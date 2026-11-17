#!/usr/bin/env python3
"""Scanner and bookkeeping for the /tidy skill.

Read-only except for its own state files:
  ~/.local/state/tidy/baseline.json   hashes of watched config files (persistent)
  $XDG_RUNTIME_DIR/tidy/acks.json      session acknowledgements (cleared on logout)

Commands:
  scan                 print the tidy report
  ack <path> <reason>  hide a config change until logout or until the file changes again
  accept <path>...     record the current content of a watched file as the new baseline
  jd-items [query]     list Google Drive JD folders (from the vault's drive-tree.json)
"""

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

HOME = Path.home()
SKILL_DIR = Path(__file__).resolve().parent.parent
MYENV = HOME / "Projects" / "my-enviroment"
VAULT = HOME / "Documents" / "Vault"
DRIVE_TREE = VAULT / "00 🛠 System" / "drive-tree.json"
JD_LINT = VAULT / "00 🛠 System" / "bin" / "jd.py"

REPO_ROOTS = [HOME / "Projects", HOME / "Work", HOME / "src"]
DOWNLOADS = HOME / "Downloads"
LOOSE_DIRS = [  # (dir, recurse, excluded child names)
    (HOME, False, set()),
    (HOME / "Pictures", True, set()),
    (HOME / "Work", False, set()),
    (HOME / "Documents", False, {"Vault"}),
]
BUILD_SHARE = Path("/data/albld30")
BUILD_HOME = Path("/data/cfleming")

STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local" / "state")) / "tidy"
BASELINE = STATE_DIR / "baseline.json"
RUNTIME = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")) / "tidy"
ACKS = RUNTIME / "acks.json"
WATCHLIST = SKILL_DIR / "config-watch.txt"

MAX_WATCH_FILES = 2000
MAX_WATCH_BYTES = 5 * 1024 * 1024


# ---------- helpers ----------

def sh(args, cwd=None, timeout=20):
    try:
        r = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        # rstrip only: `git status --porcelain` lines start with a meaningful space
        return r.returncode, r.stdout.rstrip("\n"), r.stderr.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        return 1, "", str(e)


def human_size(n):
    for unit in ("B", "K", "M", "G"):
        if n < 1024:
            return f"{n:.0f}{unit}" if unit == "B" else f"{n:.1f}{unit}"
        n /= 1024
    return f"{n:.1f}T"


def age_days(p):
    return (time.time() - p.lstat().st_mtime) / 86400


def tilde(p):
    s = str(p)
    return "~" + s[len(str(HOME)):] if s.startswith(str(HOME)) else s


def sha256(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def load_json(p, default):
    try:
        return json.loads(p.read_text())
    except (OSError, ValueError):
        return default


def save_json(p, data):
    p.parent.mkdir(parents=True, exist_ok=True)
    tmp = p.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, indent=1, sort_keys=True))
    tmp.replace(p)


def section(title):
    print(f"\n## {title}")


# ---------- repos ----------

def find_repos():
    repos = []
    for root in REPO_ROOTS:
        if not root.is_dir():
            continue
        for child in sorted(root.iterdir()):
            if child.is_symlink() or not child.is_dir():
                continue
            if (child / ".git").exists():
                repos.append(child)
            else:  # one level of grouping
                for sub in sorted(child.iterdir()):
                    if not sub.is_symlink() and sub.is_dir() and (sub / ".git").exists():
                        repos.append(sub)
    return repos


def repo_issues(repo):
    issues = []
    _, porcelain, _ = sh(["git", "status", "--porcelain"], cwd=repo)
    lines = [l for l in porcelain.splitlines() if l]
    modified = [l for l in lines if not l.startswith("??")]
    untracked = [l for l in lines if l.startswith("??")]
    if modified:
        issues.append(f"{len(modified)} uncommitted: " + ", ".join(l[3:] for l in modified[:5])
                      + (" …" if len(modified) > 5 else ""))
    if untracked:
        issues.append(f"{len(untracked)} untracked: " + ", ".join(l[3:] for l in untracked[:5])
                      + (" …" if len(untracked) > 5 else ""))
    _, remotes, _ = sh(["git", "remote"], cwd=repo)
    if not remotes:
        issues.append("no remote (exists only on this machine)")
    else:
        _, unpushed, _ = sh(["git", "log", "--branches", "--not", "--remotes", "--oneline"], cwd=repo)
        n = len([l for l in unpushed.splitlines() if l])
        if n:
            issues.append(f"{n} commit(s) not pushed (as of last fetch)")
        _, refs, _ = sh(["git", "for-each-ref", "--format=%(refname:short)\t%(upstream)", "refs/heads"], cwd=repo)
        no_up = []
        for r in refs.splitlines():
            branch, _, upstream = r.partition("\t")
            if branch and not upstream:
                no_up.append(branch)
        if no_up:
            issues.append("branch(es) with no upstream: " + ", ".join(no_up))
    _, stashes, _ = sh(["git", "stash", "list"], cwd=repo)
    n = len([l for l in stashes.splitlines() if l])
    if n:
        issues.append(f"{n} stash(es)")
    return issues


def report_repos():
    section("Repos")
    repos = find_repos()
    dirty = 0
    for repo in repos:
        issues = repo_issues(repo)
        if issues:
            dirty += 1
            print(f"- {tilde(repo)}")
            for i in issues:
                print(f"    - {i}")
    print(f"{dirty} of {len(repos)} repo(s) need attention (scanned {', '.join(tilde(r) for r in REPO_ROOTS if r.is_dir())})")


# ---------- files ----------

def file_line(p, base):
    try:
        st = p.lstat()
    except OSError:
        return None
    rel = p.relative_to(base) if base else p
    return f"- {rel}  ({human_size(st.st_size)}, {age_days(p):.0f}d old)"


def report_downloads():
    section("Downloads (all ages, oldest first)")
    if not DOWNLOADS.is_dir():
        print("~/Downloads does not exist")
        return
    items = sorted((p for p in DOWNLOADS.iterdir() if not p.name.startswith(".")),
                   key=lambda p: p.lstat().st_mtime)
    for p in items:
        suffix = "/" if p.is_dir() else ""
        line = file_line(p, DOWNLOADS)
        if line:
            print(line.replace(f"- {p.name}", f"- {p.name}{suffix}", 1))
    print(f"{len(items)} item(s) in {tilde(DOWNLOADS)}")


def report_loose():
    section("Loose files")
    total = 0
    for d, recurse, excluded in LOOSE_DIRS:
        if not d.is_dir():
            continue
        found = []
        if recurse:
            for root, dirs, files in os.walk(d):
                dirs[:] = [x for x in dirs if not x.startswith(".")]
                found += [Path(root) / f for f in files if not f.startswith(".")]
        else:
            found = [p for p in d.iterdir()
                     if not p.name.startswith(".") and p.name not in excluded
                     and p.is_file() and not p.is_symlink()]
        found.sort(key=lambda p: p.lstat().st_mtime)
        if found:
            print(f"{tilde(d)}:")
            for p in found:
                print("  " + file_line(p, d))
        total += len(found)
    print(f"{total} loose file(s)")


# ---------- destinations ----------

def report_destinations():
    section("Destinations")
    rc, _, _ = sh(["mountpoint", "-q", str(BUILD_SHARE)])
    if rc == 0:
        print(f"- build server: MOUNTED ({BUILD_SHARE}; work files go under {BUILD_HOME})")
    else:
        print(f"- build server: NOT MOUNTED. Offer: sshfs cfleming@albld30.corp.oneilluminate.com:/ {BUILD_SHARE}")
    if shutil.which("rclone"):
        _, remotes, _ = sh(["rclone", "listremotes"])
        if "gdrive:" in remotes.split():
            print("- google drive: rclone remote gdrive: configured")
        else:
            print("- google drive: rclone installed but no gdrive: remote. User runs: ! rclone config")
    else:
        print("- google drive: rclone NOT INSTALLED. User runs: ! sudo pacman -S rclone  then  ! rclone config")


# ---------- config ----------

def seeded_files():
    """(repo copy, live path) pairs that setup_links.sh copies rather than links."""
    script = MYENV / "bin" / "setup_links.sh"
    pairs = []
    try:
        for line in script.read_text().splitlines():
            m = re.match(r"\s*seedfile\s+\$MYENV_HOME/(\S+)\s+(\S+)", line)
            if m:
                pairs.append((MYENV / m.group(1), Path(os.path.expanduser(m.group(2)))))
    except OSError:
        pass
    return pairs


def linked_files():
    """(repo source, live path) pairs that setup_links.sh symlinks on this machine.

    Tracks `if $omarchy` / `if ! $omarchy` blocks so links meant only for the
    other branch aren't checked. Lines using loop variables are skipped.
    """
    script = MYENV / "bin" / "setup_links.sh"
    omarchy = Path("/etc/os-release").exists() and "ID=omarchy" in Path("/etc/os-release").read_text()
    stack, pairs = [], []
    try:
        lines = script.read_text().splitlines()
    except OSError:
        return pairs
    for line in lines:
        s = line.strip()
        if re.match(r"if\s+!\s*\$omarchy\b", s):
            stack.append(not omarchy)
        elif re.match(r"if\s+\$omarchy\b", s):
            stack.append(omarchy)
        elif re.match(r"if\b", s) and not s.endswith("fi"):
            stack.append(True)
        elif s == "else" and stack:
            stack[-1] = not stack[-1]
        elif s.startswith("fi") and stack:
            stack.pop()
        m = re.match(r"makelink\s+\$MYENV_HOME/(\S+?)/?\s+(~\S+?)/?$", s)
        if m and all(stack) and "$" not in m.group(2):
            pairs.append((MYENV / m.group(1), Path(os.path.expanduser(m.group(2)))))
    return pairs


def watch_paths():
    paths = []
    try:
        for line in WATCHLIST.read_text().splitlines():
            line = line.split("#", 1)[0].strip()
            if line:
                paths.append(Path(os.path.expanduser(line)))
    except OSError:
        pass
    return paths


def watched_files():
    """Current {path: hash} for watched files not already tracked via a link into my-enviroment."""
    myenv_real = str(MYENV.resolve())
    seeded = {str(live) for _, live in seeded_files()}
    out = {}

    def consider(p):
        if len(out) >= MAX_WATCH_FILES:
            return
        try:
            if str(p.resolve()).startswith(myenv_real + os.sep):
                return  # tracked by my-enviroment; git status covers it
            if str(p) in seeded or not p.is_file() or p.stat().st_size > MAX_WATCH_BYTES:
                return
            if ".myenvbak" in p.name:
                return  # reported separately
            out[str(p)] = sha256(p)
        except OSError:
            pass

    for w in watch_paths():
        if w.is_symlink() and str(w.resolve()).startswith(myenv_real + os.sep):
            continue
        if w.is_dir():
            for root, dirs, files in os.walk(w):
                dirs[:] = [d for d in dirs if d not in (".git", "__pycache__")]
                for f in files:
                    consider(Path(root) / f)
        elif w.exists():
            consider(w)
    return out


def report_config():
    section("Config")
    # 1. my-enviroment state
    if (MYENV / ".git").exists():
        issues = repo_issues(MYENV)
        print("- my-enviroment: " + ("clean and pushed" if not issues else "; ".join(issues)))
    else:
        print(f"- my-enviroment not found at {tilde(MYENV)}")

    # 2. seeded-file drift
    for repo_copy, live in seeded_files():
        if not live.exists():
            print(f"- seeded {tilde(live)}: missing (setup_links.sh would recreate it)")
        elif not repo_copy.exists():
            print(f"- seeded {tilde(live)}: repo copy {repo_copy.relative_to(MYENV)} missing")
        elif sha256(live) != sha256(repo_copy):
            print(f"- DRIFT seeded {tilde(live)} differs from my-enviroment/{repo_copy.relative_to(MYENV)}"
                  f"  (diff -u {repo_copy} {live})")

    # 2b. links that an app replaced with a regular file (e.g. Omarchy rewriting shell.json)
    for src, live in linked_files():
        if live.is_symlink() or not live.exists():
            continue
        if live.is_file() and src.is_file():
            same = sha256(live) == sha256(src)
            print(f"- UNLINKED {tilde(live)} is a regular file, not a link to my-enviroment/{src.relative_to(MYENV)}"
                  + ("; content identical" if same else f"; content differs (diff -u {src} {live})"))
        else:
            print(f"- UNLINKED {tilde(live)} exists but is not a link to my-enviroment/{src.relative_to(MYENV)}")

    # 3. untracked config changes vs baseline, minus session acks
    current = watched_files()
    baseline = load_json(BASELINE, None)
    if baseline is None:
        save_json(BASELINE, current)
        print(f"- watched configs: first run, baseline recorded for {len(current)} file(s); nothing to report yet")
    else:
        acks = load_json(ACKS, {})
        changed = [p for p in current if p in baseline and baseline[p] != current[p]]
        added = [p for p in current if p not in baseline]
        removed = [p for p in baseline if p not in current]
        shown = 0
        for kind, paths in (("changed", changed), ("new", added), ("removed", removed)):
            for p in sorted(paths):
                a = acks.get(p)
                if a and a.get("hash") == current.get(p):
                    continue
                print(f"- {kind}: {tilde(p)}")
                shown += 1
        hidden = sum(1 for p, a in acks.items() if a.get("hash") == current.get(p)
                     and (p in changed or p in added or p in removed))
        print(f"- watched configs: {shown} untracked change(s) to review"
              + (f", {hidden} acknowledged this session" if hidden else ""))

    # 4. myenvbak leftovers
    baks = []
    for root, dirs, files in os.walk(HOME):
        depth = Path(root).relative_to(HOME).parts
        dirs[:] = [d for d in dirs if len(depth) < 3 and d not in
                   (".cache", ".local", "node_modules", ".git", "Vault", ".mozilla", ".npm", ".cargo")]
        baks += [Path(root) / f for f in files if ".myenvbak" in f]
        baks += [Path(root) / d for d in dirs if ".myenvbak" in d]
    for b in sorted(set(baks)):
        print(f"- leftover backup: {tilde(b)}")


# ---------- vault ----------

def report_vault():
    section("Vault")
    if not JD_LINT.exists():
        print("- jd.py not found; skipped")
        return
    _, out, err = sh([sys.executable, "-I", str(JD_LINT), "lint"], cwd=VAULT, timeout=60)
    m = re.search(r"\[loose-notes\][^\n]*", out + "\n" + err)
    print("- " + (m.group(0) if m else "no loose notes at the vault root"))
    print("  (filing is left to the vault's own tooling)")


# ---------- commands ----------

def cmd_scan():
    print(f"# Tidy report  {time.strftime('%Y-%m-%d %H:%M')}")
    report_repos()
    report_downloads()
    report_loose()
    report_destinations()
    report_config()
    report_vault()


def cmd_ack(path, reason):
    p = str(Path(os.path.expanduser(path)).absolute())
    if not Path(p).is_file():
        sys.exit(f"not a file: {p}")
    acks = load_json(ACKS, {})
    acks[p] = {"hash": sha256(p), "reason": reason, "when": time.strftime("%Y-%m-%d %H:%M")}
    save_json(ACKS, acks)
    print(f"acknowledged until logout or next edit: {tilde(p)}  ({reason})")


def cmd_accept(paths):
    baseline = load_json(BASELINE, {})
    for path in paths:
        p = str(Path(os.path.expanduser(path)).absolute())
        if Path(p).is_file():
            baseline[p] = sha256(p)
            print(f"accepted as local: {tilde(p)}")
        else:
            baseline.pop(p, None)
            print(f"accepted removal: {tilde(p)}")
    save_json(BASELINE, baseline)


def cmd_jd_items(query):
    data = load_json(DRIVE_TREE, None)
    if not data:
        sys.exit(f"cannot read {DRIVE_TREE}")
    q = (query or "").lower()
    for f in sorted(data["folders"], key=lambda f: f["jd"]):
        if not q or q in f["path"].lower() or q in f["jd"]:
            print(f"{f['jd']}\t{f['path']}")


def main(argv):
    if not argv or argv[0] == "scan":
        cmd_scan()
    elif argv[0] == "ack" and len(argv) >= 3:
        cmd_ack(argv[1], " ".join(argv[2:]))
    elif argv[0] == "accept" and len(argv) >= 2:
        cmd_accept(argv[1:])
    elif argv[0] == "jd-items":
        cmd_jd_items(" ".join(argv[1:]))
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main(sys.argv[1:])

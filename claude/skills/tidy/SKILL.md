---
name: tidy
description: Report and tidy this machine. Covers repos that aren't checked in, Downloads, loose files, and config changes not recorded in my-enviroment.
disable-model-invocation: true
---

# Tidy

Run a scan, show the report, then work through it in **batches** the user approves. Nothing moves, uploads or is trashed without an approved batch.

`T=~/.claude/skills/tidy/scripts/tidy.py` (subcommands: `scan`, `ack`, `accept`, `jd-items`; `--help` for usage).

## 1. Scan and report

Run `python3 $T scan` and show its report in the terminal, condensed but with every flagged item kept. Done when the user has seen every section.

## 2. Repos: report only

List each flagged repo and what's wrong. Committing and pushing is the user's job. Offer no git actions.

## 3. Downloads and loose files

For each file, propose one action with a one-line reason:

| Action | When | How |
|---|---|---|
| **trash** | Duplicates (`name (1).pdf`), installers, throwaway exports | `gio trash <file>` |
| **work** | Work material: customer docs, manuals, scan reports, code | Copy to `/data/cfleming/<folder>/` |
| **personal** | Personal documents | Upload to Google Drive under a Johnny.Decimal item |
| **keep** | Still in use, or the user wants it where it is | Leave it |

Judge work vs personal from the name, type and content (peek at the first page or lines when the name isn't enough). Mark uncertain calls with `?` so the user decides.

Present the proposals as one table per batch (at most ~15 rows). Apply only after the user approves, applying their edits. Done when every file in the report has an approved action applied or an explicit keep.

**Work files.**
- If the report says the build server is not mounted, ask, then run the sshfs command it gives. If that fails, skip work files and say so.
- To pick a folder, run `timeout 15 ls /data/cfleming`. The share is large and `core/` is permission-denied, so never recurse into it. Use an existing folder that clearly fits, else `/data/cfleming/inbox/`.
- Copy with `cp -pn`, confirm with `cmp`, then `gio trash` the original. An existing file of the same name at the destination is a conflict: ask.

**Personal files.**
- If the report says rclone isn't ready, give the user the setup commands it prints, using the personal-rclone OAuth client from their vault note and naming the remote `gdrive`. Skip Drive uploads until it's set up.
- Pick the Johnny.Decimal item with `python3 $T jd-items <keyword>` (e.g. `payslip`, `car`, `health`). Upload to `gdrive:Document System/<path>/`. If no item clearly fits, use that category's `NN.01` inbox.
- Run `rclone copy --ignore-existing <file> "gdrive:Document System/<path>/"`, confirm with `rclone lsl` that the remote size matches, then `gio trash` the original.

## 4. Config

Each config finding needs one outcome:

- **my-enviroment uncommitted or unpushed**: report it. The user commits.
- **DRIFT** (a seeded file differs from its repo copy): show the diff. On approval, `cp` the live file over the repo copy. It then shows as uncommitted in my-enviroment.
- **UNLINKED** (an app replaced a symlink with a regular file): show the diff. Offer to copy the live content into the repo and restore the link with `ln -sfn <repo file> <live path>`. Apply only on approval, and keep the live content.
- **changed / new / removed** watched config: show the diff where possible, then offer:
  - **check in**: move it into my-enviroment and add a `makelink` line to `bin/setup_links.sh`
  - **acknowledge for this session**: `python3 $T ack <path> "<reason>"`. It's hidden until logout or the next edit.
  - **accept as local**: `python3 $T accept <path>`. It's permanently fine as it is.
- **Leftover `*.myenvbak`**: offer `gio trash` for each. If its content differs from the live file, show the diff first.

Done when every config finding has an outcome the user chose.

## 5. Vault

Repeat the loose-notes count. Filing belongs to the vault's own `jd.py`.

## 6. Wrap up

Summarise what was trashed, moved, uploaded, acknowledged and accepted, and what's left for the user (commits, rclone setup).

The watch list is `~/.claude/skills/tidy/config-watch.txt`. Edit it when the user wants a path watched or dropped.

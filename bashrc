#!/bin/bash
#
# Chris's bashrc
#
# Linked to ~/.bashrc (or ~/.bashrc_myenv on Omarchy, which layers it on top of
# its own config - see bin/setup_links.sh). Interactive shells only.
#
# Targets bash 4.4+ (RHEL/Rocky 8 is the oldest system this runs on), so avoid
# newer features such as EPOCHSECONDS, ${var@U} or `wait -n`.
#
# Machine specific overrides go in ~/.bashrc_local and ~/.bashrc_$(hostname),
# which are sourced near the end so they can override anything here.
#
# Various bits borrowed from:
#   https://github.com/ciaranm/dotfiles-ciaranm
#   https://github.com/stsquad/dotfiles

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Where this checkout lives, following the ~/.bashrc symlink. Fall back to the
# canonical path if readlink -f isn't available.
MYENV_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null)" 2>/dev/null)
[[ -d $MYENV_HOME/bin ]] || MYENV_HOME=$HOME/projects/my-enviroment
export MYENV_HOME

# Shared helper functions: find_alternatives, pathadd, start_agent, ...
. "$MYENV_HOME/bin/aliases.sh"
. "$MYENV_HOME/bin/common.sh"

#######################################################################
# Terminal setup
#######################################################################

# Remote hosts often lack the terminfo for newer terminals (xterm-ghostty,
# xterm-kitty, ...), which breaks vim, less, etc. Fall back to something
# universal rather than forcing every xterm-* to xterm-256color.
if [[ -n $TERM && $TERM != dumb ]]; then
  if [[ $TERM == xterm ]] || { type -P infocmp >/dev/null && ! infocmp "$TERM" >/dev/null 2>&1; }; then
    export TERM=xterm-256color
  fi
fi

# Colours used by the prompt. Real escape characters (not \033 text) so they
# can be used both in PS1 and in $(...) expansions. Choose by what the terminal
# supports.
_ncolours=$(tput colors 2>/dev/null || echo 2)
if ((_ncolours >= 256)); then
  _c_yell=$'\033[38;5;229m' _c_gren=$'\033[38;5;35m' _c_orng=$'\033[38;5;208m'
  _c_pink=$'\033[38;5;206m' _c_blue=$'\033[38;5;33m' _c_teal=$'\033[38;5;38m'
  _c_brwn=$'\033[38;5;130m' _c_myel=$'\033[38;5;227m' _c_end=$'\033[0m'
elif ((_ncolours >= 8)); then
  _c_yell=$'\033[1;33m' _c_gren=$'\033[0;32m' _c_orng=$'\033[1;31m'
  _c_pink=$'\033[1;35m' _c_blue=$'\033[1;34m' _c_teal=$'\033[0;36m'
  _c_brwn=$'\033[0;31m' _c_myel=$'\033[0;33m' _c_end=$'\033[0m'
else
  _c_yell= _c_gren= _c_orng= _c_pink= _c_blue= _c_teal= _c_brwn= _c_myel= _c_end=
fi
unset _ncolours

# Sensible shell options
shopt -s checkwinsize        # keep LINES/COLUMNS right after resizing
shopt -s histappend          # append to the history file, don't overwrite it
shopt -s cmdhist             # keep multi-line commands as one history entry
shopt -s globstar 2>/dev/null # ** matches recursively (bash 4+)

# I want core-dumps dammit
ulimit -S -c unlimited 2>/dev/null

#############
# Aliases
#############

# I like a quick grep of history
alias h="history | grep"

# Find a given export in history
function he {
  if [ "$1" ]; then
    history | grep -E "^ *[0-9]+ +export $1" | uniq -s 6 -u
  fi
}

# Find files by (case insensitive) name, e.g.  f '*.py'
alias f="find . -iname"

# Search all text files under here, or just C/C++ source
alias sa="grep -rIn --exclude-dir=.git"
alias sc="grep -rIn --exclude-dir=.git --include='*.[chS]' --include='*.cc' --include='*.cpp' --include='*.hpp'"

# Colour for ls and grep, using whatever flavour of ls we have (GNU or BSD)
if ls --color=auto -d / >/dev/null 2>&1; then
  alias ls='ls --color=auto'
elif ls -G -d / >/dev/null 2>&1; then
  alias ls='ls -G'
fi
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'

# dircolors: keep LS_COLORS from common.sh (solarized) or the environment
# unless I have a ~/.dircolors
if type -P dircolors >/dev/null; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  elif [[ -z $LS_COLORS ]]; then
    eval "$(dircolors -b)"
  fi
fi

######################
# Environment variables
######################

# macports, ~/bin and ~/.local/bin
for _d in /opt/local/sbin /opt/local/bin "$HOME/.local/bin" "$HOME/bin"; do
  pathadd "$_d"
done
unset _d
export PATH

# rvm wants to be last in PATH and loaded as a function
[[ -s $HOME/.rvm/scripts/rvm ]] && source "$HOME/.rvm/scripts/rvm"
pathadd "$HOME/.rvm/bin" after

export EDITOR
EDITOR=$(find_alternatives nvim vim vi)
export VISUAL=$EDITOR

# Only set BROWSER if the desktop hasn't already
if [[ -z $BROWSER ]]; then
  BROWSER=$(find_alternatives firefox chromium chromium-browser google-chrome chrome)
  [[ -n $BROWSER ]] && export BROWSER || unset BROWSER
fi

# man pages et al. Make less pass colour through, and handle non-text files
# (Debian ships lesspipe, RHEL ships lesspipe.sh).
export PAGER=less
: "${LESS:=-R}"
export LESS
_lesspipe=$(find_alternatives lesspipe lesspipe.sh)
[[ -n $_lesspipe ]] && eval "$(SHELL=/bin/sh "$_lesspipe")"
unset _lesspipe

# Python, cargo
export PYTHONSTARTUP=$MYENV_HOME/pythonstartup
[[ -s $HOME/.cargo/env ]] && source "$HOME/.cargo/env"

# nvm (loaded eagerly: tools like neovim's LSP need node on PATH)
export NVM_DIR="$HOME/.nvm"
[[ -s $NVM_DIR/nvm.sh ]] && \. "$NVM_DIR/nvm.sh"
[[ -s $NVM_DIR/bash_completion ]] && \. "$NVM_DIR/bash_completion"

#
# surfraw, command line browser control
#
_surfraw=$(find_alternatives surfraw)
if [[ -n $_surfraw ]]; then
  alias wiki="$_surfraw wikipedia "
  alias google="$_surfraw google "
  alias imdb="$_surfraw imdb "
fi
unset _surfraw

########################
# History
########################

export HISTFILE=~/.bash_history
export HISTCONTROL=ignoreboth
export HISTIGNORE="rm *:h *:history"
export HISTSIZE=50000
export HISTFILESIZE=50000

# Share history between running shells: write this shell's new lines to the
# file, then re-read it. Solution from http://unix.stackexchange.com/a/48116
# (The name is relied on by the Omarchy hook that setup_links.sh adds to ~/.bashrc.)
_bash_history_sync() {
  builtin history -a
  builtin history -c
  builtin history -r
}

########################
# Prompt
########################

# Add a command to PROMPT_COMMAND, which is an array on newer bash (and on
# Omarchy) and a plain string on older ones such as Rocky 8's. $1 = command,
# $2 = "first" to put it ahead of the existing ones. Adding twice is harmless.
_prompt_add() {
  if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == "declare -a"* ]]; then
    local c
    for c in "${PROMPT_COMMAND[@]}"; do [[ $c == "$1" ]] && return 0; done
    if [[ $2 == first ]]; then PROMPT_COMMAND=("$1" "${PROMPT_COMMAND[@]}")
    else PROMPT_COMMAND+=("$1"); fi
  else
    case ";$PROMPT_COMMAND;" in *"; $1;"* | *";$1;"*) return 0 ;; esac
    if [[ $2 == first ]]; then PROMPT_COMMAND="$1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    else PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }$1"; fi
  fi
}

# Runs before every prompt. Must be first so $? is still the last command's.
_myenv_prompt() {
  local rc=$?
  prompt_exit_status=$rc
  if ((rc == 0)); then _ps_stat_colour=$_c_yell; else _ps_stat_colour=$_c_orng; fi
  _bash_history_sync
  # Set the terminal title
  case "$TERM" in
    xterm* | rxvt* | alacritty* | foot* | tmux* | screen*)
      printf '\033]0;%s@%s:%s\007' "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"
      ;;
  esac
  return $rc
}
# If starship (Omarchy) already owns the prompt, leave PROMPT_COMMAND alone: it
# keeps its own title/history hooks, and a second hook would make it run twice.
if [[ ${PROMPT_COMMAND[*]} != *starship_precmd* ]]; then
  _prompt_add "_myenv_prompt" first
fi

ps_job_f() {
  local j
  j=$(jobs)
  if [[ -n $j ]]; then
    local l=${j//[^$'\n']/}
    echo "&$((${#l} + 1)) "
  fi
}

ps_dir_f() {
  if ((${#DIRSTACK[@]} > 1)); then
    echo "^$((${#DIRSTACK[@]} - 1)) "
  fi
}

ps_scr_f() {
  if [[ -n $TMUX || $TERM == screen* ]]; then
    echo "s "
  fi
}

ps_ven_f() {
  if [[ -n $VIRTUAL_ENV ]]; then
    echo "[$(basename "$VIRTUAL_ENV")] "
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    echo "[$CONDA_DEFAULT_ENV] "
  fi
}

# Git status for the prompt:  (branch +ahead-behind *+?)
#   * unstaged changes   + staged changes   ? untracked files
# plus rebase/merge/bisect state when one is in progress.
ps_scm_f() {
  local out
  out=$(GIT_OPTIONAL_LOCKS=0 git status --porcelain=v1 -b 2>/dev/null) || return 0
  [[ -n $out ]] || return 0

  local head=${out%%$'\n'*} branch ab= flags= state= d
  head=${head#\#\# }
  branch=${head%%...*}
  branch=${branch%% \[*}
  case "$head" in
    "No commits yet on "*) branch=${head#No commits yet on } ;;
    "HEAD (no branch)")
      branch=$(git rev-parse --short HEAD 2>/dev/null)
      ;;
  esac

  local re='\[(ahead ([0-9]+))?(, )?(behind ([0-9]+))?\]'
  if [[ $head =~ $re ]]; then
    [[ -n ${BASH_REMATCH[2]} ]] && ab+="+${BASH_REMATCH[2]}"
    [[ -n ${BASH_REMATCH[5]} ]] && ab+="-${BASH_REMATCH[5]}"
  fi

  local nl=$'\n' re_unstaged=$'\n'.[MD] re_staged=$'\n'[MADRC]
  [[ $out =~ $re_unstaged ]] && flags+="*"
  [[ $out =~ $re_staged ]] && flags+="+"
  [[ $out == *"$nl??"* ]] && flags+="?"

  d=$(git rev-parse --git-dir 2>/dev/null)
  if [[ -d $d/rebase-merge || -d $d/rebase-apply ]]; then state=rebase
  elif [[ -f $d/MERGE_HEAD ]]; then state=merge
  elif [[ -f $d/BISECT_LOG ]]; then state=bisect
  fi

  echo "(${state:+$state:}${branch}${ab}${flags:+ $flags}) "
}

ps_usr="\[${_c_yell}\]\u@"
ps_hst="\[${_c_yell}\]\h "
ps_cwd="\[${_c_gren}\]\W "
ps_ret="\[\${_ps_stat_colour}\]\${prompt_exit_status} "
ps_job="\[${_c_pink}\]\$(ps_job_f)"
ps_dir="\[${_c_brwn}\]\$(ps_dir_f)"
ps_scr="\[${_c_blue}\]\$(ps_scr_f)"
ps_scm="\[${_c_orng}\]\$(ps_scm_f)"
ps_ven="\[${_c_teal}\]\$(ps_ven_f)"
ps_mrk="\[${_c_myel}\]\\\$ "
ps_end="\[${_c_end}\]"
PS1="${ps_usr}${ps_hst}${ps_cwd}${ps_ret}${ps_job}${ps_dir}${ps_scr}${ps_scm}${ps_ven}${ps_mrk}${ps_end}"

########################
# Optional per-tool and per-machine config
########################

# Extras that only make sense if the tool is installed
for _pair in emacs:emacs apt-get:apt gpg-agent:gpg screen:screen; do
  if type -P "${_pair%%:*}" >/dev/null && [[ -r $HOME/.bashrc_${_pair##*:} ]]; then
    source "$HOME/.bashrc_${_pair##*:}"
  fi
done
unset _pair

# Completion (Rocky/RHEL, Debian/Ubuntu, Arch, fink)
if ! shopt -oq posix && ! type _init_completion >/dev/null 2>&1; then
  for _f in /usr/share/bash-completion/bash_completion /etc/bash_completion /sw/etc/bash_completion; do
    if [[ -r $_f ]]; then
      . "$_f"
      break
    fi
  done
  unset _f
fi

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# Generic local config for work and stuff, then anything machine specific.
# These come late so they can override anything above.
[[ -f $HOME/.bashrc_local ]] && source "$HOME/.bashrc_local"
for _h in "$(hostname 2>/dev/null)" "$(hostname -s 2>/dev/null)"; do
  if [[ -n $_h && -f $HOME/.bashrc_$_h ]]; then
    source "$HOME/.bashrc_$_h"
    break
  fi
done
unset _h

########################
# SSH agent
########################

SSH_ENV="$HOME/.ssh/environment"

# Is SSH_AUTH_SOCK an agent that answers? (ssh-add -l: 0 = has keys, 1 = none,
# 2 = can't connect.) Covers a forwarded agent, systemd's ssh-agent.socket and
# keychain's agent, so we only start one when we need to.
_ssh_agent_usable() {
  [[ -S ${SSH_AUTH_SOCK:-} ]] || return 1
  local rc
  if type -P timeout >/dev/null; then
    timeout 3 ssh-add -l >/dev/null 2>&1
  else
    ssh-add -l >/dev/null 2>&1
  fi
  rc=$?
  ((rc == 0 || rc == 1))
}

if type -P ssh-add >/dev/null && ! _ssh_agent_usable; then
  if type -P keychain >/dev/null; then
    _ssh_keys=()
    for _k in id_rsa id_ed25519 id_sftp; do
      [[ -f $HOME/.ssh/$_k ]] && _ssh_keys+=("$_k")
    done
    eval "$(keychain --quiet --eval --inherit any "${_ssh_keys[@]}" 2>/dev/null)"
    unset _ssh_keys _k
  elif [[ -f $SSH_ENV ]] && . "$SSH_ENV" >/dev/null && kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    : # re-using the agent saved from an earlier shell
  else
    start_agent
  fi
fi
unset -f _ssh_agent_usable

########################
# Keep this repo up to date
########################

# Refresh the remote in the background (at most every 10 hours, never prompting
# for credentials), and say so if this checkout is behind or has local changes.
_myenv_update_check() {
  type -P git >/dev/null && [[ -d $MYENV_HOME/.git ]] || return 0
  local fh=$MYENV_HOME/.git/FETCH_HEAD
  if [[ ! -e $fh || -n $(find "$fh" -mmin +600 2>/dev/null) ]]; then
    (GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5' \
      git -C "$MYENV_HOME" remote update >/dev/null 2>&1 &)
  fi
  local st
  st=$(git -C "$MYENV_HOME" status -sb -uno 2>/dev/null)
  # Quiet when on a branch tracking its remote with nothing to report
  if [[ $st == *$'\n'* || $st == *"["* ]]; then
    echo "my-enviroment: $st"
  fi
}
_myenv_update_check
unset -f _myenv_update_check

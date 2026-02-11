#!/bin/bash
#
# Chris's .bash_profile
# loaded by bash when any login shell started
#
# Various bits borrowed from:
#
# Grabbed from https://github.com/ciaranm/dotfiles-ciaranm
# https://github.com/stsquad/dotfiles

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source aliases
. $HOME/projects/my-enviroment/bin/aliases.sh
. $HOME/projects/my-enviroment/bin/common.sh

# Generic local configs for work and stuff
if [ -f $HOME/.bashrc_local ]; then
  echo "loading .bashrc_local"
  source $HOME/.bashrc_local
fi

# Source aliases
. $HOME/projects/my-enviroment/bin/aliases.sh

# Generic local configs for work and stuff
if [ -f $HOME/.bashrc_local ]; then
  echo "loading .bashrc_local"
  source $HOME/.bashrc_local
fi

#
# Source global definitions
#

# Pull in fink stuff on the mac
if [ -f /sw/bin/init.sh ]; then
  . /sw/bin/init.sh
fi

#######################################################################
# Terminal Setup
#
# via http://github.com/ciaranm/dotfiles-ciaranm/tree/master/bashrc
#
# The Apple Terminal doesn't seem to handle 256 colours very well so we
# limit it to a 16 colour display
#
# Need a way to deal with mac's when sshing in...
# possibly assumen xterm-color is only 16 colours
#
#
#######################################################################
case "${TERM}" in
xterm*)
  export TERM=xterm-256color
  cache_term_colours=256
  ;;
screen*)
  cache_term_colours=256
  ;;
cygwin)
  cache_term_colours=256
  ;;
dumb)
  cache_term_colours=2
  ;;
*)
  cache_term_colours=16
  ;;
esac

case "${cache_term_colours}" in
256)
  cache_colour_l_blue='\033[38;5;33m'
  cache_colour_d_blue='\033[38;5;21m'
  cache_colour_m_purp='\033[38;5;69m'
  cache_colour_l_yell='\033[38;5;229m'
  cache_colour_m_yell='\033[38;5;227m'
  cache_colour_m_gren='\033[38;5;35m'
  cache_colour_m_grey='\033[38;5;245m'
  cache_colour_m_orng='\033[38;5;208m'
  cache_colour_l_pink='\033[38;5;206m'
  cache_colour_m_teal='\033[38;5;38m'
  cache_colour_m_brwn='\033[38;5;130m'
  cache_colour_end='\033[0;0m'
  ;;
16)
  cache_colour_l_blue='\033[1;34m'
  cache_colour_d_blue='\033[0;32m'
  cache_colour_m_purp='\033[0;35m'
  cache_colour_l_yell='\033[1;33m'
  cache_colour_m_yell='\033[0;33m'
  cache_colour_m_gren='\033[0;32m'
  cache_colour_m_grey='\033[0;37m'
  cache_colour_m_orng='\033[1;31m'
  cache_colour_l_pink='\033[1;35m'
  cache_colour_m_teal='\033[0;36m'
  cache_colour_m_brwn='\033[0;31m'
  cache_colour_end='\033[0;0m'
  ;;
*)
  eval unset ${!cache_colour_*}
  ;;
esac

cache_colour_usr=${cache_colour_l_yell}
cache_colour_hst=${cache_colour_l_yell}
cache_colour_cwd=${cache_colour_m_gren}
cache_colour_wrk=${cache_colour_m_teal}
cache_colour_rok=${cache_colour_l_yell}
cache_colour_rer=${cache_colour_m_orng}
cache_colour_job=${cache_colour_l_pink}
cache_colour_dir=${cache_colour_m_brwn}
cache_colour_mrk=${cache_colour_m_yell}
cache_colour_lda=${cache_colour_m_yell}
cache_colour_scr=${cache_colour_l_blue}
cache_colour_scm=${cache_colour_m_orng}
cache_colour_ven=${cache_colour_m_teal}

# Setup the TERM Title
case "${TERM}" in
xterm*)
  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
  ;;
screen)
  PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
  ;;
*)
  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
  ;;
esac

# If we are in a screen session then set the Window Name to Hostname
reset_screen_title

#setxkbmap -option "ctrl:nocaps"

#############
# Aliases
#############

# I like a quick grep of history
alias h="history | grep"

# Find a given export in history
function he {
  if [ "$1" ]; then
    history | grep -E "^ [0-9]+ export $1" | uniq -s 6 -u
  fi
}

#
# Lets see if we have a decent "grep"
GREP=$(find_alternatives "ggrep" "grep" "/bin/grep")
alias grep="$GREP"

#
# Look for a decent diff
DIFF=$(find_alternatives "gdiff" "diff")
alias diff="$DIFF"

# Some systems I use don't have a decent 'find' implentation so
# Lets look for gfind first (The GNU find on Solaris)
FIND=$(find_alternatives "gfind" "find")
alias find="$FIND"

FIND_VERSION=$(find --version 2>/dev/null)
if [ "${FIND_VERSION:0:8}" == "GNU find" ]; then

  # Some nice find expressions
  FIND_BACKUPS=" -name '.#*' -o -name '#*#' -o -name '*\.~*.~' -o -path '*./CVS/*.'"
  FIND_CVS=" -path '*./CVS/.*' "
  FIND_CCODE=" -iname '*.[chS]' -or -iname '*.cc' "
  FIND_CHEAD=" -iname '*.h' "

  # and search code for stuff (when I figure out proper expansion and quuting I'll make this neater)
  #alias sc="find . -iname '*.[chS]' -or -iname '*.cc' -and -not \( -name '.#' -o -name '#*#' -o -name '*\.~*.~' -o -path '*./CVS/*.' \) -print0 | xargs -0 grep -H "

  alias f="$FIND -iname"
  alias sc="$FIND . \( $FIND_CCODE \) -and -not \( $FIND_BACKUPS -o $FIND_CVS \) -print0 | xargs -0 grep -H"
  # alias sh="find . -iname '*.h' -print0 | xargs -0 grep -H "
  alias sa="$FIND . -xtype f -print0 | xargs -0 grep -H "
else
  #
  # Who knows how standard unix is, its not GNU so probably not
  #
  # Lets assume both find and grep are borken
  #

  # Find files under here
  alias f="$FIND . -name"

  # and search code for stuff
  alias sc="$FIND . -name '*.[chS]' -o -name '*.cc' | xargs grep "
  # alias sh="find . -name '*.h' | xargs grep "
  alias sa="$FIND -L . -type f | xargs grep "
fi

# Find a decent browser
BROWSER=$(find_alternatives "chromium-browser" "chrome" "firefox-4.0" "firefox" "mozilla")

######################
# Environent Variables
######################

# Add /opt/local/bin and /opt/local/sbin to path if they exsit, needed for macports and generally
paths=("/opt/local/sbin" "/opt/local/bin" "$HOME/bin" "$HOME/.rvm/bin")

for d in "${paths[@]}"; do
  pathadd $d
done

export PATH
# Lets setup rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export EDITOR=$(find_alternatives "mvim" "vim" "vi")

# Append to history file
shopt -s histappend

export HISTFILE=~/.bash_history
export HISTCONTROL=ignoredups:ignorespace
export HISTIGNORE="rm *:h *:history"
export HISTSIZE=10000
export HISTFILESIZE=10000

# From solution under: http://unix.stackexchange.com/a/48116

history() {
  _bash_history_sync
  builtin history "$@"
}
_bash_history_sync() {
  builtin history -a     #1
  HISTFILESIZE=$HISTSIZE #2
  builtin history -c     #3
  builtin history -r     #4
}

# Dump history to the file each prompt
PROMPT_COMMAND="_bash_history_sync; $PROMPT_COMMAND"

# GNU systems usually use less by default for
# man pages, however not all unix-a-likes do
export PAGER=less

# and while we're at it make less handle non text...
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#
# GIT Stuff
#
export GIT_AUTHOR_NAME="Chris Fleming"
export GIT_AUTHOR_EMAIL="me@chrisfleming.org"
export GIT_COMMITTER_NAME="Chris Fleming"

#
# surfraw, command line browser control
# http://surfraw.alioth.debian.org/
#
SURFRAW=$(find_alternatives "surfraw")
if [[ -f $SURFRAW ]]; then
  alias wiki="$SURFRAW wikipedia "
  alias google="$SURFRAW google "
  alias imdb="$SURFRAW imdb "
  alias code="$SURFRAW codesearch"
  alias jspcode="$SURFRAW codesearch lang:jsp"
  alias javacode="$SURFRAW codesearch lang:java"
  alias pycode="$SURFRAW codesearch lang:python"
fi

########################
# PS Setup
########################

ps_wrk_f() {
  if [[ "${PWD/ciaranm\/snow/}" != "${PWD}" ]]; then
    local p="snow${PWD#*/ciaranm/snow}"
    p="${p%%/*}"
    echo "@${p}"
  fi
}

ps_retc_f() {
  if [[ ${1} -eq 0 ]]; then
    echo -e "${cache_colour_rok}"
  else
    echo -e "${cache_colour_rer}"
  fi
  return $1
}

ps_job_f() {
  local j="$(jobs)"
  if [[ -n ${j} ]]; then
    local l="${j//[^$'\n']/}"
    echo "&$((${#l} + 1)) "
  fi
}

ps_dir_f() {
  if [[ "${#DIRSTACK[@]}" -gt 1 ]]; then
    echo "^$((${#DIRSTACK[@]} - 1)) "
  fi
}

ps_lda_f() {
  local u=$(uptime)
  u=${u#*average?(s): }
  echo "${u%%,*} "
}

ps_scr_f() {
  if [[ "${TERM/screen/}" != "${TERM}" ]]; then
    echo "s "
  fi
}

ps_ven_f() {
  if [[ $VIRTUAL_ENV ]]; then
    echo "[$(basename $VIRTUAL_ENV)] "
  fi
}

ps_scm_f() {
  local s=
  if [[ -f $CLEARCASE_ROOT ]]; then
    s="($(basename $CLEARCASE_ROOT))"
  elif [[ -d ".svn" ]]; then
    local r=$(svn info | sed -n -e '/^Revision: \([0-9]*\).*$/s//\1/p')
    s="(r$r$(svn status | grep -q -v '^?' && echo -n "*"))"
  else
    local d=$(git rev-parse --git-dir 2>/dev/null) b= r= a= c= e= f= g=
    if [[ -n "${d}" ]]; then
      if [[ -d "${d}/../.dotest" ]]; then
        if [[ -f "${d}/../.dotest/rebase" ]]; then
          r="rebase"
        elif [[ -f "${d}/../.dotest/applying" ]]; then
          r="am"
        else
          r="???"
        fi
        b=$(git symbolic-ref HEAD 2>/dev/null)
      elif [[ -f "${d}/.dotest-merge/interactive" ]]; then
        r="rebase-i"
        b=$(<${d}/.dotest-merge/head-name)
      elif [[ -d "${d}/../.dotest-merge" ]]; then
        r="rebase-m"
        b=$(<${d}/.dotest-merge/head-name)
      elif [[ -f "${d}/MERGE_HEAD" ]]; then
        r="merge"
        b=$(git symbolic-ref HEAD 2>/dev/null)
      elif [[ -f "${d}/BISECT_LOG" ]]; then
        r="bisect"
        b=$(git symbolic-ref HEAD 2>/dev/null)"???"
      else
        r=""
        b=$(git symbolic-ref HEAD 2>/dev/null)
      fi

      if git status | grep -q '^# Changed but not updated:'; then
        a="${a}*"
      fi

      if git status | grep -q '^# Changes to be committed:'; then
        a="${a}+"
      fi

      if git status | grep -q '^# Untracked files:'; then
        a="${a}?"
      fi

      e=$(git status | sed -n -e '/^# Your branch is /s/^.*\(ahead\|behind\).* by \(.*\) commit.*/\1 \2/p')
      if [[ -n ${e} ]]; then
        f=${e#* }
        g=${e% *}
        if [[ ${g} == "ahead" ]]; then
          e="+${f}"
        else
          e="-${f}"
        fi
      else
        e=
      fi

      b=${b#refs/heads/}
      b=${b// /}
      [[ -n "${b}" ]] && c="$(git config "branch.${b}.remote" 2>/dev/null)"
      [[ -n "${r}${b}${c}${a}" ]] && s="(${r:+${r}:}${b}${c:+@${c}}${e}${a:+ ${a}})"
    fi
  fi
  s="${s}${ACTIVE_COMPILER}"
  s="${s:+${s} }"
  echo -n "$s"
}

PROMPT_COMMAND="export prompt_exit_status=\$? ; $PROMPT_COMMAND"
ps_usr="\[${cache_colour_usr}\]\u@"
ps_hst="\[${cache_colour_hst}\]\h "
ps_cwd="\[${cache_colour_cwd}\]\W\[${cache_colour_wrk}\]\$(ps_wrk_f) "
ps_mrk="\[${cache_colour_mrk}\]\$ "
ps_end="\[${cache_colour_end}\]"
ps_ret='\[$(ps_retc_f $prompt_exit_status)\]$prompt_exit_status '
ps_job="\[${cache_colour_job}\]\$(ps_job_f)"
ps_lda="\[${cache_colour_lda}\]\$(ps_lda_f)"
ps_dir="\[${cache_colour_dir}\]\$(ps_dir_f)"
ps_scr="\[${cache_colour_scr}\]\$(ps_scr_f)"
ps_scm="\[${cache_colour_scm}\]\$(ps_scm_f)"
ps_ven="\[${cache_colour_ven}\]\$(ps_ven_f)"
#export PS1="${ps_sav}${ps_usr}${ps_hst}${ps_cwd}${ps_ret}${ps_lda}${ps_job}${ps_dir}${ps_scr}${ps_scm}"
export PS1="${ps_usr}${ps_hst}${ps_cwd}${ps_ret}${ps_job}${ps_dir}${ps_scr}${ps_scm}${ps_ven}"
export PS1="${PS1}${ps_mrk}${ps_end}"

# End PS Setup
#########################
# We want to extract the screen session name (if it exisits) from STY
function ps_xterm_f() {
  session_name=${STY/*./}
  if [ $session_name ]; then
    session_name="${session_name}@$(hostname)"
  else
    session_name="$(pwd)@$(hostname)"
  fi
  echo -n -e "\e]2;${session_name}\a"
}

if [[ "$TERM" == "xterm" || "$TERM" == "screen" ]]; then
  # Too prevent confusion about line lengths we append this to the PROMPT_COMMAND
  export PROMPT_COMMAND="$PROMPT_COMMAND; ps_xterm_f"
fi

########################
# Miscelaneous Stuff
########################
# I want core-dumps dammit
ulimit -S -c unlimited

#
# Now source any local bashrc's which can overide stuff
# or add stuff relevant to the system I am on
#
# We only want this for interactive shells as remote
# noise just gets in the way.

# If we have emacs on this system we have stuff we can do
EMACS=$(find_alternatives "emacs")
if [[ -f $EMACS && -f $HOME/.bashrc_emacs ]]; then
  source $HOME/.bashrc_emacs
fi
unset EMACS

VIM=$(find_alternatives "vim")
if [[ (-f $VIM && $TERM==screen) ]]; then
  function vim() {
    echo -ne '\033k'$(hostname | cut -d . -f1):"$*"'\033\\'
    $VIM $*
    echo -ne '\033k'$(hostname | cut -d . -f1)'\033\\'
  }
fi

# If we have apt on this system I'll want some
# debian like shortcuts
APT=$(find_alternatives "apt-get")
if [[ -f $APT && -f $HOME/.bashrc_apt ]]; then
  echo "loading .bashrc_apt"
  source $HOME/.bashrc_apt
fi
unset APT

# GPG Agent
SCREEN=$(find_alternatives "gpg-agent")
if [[ -f $SCREEN && -f $HOME/.bashrc_gpg ]]; then
  source $HOME/.bashrc_gpg
fi

# Screen Tweaks
SCREEN=$(find_alternatives "screen")
if [[ -f $SCREEN && -f $HOME/.bashrc_screen ]]; then
  source $HOME/.bashrc_screen
fi

# Any machine specific stuff
HOST_BASHRC="$HOME/.bashrc_$(hostname)"
if [ -f $HOST_BASHRC ]; then
  echo "loading .bashrc_$(hostname)"
  source $HOST_BASHRC
fi

# Put some colour into my life

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Pull in bash completion stuff is possible...

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

if [ -f /sw/etc/bash_completion ] && ! shopt -oq posix; then
  . /sw/etc/bash_completion
fi

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

SSH_ENV="$HOME/.ssh/environment"
# Source SSH settings, if applicable

if [[ -z "${SSH_AUTH_SOCK}" ]]; then
  if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" >/dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ >/dev/null || {
      start_agent
    }
  else
    start_agent
  fi
fi

# GPG_ENV="$HOME/.gpg-agent-info"
# GPGAGENT=$(find_alternatives "gpg-agent")
# if [[ -f $GPGAGENT ]]; then

#    GPG_TTY=$(tty)
#    export GPG_TTY
# If file exisits and gpg is running just source file, otherwise start
#	if test -f "${GPG_ENV}" && kill -0 `cut -d: -f 2 $GPG_ENV | head -n 1` 2>/dev/null; then
#        . "${HOME}/.gpg-agent-info"
#        export GPG_AGENT_INFO
#        export SSH_AUTH_SOCK
#        export SSH_AGENT_PID
#	else
#        eval `gpg-agent --daemon --enable-ssh-support --write-env-file ${GPG_ENV}`
#	fi
#
#fi

# Check that enviroment files don't have an update.
# TODO: only do this once a day.

GIT=$(find_alternatives "git")
if [[ -f $GIT && -d ~/projects/my-enviroment ]]; then
  pushd ~/projects/my-enviroment/ >/dev/null
  if test "$(find ./.git/FETCH_HEAD -mmin +600)"; then
    echo $(date) ": git remote update"
    git remote update >/dev/null
  fi
  git status -uno | grep -v "On branch master" | grep -v "nothing to commit"
  popd >/dev/null
fi
unset GIT

pathadd "$HOME/.rvm/bin" append

export PYTHONSTARTUP=$HOME/projects/my-enviroment/pythonstartup
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
. "$HOME/.cargo/env"

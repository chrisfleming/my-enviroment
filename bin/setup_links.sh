#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
MYENV_HOME=$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)

# Many dotfiles still refer to $HOME/projects/my-enviroment. If this checkout
# lives somewhere else (e.g. ~/Projects on a case-sensitive filesystem), provide
# that path as a symlink so those references keep working.
CANONICAL=$HOME/projects/my-enviroment
if [[ "$MYENV_HOME" != "$CANONICAL" && ! -e "$CANONICAL" ]]; then
  echo "linking $CANONICAL -> $MYENV_HOME"
  mkdir -p "$HOME/projects"
  ln -s "$MYENV_HOME" "$CANONICAL"
fi

# Always link through the canonical path, however this script was reached
# (~/Projects/... and ~/projects/... are the same checkout). Otherwise every
# existing link looks wrong and gets needlessly backed up and recreated.
if [[ "$CANONICAL" -ef "$MYENV_HOME" ]]; then
  MYENV_HOME=$CANONICAL
fi

# Copy a file into place only if it isn't there yet. For files that Omarchy
# rewrites itself (replacing any symlink), so the repo copy is just a seed.
function seedfile() {
  sourcef=$1
  destf=$2

  if [[ -e $destf || -L $destf ]]; then
    echo "$destf already exists, not seeding"
    return
  fi

  echo "seeding $destf from $sourcef"
  cp $sourcef $destf
}

function makelink() {
  sourcef=$1
  destf=$2

  if [[ -e $destf && ($(readlink $destf) == $sourcef) ]]; then
    echo "$destf is already linked to $sourcef"
    return
  fi

  if [[ -e $destf || -L $destf ]]; then
    # Never overwrite an earlier backup: that one holds the original file
    backup="$destf.myenvbak"
    if [[ -e $backup || -L $backup ]]; then
      backup="$backup.$(date +%s)"
    fi
    echo "backing up $destf to $backup"
    mv -T $destf "$backup"
  fi

  echo "creating link $sourcef $destf"
  ln -s $sourcef $destf
}

# Get OS:
#
os=""
case "$(uname -sr)" in

Darwin*)
  os='Mac'
  ;;

Linux*Microsoft*)
  os='WSL' # Windows Subsystem for Linux
  ;;

Linux*)
  os='Linux'
  ;;

CYGWIN* | MINGW* | MINGW32* | MSYS*)
  os='Windows'
  ;;

*)
  echo 'Other OS'
  ;;
esac

# Omarchy (Arch based) owns the bash, terminal, nvim, tmux and starship
# configuration and themes them dynamically. On Omarchy we layer on top of
# those rather than replacing them.
omarchy=false
if [[ -r /etc/os-release ]] && grep -qx 'ID=omarchy' /etc/os-release; then
  omarchy=true
  echo "Omarchy detected: keeping Omarchy managed bash/terminal/nvim/tmux/starship config"
fi

mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 $MYENV_HOME/dot_ssh/config

makelink $MYENV_HOME/bash_aliases ~/.bash_aliases

makelink $MYENV_HOME/dot_zshrc ~/.zshrc
makelink $MYENV_HOME/dot_p10k.zsh ~/.p10k.zsh
makelink $MYENV_HOME/dot_keybinding ~/.keybinding
makelink $MYENV_HOME/inputrc ~/.inputrc

if $omarchy; then
  # ~/.bashrc belongs to Omarchy (it sets up PATH, mise and its aliases).
  # Link ours alongside and source it from the end of Omarchy's file.
  makelink $MYENV_HOME/bashrc ~/.bashrc_myenv
  if ! grep -q 'bashrc_myenv' ~/.bashrc; then
    echo "adding my-enviroment hook to ~/.bashrc"
    cat >>~/.bashrc <<'HOOK'

# my-enviroment: layer on top of Omarchy, keeping Omarchy's prompt. ls stays
# GNU ls (not Omarchy's eza alias) so flags like ls -lrt work.
if [[ -r ~/.bashrc_myenv ]]; then
  _omarchy_ps1=$PS1 _omarchy_pc=$PROMPT_COMMAND
  source ~/.bashrc_myenv
  PS1=$_omarchy_ps1
  PROMPT_COMMAND="${_omarchy_pc:+$_omarchy_pc; }_bash_history_sync"
  unset _omarchy_ps1 _omarchy_pc
fi
HOOK
  fi
  # Migrate hooks written by earlier versions, which restored Omarchy's ls alias
  if grep -q '_omarchy_ls' ~/.bashrc; then
    echo "updating my-enviroment hook in ~/.bashrc (ls is GNU ls again)"
    sed -i \
      -e 's/ _omarchy_ls=\$(alias ls 2>\/dev\/null)//' \
      -e '/_omarchy_ls" \]\] && eval/d' \
      -e '/\[\[ -n \$_omarchy_ls \]\]/d' \
      -e 's/unset _omarchy_ps1 _omarchy_pc _omarchy_ls/unset _omarchy_ps1 _omarchy_pc/' \
      -e "s/keeping Omarchy's prompt and ls/keeping Omarchy's prompt, ls stays GNU ls/" \
      ~/.bashrc
  fi
else
  makelink $MYENV_HOME/tmux.conf ~/.tmux.conf
  makelink $MYENV_HOME/bashrc ~/.bashrc
  makelink $MYENV_HOME/bash_profile ~/.bash_profile
fi

makelink $MYENV_HOME/dot_ssh/config ~/.ssh/config
makelink $MYENV_HOME/dot_gitconfig ~/.gitconfig

makelink $MYENV_HOME/dot_tmuxp ~/.tmuxp

mkdir -p ~/.config/tmuxp/
makelink $MYENV_HOME/timew.yml ~/.config/tmuxp/timew.yml
makelink $MYENV_HOME/config/tmuxp/quake.yml ~/.config/tmuxp/quake.yml

# Per-machine ssh hosts (not tracked) go in ~/.ssh/config.d/, which
# dot_ssh/config includes. tmuxp/quake.yml expects a "quake" alias there.
mkdir -p ~/.ssh/config.d
chmod 700 ~/.ssh/config.d
if [[ $(ssh -G quake 2>/dev/null | awk '$1 == "hostname" { print $2 }') == quake ]]; then
  echo "NOTE: no 'quake' ssh alias yet - add a Host quake entry in ~/.ssh/config.d/quake"
fi

# VIM
makelink $MYENV_HOME/vim/vim ~/.vim
makelink $MYENV_HOME/vim/vimrc ~/.vimrc
makelink $MYENV_HOME/vim/vim/snippets/ ~/.snippets

if ! $omarchy; then
  makelink $MYENV_HOME/config/ghostty/ ~/.config/ghostty
  makelink $MYENV_HOME/config/alacritty/ ~/.config/alacritty
  if [[ $os = "Linux" ]]; then
    makelink ~/.config/alacritty/linux.toml ~/.config/alacritty/os.toml
  fi

  # NeoVIM
  # If nvim is a plain directory, then rename before we create a symlink to
  # our new version
  if test -d ~/.config/nvim; then
    if test -L ~/.config/nvim; then
      echo "nvim is already a symlink to a directory, not changing"
    else
      echo "nvim is just a plain directory, renaming"
      mv ~/.config/nvim ~/.config/nvim-before-lazyvim-changes
    fi
  fi
  makelink $MYENV_HOME/nvim ~/.config/nvim

  # Starship Prompt
  makelink $MYENV_HOME/config/starship.toml ~/.config/starship.toml
fi

# Email
makelink $MYENV_HOME/mutt ~/.mutt
makelink $MYENV_HOME/muttrc ~/.muttrc

# Fish (optional shell - harmless if fish isn't installed)
mkdir -p ~/.config/fish
makelink $MYENV_HOME/config/fish/config.fish ~/.config/fish/config.fish
makelink $MYENV_HOME/config/fish/fish_plugins ~/.config/fish/fish_plugins

mkdir -p ~/.config/fish/functions
for i in $(ls $MYENV_HOME/config/fish/functions); do
  makelink $MYENV_HOME/config/fish/functions/$i ~/.config/fish/functions/$i
done

# Omarchy shell (bar, dock, idle) and Hyprland keybindings.
# monitors.lua is deliberately not linked: it depends on what is plugged in.
# Saved layouts live in config/hypr/monitors/; apply one with
# "monitor-setup restore".
if $omarchy; then
  mkdir -p ~/.config/omarchy ~/.config/hypr ~/.config/kitty ~/.config/environment.d
  # Text size: Omarchy rewrites this file when the size is changed
  seedfile $MYENV_HOME/config/omarchy/shell.toml ~/.config/omarchy/shell.toml
  makelink $MYENV_HOME/config/kitty/kitty.conf ~/.config/kitty/kitty.conf
  makelink $MYENV_HOME/config/xdg-terminals.list ~/.config/xdg-terminals.list
  # Compose key shortcuts (includes Omarchy's emoji sequences)
  makelink $MYENV_HOME/dot_XCompose ~/.XCompose
  # ssh-agent as a systemd user socket, with SSH_AUTH_SOCK set for the session
  makelink $MYENV_HOME/config/environment.d/90-ssh-agent.conf ~/.config/environment.d/90-ssh-agent.conf
  if systemctl --user cat ssh-agent.socket &>/dev/null; then
    systemctl --user enable --now ssh-agent.socket
  fi
  makelink $MYENV_HOME/config/omarchy/shell.json ~/.config/omarchy/shell.json
  makelink $MYENV_HOME/config/hypr/bindings.lua ~/.config/hypr/bindings.lua
  # Electron apps (Element etc.): use gnome-keyring and native Wayland
  makelink $MYENV_HOME/config/electron-flags.conf ~/.config/electron-flags.conf
fi

# Claude Code skills
mkdir -p ~/.claude/skills
makelink $MYENV_HOME/claude/skills/tidy ~/.claude/skills/tidy

# link bin files
mkdir -p ~/bin
bin_links=(
  myip:myip
  dms_to_decimal:dms_to_decimal
  tmux-vim-select-pane:tmux-vim-select-pane
  tmux-nest:tmux-nest
  worldclock:worldclock
  mtu_size.sh:mtu_size
  wait-for-host.sh:wait-for-host
  stay-connected:stay-connected
  stay-connected-tmux:stay-connected-tmux
  stay-connected-bs-tmux:stay-connected-bs-tmux
  monitor-setup:monitor-setup
)
for pair in "${bin_links[@]}"; do
  makelink $MYENV_HOME/bin/${pair%%:*} ~/bin/${pair##*:}
done

# Geometery theme
theme_dir=$MYENV_HOME/zsh/custom/
geometry_theme_dir=$theme_dir/geometry

# Remove old custom/themes if it exists
if [ -d $theme_dir/themes ]; then
  rm -rf $theme_dir/themes
fi

# If we have a migration guide then force a pull.
if [ -f $geometry_theme_dir/migration-guide.md ]; then
  rm -rf $geometry_theme_dir
fi

if [ -d $geometry_theme_dir ]; then
  cd $geometry_theme_dir
  git pull origin
  git submodule update --init --recursive
else
  cd $theme_dir
  git clone https://github.com/fribmendes/geometry.git geometry
  cd geometry
  git submodule update --init --recursive
fi

# Powerline10k Theme
p10k_dir=$MYENV_HOME/zsh/custom/themes/powerlevel10k
if [ -d ${p10k_dir} ]; then
  echo "Upodating p10k repo"
  cd $p10k_dir
  git pull origin master
else
  echo "Setting up p10k repo"
  git clone https://github.com/romkatv/powerlevel10k.git ${p10k_dir}
fi

# Time Warrior zsh plugins
zsh_timew_dir=$MYENV_HOME/zsh/custom/plugins/timewarrior

if [ -d ${zsh_timew_dir} ]; then
  echo "Updating zsh timewarrior plugin"
  cd $zsh_timew_dir
  git pull origin master
else
  echo "Installing zsh timewarrior plugin"
  git clone https://github.com/svenXY/timewarrior ${zsh_timew_dir}
fi

# Do an initial remote update which populates .git/FETCH_HEAD and prevents errors
pushd $MYENV_HOME >/dev/null
git remote update
popd >/dev/null

## Clone the vim-solarized8 repo and checkout neovim
#if [ -d ~/.vim/pack/themes/start/solarized8 ]; then
#	cd ~/.vim/pack/themes/start/solarized8
#	git checkout neovim
#	git pull
#else
#	git clone https://github.com/lifepillar/vim-solarized8.git \
#		~/.vim/pack/themes/start/solarized8
#	cd ~/.vim/pack/themes/start/solarized8
#	git checkout neovim
#fi

# Are we is WSL?
if [ -f /proc/sys/kernel/isrelease ] && grep -Fqi Microsoft /proc/sys/kernel/osrelease; then
  echo "WSL Detected"
  pushd /mnt/c
  APPDATA=$(wslpath -au "$(cmd.exe /c 'echo %APPDATA%')")
  popd

  roaming=$APPDATA
  locald=$APPDATA/../Local
  nvimd=$locald/nvim
  if [ -d $roaming/wsltty ]; then
    echo "wsltty dir already exists - not copying over"
  else
    cp -R $MYENV_HOME/wsl/wsltty $roaming
  fi

  # This section, is linking in for Windows version of running vim.
  # Will need a revisit for Lazyvim changes
  if [ -d $nvimd ]; then
    echo "nvim dir already exists - not copying over"
  else
    mkdir -p $nvimd/autoload
    cp $MYENV_HOME/vim/init.vim $nvimd/init.vim
    cp -R $MYENV_HOME/vim/vim/snippets $nvimd/
    curl -fLo $nvimd/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    sed -i "s@~/.vim/autoload/plug.vim@$nvimd/autoload/plug.vim@" $nvimd/init.vim
  fi
fi

#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function makelink() {
	sourcef=$1
	destf=$2

	if [[ -e $destf && ($(readlink $destf) == $sourcef) ]]; then
		echo "$destf is already linked to $sourcef"
		return
	fi

	if [[ -e $destf || -L $destf ]]; then
		echo "backing up $destf"
		mv $destf "$destf.myenvbak"
	fi

	echo "creating link $sourcef $destf"
	ln -s $sourcef $destf
}

chmod 600 ~/projects/my-enviroment/dot_ssh/config

makelink ~/projects/my-enviroment/bash_aliases ~/.bash_aliases

makelink ~/projects/my-enviroment/tmux.conf ~/.tmux.conf
makelink ~/projects/my-enviroment/bashrc ~/.bashrc
makelink ~/projects/my-enviroment/bash_profile ~/.bash_profile
makelink ~/projects/my-enviroment/dot_zshrc ~/.zshrc
makelink ~/projects/my-enviroment/dot_p10k.zsh ~/.zshrc
makelink ~/projects/my-enviroment/dot_keybinding ~/.keybinding
makelink ~/projects/my-enviroment/inputrc ~/.inputrc

makelink ~/projects/my-enviroment/dot_ssh/config ~/.ssh/config
makelink ~/projects/my-enviroment/dot_gitconfig ~/.gitconfig

makelink ~/projects/my-enviroment/dot_tmuxp ~/.tmuxp

# VIM
makelink ~/projects/my-enviroment/vim/vim ~/.vim
makelink ~/projects/my-enviroment/vim/vimrc ~/.vimrc

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
makelink ~/projects/my-enviroment/nvim ~/.config/nvim

# Email
makelink ~/projects/my-enviroment/mutt ~/.mutt
makelink ~/projects/my-enviroment/muttrc ~/.muttrc

# link bin files
mkdir -p ~/bin
makelink ~/projects/my-enviroment/bin/myip ~/bin/myip
makelink ~/projects/my-enviroment/bin/tmux-vim-select-pane ~/bin/tmux-vim-select-pane

makelink ~/projects/my-enviroment/bin/go ~/bin/go
makelink ~/projects/my-enviroment/bin/tmux-nest ~/bin/tmux-nest
makelink ~/projects/my-enviroment/bin/worldclock ~/bin/worldclock
makelink ~/projects/my-enviroment/bin/mtu_size.sh ~/bin/mtu_size

# Geometery theme
theme_dir=$HOME/projects/my-enviroment/zsh/custom/
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
p10k_dir=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
if [ -d ${p10k_dir} ]; then
	echo "Upodating p10k repo"
	cd $p10k_dir
	git pull origin master
else
	echo "Setting up p10k repo"
	git clone https://github.com/romkatv/powerlevel10k.git ${p10k_dir}
fi

if [ -d ~/.tmux/plugins/tpm ]; then
	cd ~/.tmux/plugins/tpm
	git pull origin master
else
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Do an initial remote update which populates .git/FETCH_HEAD and prevents errors
pushd ~/projects/my-enviroment >/dev/null
git remote update
popd >/dev/null

## Clone the vim-solarized8 repo and checkout neovim
if [ -d ~/.vim/pack/themes/start/solarized8 ]; then
	cd ~/.vim/pack/themes/start/solarized8
	git checkout neovim
	git pull
else
	git clone https://github.com/lifepillar/vim-solarized8.git \
		~/.vim/pack/themes/start/solarized8
	cd ~/.vim/pack/themes/start/solarized8
	git checkout neovim
fi

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
		cp -R ~/projects/my-enviroment/wsl/wsltty $roaming
	fi

	# This section, is linking in for Windows version of running vim.
	# Will need a revisit for Lazyvim changes
	if [ -d $nvimd ]; then
		echo "nvim dir already exists - not copying over"
	else
		mkdir -p $nvimd/autoload
		cp ~/projects/my-enviroment/vim/init.vim $nvimd/init.vim
		cp -R ~/projects/my-enviroment/vim/vim/snippets $nvimd/
		curl -fLo $nvimd/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		sed -i "s@~/.vim/autoload/plug.vim@$nvimd/autoload/plug.vim@" $nvimd/init.vim
	fi

fi

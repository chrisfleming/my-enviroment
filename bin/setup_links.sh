#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


function makelink() {
   sourcef=$1
   destf=$2

   if [[ -e $destf && (`readlink $destf` == $sourcef) ]]; then
       echo "$destf is already linked to $sourcef"
       return
   fi

   if [[ -e $destf || -h $destf ]]; then
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
makelink ~/projects/my-enviroment/dot_keybinding ~/.keybinding
makelink ~/projects/my-enviroment/inputrc ~/.inputrc

makelink ~/projects/my-enviroment/dot_ssh/config ~/.ssh/config
makelink ~/projects/my-enviroment/dot_gitconfig ~/.gitconfig

makelink ~/projects/my-enviroment/dot_tmuxp ~/.tmuxp

# VIM
makelink ~/projects/my-enviroment/vim/vim ~/.vim
makelink ~/projects/my-enviroment/vim/vimrc ~/.vimrc

# NeoVIM
mkdir -p ~/.config/nvim/
makelink ~/projects/my-enviroment/vim/init.vim ~/.config/nvim/init.vim
makelink ~/projects/my-enviroment/vim/ginit.vim ~/.config/nvim/ginit.vim
makelink ~/.vim/snippets ~/.config/nvim/snippets

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

makelink  ~/projects/my-enviroment/mutt ~/.mutt
makelink ~/projects/my-enviroment/muttrc ~/.muttrc

# link bin files
mkdir -p ~/bin
makelink ~/projects/my-enviroment/bin/myip ~/bin/myip
makelink ~/projects/my-enviroment/bin/tmux-vim-select-pane ~/bin/tmux-vim-select-pane

makelink ~/projects/my-enviroment/bin/go ~/bin/go
makelink ~/projects/my-enviroment/bin/tmux-nest ~/bin/tmux-nest
makelink ~/projects/my-enviroment/bin/worldclock ~/bin/worldclock

theme_dir=$HOME/projects/my-enviroment/zsh/custom/
geometry_theme_dir=$theme_dir/geometry

# Remove old custom/themes if it exists
if [ -d $theme_dir/themes ]; then
	rm -rf $theme_dir/themes
fi

# If we have a migration guide then force a pull.
if [ -f $geometry_theme_dir/migration-guide.md ]; then
	rm -rf  $geometry_theme_dir
fi

set -x
if [ -d $geometry_theme_dir ]; then
	cd $geometry_theme_dir
	git pull origin
	git submodule update --init --recursive
else
	cd $theme_dir
	git clone https://github.com/fribmendes/geometry.git geometry
	cd  geometry
	git submodule update --init --recursive
fi

if [ -d ~/.tmux/plugins/tpm ]; then
	cd ~/.tmux/plugins/tpm
	git pull origin master
else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Do an initial remote update which populates .git/FETCH_HEAD and prevents errors
pushd ~/projects/my-enviroment >/dev/null
git remote  update
popd >/dev/null

# Are we is WSL?

if grep -Fq Microsoft /proc/sys/kernel/osrelease
then
	echo "WSL Detected"
	roaming=`wslpath -a $APPDATA`
	locald=`wslpath -a $APPDATA/../Local`
	nvimd=$locald/nvim
	if [ -d $roaming/wsltty ]; then
		echo "wsltty dir already exists - not copying over"
	else
		cp -R ~/projects/my-enviroment/wsl/wsltty $roaming
	fi
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

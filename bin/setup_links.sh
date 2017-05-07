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


makelink ~/projects/my-enviroment/bash_aliases ~/.bash_aliases

#ln -s ~/projects/my-enviroment/bash_aliases ~/.bash_aliases
#mv  ~/.bashrc  ~/.bashrc_orig
#mv ~/.bash_profile ~/.bash_profile
makelink ~/projects/my-enviroment/tmux.conf ~/.tmux.conf
makelink ~/projects/my-enviroment/bashrc ~/.bashrc
makelink ~/projects/my-enviroment/bash_profile ~/.bash_profile
makelink ~/projects/my-enviroment/dot_zshrc ~/.zshrc
makelink ~/projects/my-enviroment/inputrc ~/.inputrc
makelink ~/projects/my-enviroment/vim/vim ~/.vim
makelink ~/projects/my-enviroment/vim/vimrc ~/.vimrc

makelink  ~/projects/my-enviroment/mutt ~/.mutt
makelink ~/projects/my-enviroment/muttrc ~/.muttrc

makelink ~/projects/my-enviroment/bin/myip ~/bin/myip

theme_dir=$HOME/projects/my-enviroment/zsh/custom/themes/
geometry_theme_dir=$theme_dir/geometry.zsh-theme

if [ -d $geometry_theme_dir ]; then
	cd $geometry_theme_dir
	git pull origin master
else
	mkdir -p $theme_dir
	cd $theme_dir
	git clone https://github.com/fribmendes/geometry.git geometry.zsh-theme
fi

# Do an initial remote update which populates .git/FETCH_HEAD and prevents errors
pushd ~/projects/my-enviroment >/dev/null
git remote  update
popd >/dev/null


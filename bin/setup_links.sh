ln -s ~/projects/my-enviroment/bash_aliases ~/.bash_aliases
mv  ~/.bashrc  ~/.bashrc_orig
mv ~/.bash_profile ~/.bash_profile
ln -s ~/projects/my-enviroment/tmux.conf ~/.tmux.conf
ln -s ~/projects/my-enviroment/bashrc ~/.bashrc
ln -s ~/projects/my-enviroment/bash_profile ~/.bash_profile
ln -s ~/projects/my-enviroment/inputrc ~/.inputrc
ln -s ~/projects/my-enviroment/vim/vim ~/.vim
ln -s ~/projects/my-enviroment/vim/vimrc ~/.vimrc

ln -s  ~/projects/my-enviroment/mutt ~/.mutt
ln -s ~/projects/my-enviroment/muttrc ~/.muttrc

cd ~/projects/my-enviroment/


# Do an initial remote update which populates .git/FETCH_HEAD and prevents errors
pushd ~/projects/my-enviroment
git remote  update
popd


ln -s ~/projects/my-enviroment/bash_aliases ~/.bash_aliases
mv  ~/.bashrc  ~/.bashrc_orig
ln -s ~/projects/my-enviroment/bash_profile ~/.bashrc
ln -s ~/projects/my-enviroment/vim/vim ~/.vim
ln -s ~/projects/my-enviroment/vim/vimrc ~/.vimrc

# Do an initial remote update which populates .git/FETCH_HEAD and prevents errors
pushd ~/projects/my-enviroment
git remote  update
popd


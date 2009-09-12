#!/bin/sh

if [ -e ~/.vim ]; then
    echo "WARNING: pls backup your ~/.vim and \n rm -rf .vim "
    exit
fi

if [ -e ~/.vimrc ]; then
    echo "WARNING: pls backup your ~/.vimrc and \n rm ~/.vimrc "
    exit
fi

cd ~ && git clone git://github.com/jimjin/vimfiles.git .vim
cd ~/.vim && git submodule init
cd ~/.vim && git submodule update

echo source ~/.vim/vimrc > ~/.vimrc
echo source ~/.vim/agi-vimrc >> ~/.vimrc

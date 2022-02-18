
#!/bin/bash

# This will setup a new Ubuntu machine 

# first make the setupDotFile an exe
chmod +x setupDotfiles.sh

# make sure we are in home folder
cd ~

# update system
sudo apt update 

# confirm for upgrade
sudo apt upgrade

# install zsh and Micro
echo "Installing zsh and micro"
sudo apt install zsh micro

# install exa - replacement for ls
# for Ubuntu 20.04 we need to install from source for that we need Rust Env Cargo
echo "Installing cargo to install exa"
sudo apt install cargo
sudo cargo install exa
echo "exa installed. This will replace 'ls' command"

# change shell to zsh
echo "Changing shell to zsh"
chsh -s $(which zsh)
# Create a temporary file to tell the script that step 1 done next time this setup is run
touch $ZSH_INSTALLED
echo "Shell changed to zsh. Please logout and log back in"






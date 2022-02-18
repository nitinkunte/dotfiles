
#!/bin/bash

# This will setup a new Ubuntu machine 

# Check if we have completed first few tasks
ZSH_INSTALLED=.zsh_installed

if [ ! -f "$ZSH_INSTALLED" ]; then

    # update system
    sudo apt update 

    # confirm for upgrade
    sudo apt upgrade

    # install zsh and Micro
    echo "Installing zsh and micro"
    sudo apt install zsh micro

    # change shell to zsh
    echo "Changing shell to zsh"
    chsh -s $(which zsh)
    # Create a temporary file to tell the script that step 1 done next time this setup is run
    touch $ZSH_INSTALLED
    echo "Shell changed to zsh. Please logout and log back in"
else
    # make sure we are in home folder
    cd ~
    # install exa - replacement for ls
    # for Ubuntu 20.04 we need to install from source for that we need Rust Env Cargo
    echo "Installing cargo to install exa"
    sudo apt install cargo
    sudo cargo install exa
    echo "exa installed. This will replace 'ls' command"

    # install oh-my-zsh
    echo "Installing Oh my zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # install oh-my-zsh additional plugins
    echo "Installing additional plugins 'zsh-completions' & 'zsh-autosuggestions' "
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # copy our files
    echo "Setting up our config files"
    #  create dir if it does not already exist
    mkdir -p .myconfigs
    cp .aliases ~/.myconfigs/.
    cp .functions ~/.myconfigs/.

    # ask if we are okay replacing the zshrc file
    read -p "Do you want to replace the '.zshrc' file? (y / n): " REPLACE_ZSHRC

    if [ $REPLACE_ZSHRC == "y" ] 
    then
        NEW_NAME="~/.myconfigs/.zshrc_$(date '+%Y%m%d-%H%M%S')"
        mv ~/.zshrc $NEW_NAME
        cp .zshrc ~/.zshrc
    else
        echo "You will need to manually replace the '.zshrc' file with the one from our folder"
    fi
fi





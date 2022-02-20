#!/bin/bash
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/nitinkunte/dotfiles/main/setupUbuntu.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/nitinkunte/dotfiles/main/tools/setupUbuntu.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/nitinkunte/dotfiles/main/tools/setupUbuntu.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/nitinkunte/dotfiles/tools/setupUbuntu.sh
#   sh setupUbuntu.sh
#

# mnk_fileExists file
#
# Makes sure that the given regular file exists. Thus, is not a directory or device file.
#
# Example:
# response=$(mnk_fileExists "file-to-be-check")
#    0 = false; else true
#
function mnk_fileExists {
    local file=${1}
    if [[ ! -f "${file}" ]]; then
        echo "1"
    else
        echo "0"
    fi
}

# mnk_fileDoesNotExists file
#
# Makes sure that the given file does not exist.
#
# Example:
# response=$(mnk_fileDoesNotExists "file-to-be-written-in-a-moment")
#    0 = false; else true
#
function mnk_fileDoesNotExists {
    local file=${1}
    if [[ -e "${file}" ]]; then
        echo "1"
    else
        echo "0"
    fi
}

# display error in red
mnk_error()
{
    local whatToEcho=$1
    # red
    echo "`tput setaf 1`$whatToEcho`tput sgr0`"
}
# display warning in magenta
mnk_warning()
{
    local whatToEcho=$1
    # magenta
    echo "`tput setaf 5`$whatToEcho`tput sgr0`"
}
# display information in blue
mnk_info()
{
    local whatToEcho=$1
    # blue
    echo "`tput setaf 4`$whatToEcho`tput sgr0`"
}

mnk_CommandExists() {
  command -v "$@" >/dev/null 2>&1
}

mnk_setup_ubuntu(){

    # make sure we are in home folder
    cd $HOME

    # update system
    sudo apt update 

    # confirm for upgrade
    sudo apt upgrade

    # install zsh and Micro
    mnk_info "Installing zsh and micro"
    sudo apt install zsh micro

    # install exa - replacement for ls
    ubuntu_release=$(lsb_release -cs)
    
    mnk_info "Installing exa"
    # Run code specifc to Ubuntu 20.04 = focal
    if [ $ubuntu_release == "focal" ] 
    then
        # for Ubuntu 20.04 we need to install from source for that we need Rust Env Cargo
        sudo apt install -y unzip
        # Get the latest version tag of exa release and assign it to variable.
        EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
        # Download zip archive from releases page of the exa repository.
        curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
        # Extract executable file from a ZIP archive:
        sudo unzip -q exa.zip bin/exa -d /usr/local
        # Remove the ZIP archive as it is no longer needed
        rm -rf exa.zip
    else
        sudo apt install exa
    fi

    mnk_info "exa installed. This will replace 'ls' command"

    if ! mnk_CommandExists zsh; then
        mnk_error "Something went wrong. zsh is not installed. Please try again..."
        exit 1
    fi
    # change shell to zsh
    echo "Changing shell to zsh"
    sudo -u $(logname) chsh -s $(which zsh)

    echo "Shell changed to zsh. Please logout and log back in"
}

# call our main function to run the script
mnk_setup_ubuntu







#!/bin/bash

# This will setup a oh my zsh and our dot files 

OUR_DIR=~/.myconfigs

# install oh-my-zsh
echo "Installing Oh my zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install oh-my-zsh additional plugins
echo "Installing additional plugins 'zsh-completions' & 'zsh-autosuggestions' "
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# copy our files
echo "Setting up our config files"
#  create dir if it does not already exist
mkdir -p $OUR_DIR
cp .aliases $OUR_DIR/.
cp .functions $OUR_DIR/.

# ask if we are okay replacing the zshrc file
read -p "Do you want to replace the '.zshrc' file? (y / n): " REPLACE_ZSHRC

if [ $REPLACE_ZSHRC == "y" ] 
then
    NEW_NAME="$OUR_DIR/.zshrc_$(date '+%Y%m%d-%H%M%S')"
    mv ~/.zshrc $NEW_NAME
    cp .zshrc ~/.zshrc
else
    echo "You will need to manually replace the '.zshrc' file with the one from our folder"
fi






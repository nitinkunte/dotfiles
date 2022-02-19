#!/bin/bash

# BEGIN: Read functions from helper_functions.
MNK_HELPER_FUNCTIONS="helper_functions"
if [[ ! -f "${MNK_HELPER_FUNCTIONS}" ]]; then
  echo "Required file does not exist: ${MNK_HELPER_FUNCTIONS}"
  exit 1
fi

# source our helper functions
. "${MNK_HELPER_FUNCTIONS}"

# END: Read functions from helper_functions.

# initialize 
mnk_initialize

# ------ GLOBAL VARIABLES START ------------------
USER=${USER:-$(id -u -n)}
REPO=https://github.com/nitinkunte/dotfiles.git
MY_CONFIG_DIR=$HOME/.myconfigs
# ------ GLOBAL VARIABLES END ------------------

mnk_info "Cloning dot files from github"
# check if git is installed
mnk_CommandExists git || {
    mnk_error "git is not installed. Please install git and try again"
    exit 1
}

# Create .myconfigs folder
echo "Creating $MY_CONFIG_DIR folder"
mkdir -p $MY_CONFIG_DIR

echo "Cloning our repo to $MY_CONFIG_DIR"
cd $MY_CONFIG_DIR
git clone --bare $REPO


mnk_echo "Color yellow" yellow

mnk_info "This is just FYI"

mnk_warning "This is a warning"

mnk_error "Error encountered"

#mnk_continue 
response=$(mnk_continue)
echo "return value is = $response"
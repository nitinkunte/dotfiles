#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/nitinkunte/dotfiles/main/setupDotfiles.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/nitinkunte/dotfiles/main/tools/setupDotfiles.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/nitinkunte/dotfiles/main/tools/setupDotfiles.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/nitinkunte/dotfiles/tools/setupDotfiles.sh
#   sh setupDotfiles.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Oh My Zsh repository:
#   ZSH=~/.zsh sh setupDotfiles.sh
#
# Respects the following environment variables:
#   MYDOTFILES - path to the Oh My Zsh repository folder (default: $HOME/.myconfigs)
#   REPO       - name of the GitHub repo to install from (default: nitinkunte/dotfiles)
#   REMOTE     - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH     - branch to check out immediately after install (default: main)
#
# Other options:
#   KEEP_ZSHRC - 'yes' means the installer will not replace an existing .zshrc (default: no)
#
# You can also pass some arguments to the install script to set some these options:
#   --keep-zshrc: sets KEEP_ZSHRC to 'yes'
# For example:
#   sh setupDotfiles.sh --keep-zshrc
# or:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/nitinkunte/dotfiles/main/tools/setupDotfiles.sh)" "" --keep-zshrc
#

# Exit our script immediately if there are errors
set -e


# ------ GLOBAL VARIABLES START ------------------
#
USER=${USER:-$(id -u -n)}
REPO=${REPO:-nitinkunte/dotfiles}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-main}
MY_CONFIG_DIR=$HOME/.myconfigs
KEEP_ZSHRC=${KEEP_ZSHRC:-no}
#
# ------ GLOBAL VARIABLES END ------------------

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

mnk_setup_ohmyzsh(){
    # install oh-my-zsh
    mnk_info "Installing Oh my zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # install oh-my-zsh additional plugins
    mnk_info "Installing additional plugins 'zsh-completions' & 'zsh-autosuggestions' "
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo
}

mnk_setup_dotfiles(){
    # Prevent the cloned repository from having insecure permissions. Failing to do
    # so causes compinit() calls to fail with "command not found: compdef" errors
    # for users with insecure umasks (e.g., "002", allowing group writability). Note
    # that this will be ignored under Cygwin by default, as Windows ACLs take
    # precedence over umasks except for filesystems mounted with option "noacl".
    umask g-w,o-w

    mnk_info "Cloning our dotfiles"

    mnk_CommandExists git || {
        mnk_error "git is not installed"
        exit 1
    }

    mnk_info "Creating place for our dotfiles"

     # Manual clone with git config options to support git < v1.7.2
    git init "$MY_CONFIG_DIR" && cd "$MY_CONFIG_DIR" \
    && git config core.eol lf \
    && git config core.autocrlf false \
    && git config fsck.zeroPaddedFilemode ignore \
    && git config fetch.fsck.zeroPaddedFilemode ignore \
    && git config receive.fsck.zeroPaddedFilemode ignore \
    && git config oh-my-zsh.remote origin \
    && git config oh-my-zsh.branch "$BRANCH" \
    && git remote add origin "$REMOTE" \
    && git fetch --depth=1 origin \
    && git checkout -b "$BRANCH" "origin/$BRANCH" || {
        rm -rf "$MY_CONFIG_DIR"
        mnk_error "git clone of our dotfiles repo failed"
        exit 1
    }
    echo
}

mnk_setup_zshrc() {
    # Keep most recent old .zshrc at .zshrc.pre-dotfiles, and older ones
    # with datestamp of installation that moved them aside, so we never actually
    # destroy a user's original zshrc
    mnk_info "Looking for existing zsh config..."

    # Must use this exact name so uninstall.sh can find it
    OLD_ZSHRC=~/.zshrc.pre-dotfiles
    if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
        # Skip this if the user doesn't want to replace an existing .zshrc
        if [ "$KEEP_ZSHRC" = yes ]; then
            mnk_info "Found ~/.zshrc. Will not replace as per your request!"
            return
        fi
        if [ -e "$OLD_ZSHRC" ]; then
            OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
            mnk_warning "Found old ~/.zshrc.pre-dotfiles"
            mnk_info "Backing up to ${OLD_OLD_ZSHRC}"
            mv "$OLD_ZSHRC" "${OLD_OLD_ZSHRC}"
        fi
        mnk_warning "Found old ~/.zshrc"
        mnk_info "Backing up to ${OLD_ZSHRC}"
        mv ~/.zshrc "$OLD_ZSHRC"
    fi
    echo
    mnk_info "Replacing existing ~/.zshrc with our template."

    mv -f $MY_CONFIG_DIR/.zshrc ~/.zshrc

    echo
}

mnk_print_success(){
    mnk_info "Installed dotfiles successfully..."
}

mnk_main() {

    # Parse arguments
    while [ $# -gt 0 ]; do
        case $1 in
            # --unattended) RUNZSH=no; CHSH=no ;;
            # --skip-chsh) CHSH=no ;;
            --keep-zshrc) KEEP_ZSHRC=yes ;;
        esac
        shift
    done

    if ! mnk_CommandExists zsh; then
        mnk_error "zsh is not installed. Please install zsh and then retry."
        exit 1
    fi

    # check if Oh My Zsh is already installed. If not, install it.
    local response=$(mnk_fileDoesNotExists "~/.oh-my-zsh/oh-my-zsh.sh")
    if [ $response == "1"]; then
        mnk_setup_ohmyzsh
    else
        echo
        mnk_info "Oh My Zsh is already installed. Skipping that part..."
    fi

    mnk_setup_dotfiles
    mnk_setup_zshrc

    eval "source ~/.zshrc"

    mnk_print_success
  
}

mnk_main "$@"
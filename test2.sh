

# ------ GLOBAL VARIABLES START ------------------
#
USER=${USER:-$(id -u -n)}
REPO=${REPO:-nitinkunte/dotfiles}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}
MY_CONFIG_DIR=$HOME/Downloads/.myconfigs
KEEP_ZSHRC=${KEEP_ZSHRC:-no}
#
# ------ GLOBAL VARIABLES END ------------------

# display error in red
mnk_error()
{
    whatToEcho=$1
    # red
    echo "`tput setaf 1`$whatToEcho`tput sgr0`"
}
# display warning in magenta
mnk_warning()
{
    whatToEcho=$1
    # magenta
    echo "`tput setaf 5`$whatToEcho`tput sgr0`"
}
# display information in blue
mnk_info()
{
    whatToEcho=$1
    # blue
    echo "`tput setaf 4`$whatToEcho`tput sgr0`"
}
mnk_CommandExists() {
  command -v "$@" >/dev/null 2>&1
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
    fmt_error "git clone of our dotfiles repo failed"
    exit 1
    }

    echo
}

mnk_setup_dotfiles
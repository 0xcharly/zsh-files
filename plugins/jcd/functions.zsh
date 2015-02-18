# Helper function to test whether a given directory exists before adding it to
# the PATH.
function f() {
    if [ -z "$2" ]; then
        find . -name "*$1*"
    else
        find "$1" -name "*$2*"
    fi
}

# Fix autoenv conflict with oh-my-git
function cd() {
    builtin cd $*
}

# Get IP
function ip-addr() {
    wget -qO- http://ipecho.net/plain
    echo
}

# Time ZSH startup
function zsh-time() {
    time zsh -i -c exit
}

# User info
export FULLNAME="Jean-Charles Delay"
export EMAIL="delay@adacore.com"
export EDITOR=vi

# Disallow automatic window renaming in tmux
export DISABLE_AUTO_TITLE=true
export PYTHONSTARTUP="$HOME/.pythonrc"

# Disallow Oh-My-ZSH auto updates
export DISABLE_AUTO_UPDATE=true

# GPG
GPG_TTY=$(tty)
export GPG_TTY

# MAVEN
export M2_REPO="$HOME/.m2/repository"

# Java
if [ "x`uname -s`" = "xDarwin" ]; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Locales
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG='en_US.UTF-8'

# Term
case `uname -s` in
    CYGWIN*)
        export TERM=xterm-256color
        ;;
    *)
        if [[ $TMUX = '' ]]; then
            export TERM=xterm-256color-italic
        else
            export TERM=screen-256color-italic
        fi
        ;;
esac

# Colored less

# F - Quit if one screen
# X - Disables sending the termcap initialization and deinitialization
# R - Raw color codes in output (don't remove color codes)
# S - Don't wrap lines, just cut off too long text
# M - Long prompts ("Line X of Y")
# ~ - Don't show those weird ~ symbols on lines after EOF
# g - Highlight results when searching with slash key (/)
# I - Case insensitive search
# s - Squeeze empty lines to one
# w - Highlight first line after PgDn

export LESS="-FXRSM~gIsw"

# Colored Man pages
export LESS_TERMCAP_mb=$'\E[01;31m'         # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'         # begin bold
export LESS_TERMCAP_me=$'\E[0m'             # end mode
export LESS_TERMCAP_se=$'\E[0m'             # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'      # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'             # end underline
export LESS_TERMCAP_us=$'\E[01;32m'         # begin underline

# SVN & Git SSH config
export SVN_SSH="ssh -l $USER -q"
# export GIT_SSH="ssh -l $USER -q"

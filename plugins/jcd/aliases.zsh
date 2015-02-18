# SSH aliases
alias ssh='TERM=xterm-256color ssh'
alias ssr='ssh -l root'
alias ssg='ssh -l gnatmail'
alias ck='ssh ssh.gnat.com'
alias cc='ssh ssh.eu.adacore.com'

# Applications aliases
alias fix='open -a "MacPAR deLuxe"'  # Open a .par2 file

alias m='make -s'
alias tmux='tmux -2'
alias tree='tree -C'

# Bugtool aliases
alias bt='bugtool'
alias tns='clear && $HOME/lstn'
alias follow='bugtool subscribe'

function bt-mail {
    if [ $# != 1 ]; then
        echo 'usage: btmail <TN>' 2>&1
        return 1
    fi

    mutt -Rf `bugtool info $@ |head -n1`/comment
    return $?
}

alias btm='bt-mail'

# Platform-specific aliases
case `uname -s` in
  AIX|SunOS|HP-UX|OSF1)
    alias ls='ls -F'
    alias l='ls -F'
    ;;
  FreeBSD|Darwin)
    alias ls='ls -F -G'
    alias l='ls -F -G -a -l'
    alias grep='grep --color=auto'
    ;;
  *)
    alias ls='ls -F --color'
    alias l='ls -alF --color'
    alias grep='grep -T --color=auto'
    ;;
esac

case `uname -s` in
    Darwin)
        alias finder='open -a Finder'
        alias ss='/System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine &'
        ;;
esac

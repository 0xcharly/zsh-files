alias ..='cd ..'        # Go up one directory
alias ...='cd ../..'    # Go up two directories
alias -- -="cd -"       # Go back

alias fix='open -a "MacPAR deLuxe"'  # Open a .par2 file

alias ssh='TERM=xterm-256color ssh'

alias ssr='ssh -l root'
alias ssg='ssh -l gnatmail'

alias m='make -s'
alias .git='git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles'

alias tmux='tmux -2'
alias tree='tree -C'
alias bt='bugtool'
alias tns='bugtool dir |grep "^....-... . delay"'
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

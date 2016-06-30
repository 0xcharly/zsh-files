alias ssh='TERM=xterm-256color ssh'
alias ssr='ssh -l root'
alias ssg='ssh -l gnatmail'
alias ct='ssh ssh.gnat.com'
alias cx='ssh xen2.gnat.com'
alias ch='ssh ssh.eu.adacore.com'
alias cm='ssh imap-eu.adacore.com'

alias tmux='tmux -2'
alias tree='tree -C'
alias vim-plugins-update='vim +PlugClean! +PlugInstall +PlugUpdate +qall'

alias today="date '+%Y%m%d'"
alias timestamp="date -u '+%Y-%m-%dT%H%M%SZ'"

function bt-mail {
    if [ $# != 1 ]; then
        echo 'usage: btmail <TN>' 2>&1
        return 1
    fi

    MUTT_FLAGS=""
    MUTT_FLAGS="$MUTT_FLAGS -e 'color index white default \"~O\"'"
    MUTT_FLAGS="$MUTT_FLAGS -e 'color index white default \"~N\"'"
    tn=$1; shift

    if type mutt-index-fmt > /dev/null 2>&1; then
        mutt \
            -e 'color index white default "~O"' \
            -e 'color index white default "~N"' \
            -e 'set index_format = "mutt-index-fmt %[%s] |"' \
            -f /reportd/gnatbugs/${tn:0:2}/$tn/comment $@
    else
        mutt \
            -e 'color index white default "~O"' \
            -e 'color index white default "~N"' \
            -f /reportd/gnatbugs/${tn:0:2}/$tn/comment $@
    fi

    return $?
}

alias bt='bugtool'
alias comment='bt-mail'

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
    Linux|Darwin)
        alias vi='vi -T "$TERM-italic"'
        alias vim='vim -T "$TERM-italic"'
        alias k='k -h'
        ;;
esac

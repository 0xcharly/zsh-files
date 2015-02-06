HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history

unsetopt APPEND_HISTORY
unsetopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_NO_STORE        # Do not store 'history' nor 'fc' commands
setopt NO_HIST_BEEP

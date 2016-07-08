# History configuration

HISTSIZE=8192
SAVEHIST=8192
HISTFILE=~/.history

setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_no_store        # Do not store 'history' nor 'fc' commands
setopt no_hist_beep

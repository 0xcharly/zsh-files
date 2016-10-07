SOURCE=${0%/*}
SHORT_HOST=`hostname |cut -d. -f1`

source $SOURCE/plugins/colored-ls/colored-ls.plugin.zsh

source $SOURCE/plugins/cygwin/cygwin.plugin.zsh

source $SOURCE/plugins/gerrit/gerrit.plugin.zsh

source $SOURCE/plugins/delay/aliases.zsh
source $SOURCE/plugins/delay/exports.zsh
source $SOURCE/plugins/delay/functions.zsh
source $SOURCE/plugins/delay/history.zsh
source $SOURCE/plugins/delay/options.zsh
source $SOURCE/plugins/delay/spectrum.zsh

if [ -f "$HOME/.customrc-$SHORT_HOST" ]; then
    source "$HOME/.customrc-$SHORT_HOST"
fi

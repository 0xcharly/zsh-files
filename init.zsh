SOURCE=${0%/*}
SHORT_HOST=`hostname |cut -d. -f1`

source $SOURCE/plugins/colored-ls/colored-ls.plugin.zsh

source $SOURCE/plugins/cygwin/cygwin.plugin.zsh

source $SOURCE/plugins/gerrit/gerrit.plugin.zsh

source $SOURCE/plugins/jcd/aliases.zsh
source $SOURCE/plugins/jcd/exports.zsh
source $SOURCE/plugins/jcd/functions.zsh
source $SOURCE/plugins/jcd/history.zsh
source $SOURCE/plugins/jcd/grep.zsh
source $SOURCE/plugins/jcd/options.zsh
source $SOURCE/plugins/jcd/spectrum.zsh

source $SOURCE/plugins/jcd/temp-functions.zsh

if [ -f "$HOME/.customrc-$SHORT_HOST" ]; then
    source "$HOME/.customrc-$SHORT_HOST"
fi

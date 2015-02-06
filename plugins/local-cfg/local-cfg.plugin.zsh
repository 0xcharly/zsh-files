SHORT_HOST=`hostname |cut -d. -f1`
if [ -f "$HOME/.customrc-$SHORT_HOST" ]; then
    source "$HOME/.customrc-$SHORT_HOST"
fi

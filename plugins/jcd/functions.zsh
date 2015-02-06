# Helper function to test whether a given directory exists before adding it to
# the PATH.

function _safe_export_path() {
  [ -d "$1" ] && export PATH="$1:$PATH"
}

function _safe_export_pythonpath() {
  [ -d "$1" ] && export PYTHONPATH="$1:$PYTHONPATH"
}

function f() {
    if [ -z "$2" ]; then
        find . -name "*$1*"
    else
        find "$1" -name "*$2*"
    fi
}

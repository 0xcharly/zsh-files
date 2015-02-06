# Helper function to test whether a given directory exists before adding it to
# the PATH.

function f() {
    if [ -z "$2" ]; then
        find . -name "*$1*"
    else
        find "$1" -name "*$2*"
    fi
}

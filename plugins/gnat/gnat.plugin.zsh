# GNAT sandbox

# Passes the arguments to echo.
function _GNAT_Info {
    echo "GNAT.env:" $@
}

# Passes the arguments to echo and redirects the output to the standard error
# stream.
function _GNAT_Warn {
    echo "GNAT.env:" $@ >&2
}

# Warn the user if $GNAT_SANDBOX is not set.
[ "$GNAT_SANDBOX" ] || _GNAT_Warn "\$GNAT_SANDBOX not set"

# Sandbox directories.
GNAT_SANDBOX_DISTFILES="$GNAT_SANDBOX/distfiles"
GNAT_SANDBOX_INSTALL_DIR="$GNAT_SANDBOX/local"

GITHUB_API_KEY='11333b34304bf6cec4b3c7e0dcf46cbdca0dc7a4'

# Checks whether the sandbox exist and is a directory.
# Returns 0 if the sandbox is valid, any other value otherwise.
function _GNAT_Ensure_Sandbox_Exists {
    if [ -d "$GNAT_SANDBOX" ]; then
        return 0
    fi

    return 1
}

# Creates a temporary directory.
# Returns the path to the new directory.
function _GNAT_Create_Tmp_Dir {
    case `uname` in
        Darwin) tmpdir=`mktemp -d -t wavefront` ;;
        *)      tmpdir=`mktemp -d` ;;
    esac

    echo $tmpdir
}

# Creates the sandbox.
# Displays a message if already exists and exits normally.
# Displays an error message if already exists and not a directory and exits with
# exit code 1.
function GNAT_Sandbox_Create {
    if [ -e "$GNAT_SANDBOX" ]; then
        if [ -d "$GNAT_SANDBOX" ]; then
            echo "\$GNAT_SANDBOX already exists, exiting."
            return 0
        fi

        echo "\$GNAT_SANDBOX is not a directory, aborting." >&2
        return 1
    fi

    mkdir -p "$GNAT_SANDBOX"
    mkdir -p "$GNAT_SANDBOX_DISTFILES"
    mkdir -p "$GNAT_SANDBOX_INSTALL_DIR"

    (
        # Exit on failure
        set -e

        tmpdir=$(_GNAT_Create_Tmp_Dir)

        # Bootstrap: install gnatpython
        curl -L https://api.github.com/repos/JcDelay/adacore-toolbox/tarball \
            -u "$GITHUB_API_KEY:x-oauth-basic" -o $tmpdir/adacore-toolbox.tar

        (
            cd $tmpdir
            tar xf adacore-toolbox.tar --strip-components 1
        ) || exit 1

        wavefront="$tmpdir/scripts/wavefront"

        # Find the file to download (resource ID)
        resource_id=$(
            python $wavefront list gnatpython \
                --auto-detect-platform --binaries-only --out-mode porcelain \
                |head -n 1 \
                |cut -d ' '  -f 2
        )

        # Download the file
        python $wavefront download $resource_id \
            --out-file $tmpdir/gnatpython.tar.gz

        (
            cd $GNAT_SANDBOX_INSTALL_DIR
            tar xf $tmpdir/gnatpython.tar.gz --strip-components 1
        ) || exit 1

        rm -rf $tmpdir
    ) || return 1

    _GNAT_Info "Sandbox created at: $GNAT_SANDBOX"
    _GNAT_Info "Use GNAT_Activate to activate the new environment."

    return 0
}

# Removes the sandbox, asking confirmation first, unless -f is specified.
# NoOp if the sandbox does not exist.
function GNAT_Sandbox_Erase {
    if ! _GNAT_Ensure_Sandbox_Exists; then
        echo "Nothing to remove, exiting."
        return 0
    fi

    force=false

    if [[ "$1" = "-f" || "$1" = "--force" ]]; then
        force=true
    fi

    if ! $force; then
        echo "Please confirm the TOTAL DELETION of the following directory:"
        echo "  $GNAT_SANDBOX"
        echo ""

        while true; do
            echo -n "Remove this directory? [y|n] "
            read yes_no

            case $yes_no in
                [Yy]|[Yy]es) break ;;
                [Nn]|[Nn]o) echo "Aborting." && return 1;;
                *) echo "Please answer yes or no.";;
            esac
        done
    fi

    rm -rf $GNAT_SANDBOX
    return 0
}

# Equivalent to
#   $ GNAT_Sandbox_Erase $@
#   $ GNAT_Sandbox_Create
function GNAT_Sandbox_Reset {
    (
        set -e

        GNAT_Sandbox_Erase "$@"
        GNAT_Sandbox_Create
    )

    return $?
}

# Activate the GNAT environment if available.
function GNAT_Activate {
    if ! _GNAT_Ensure_Sandbox_Exists; then
        echo "Sandbox does not exist (see GNAT_Sandbox_Create), exiting."
        return 1
    fi

    PATH="$GNAT_SANDBOX_INSTALL_DIR/bin:$PATH"
    GPR_PROJECT_PATH="$GNAT_SANDBOX_INSTALL_DIR/lib/gnat:$GPR_PROJECT_PATH"
    GPR_PROJECT_PATH="$GNAT_SANDBOX_INSTALL_DIR/share/gpr:$GPR_PROJECT_PATH"

    export PATH
    export GPR_PROJECT_PATH

    return 0
}

# Update the various python modules installed in the sandbox.
function GNAT_Update_Extensions {
    (
        GNAT_Activate || exit 1

        pip install https://github.com/lyda/misspell-check/archive/master.zip
        pip install https://github.com/JcDelay/PyCR/archive/master.zip

        tmpdir=$(_GNAT_Create_Tmp_Dir)

        # Bootstrap: install gnatpython
        curl -L https://api.github.com/repos/JcDelay/adacore-toolbox/zipball \
            -u "$GITHUB_API_KEY:x-oauth-basic" -o $tmpdir/adacore-toolbox.zip

        (
            cd $tmpdir
            pip install adacore-toolbox.zip
        ) || exit 1

        rm -rf $tmpdir
    )

    return $?
}

# Download the latest GNAT wavefront and install it in the sandbox.
function GNAT_Install_GNAT_Wavefront {
    (
        GNAT_Activate || exit 1

        tmpdir=$(_GNAT_Create_Tmp_Dir)

        cd $tmpdir

        # Find the file to download (resource ID)
        resource_id=$(
            wavefront list gnat \
                --auto-detect-platform --binaries-only --out-mode porcelain \
                |head -n 1 \
                |cut -d ' '  -f 2
        )

        # Download the file
        wavefront download $resource_id --out-file $tmpdir/gnat.tar.gz

        tar xf gnat.tar.gz --strip-components 1
        ./doinstall << EOF

$GNAT_SANDBOX_INSTALL_DIR
y
y
y
EOF

        rm -rf $tmpdir
    )

    return $?
}

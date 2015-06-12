# vim:ft=zsh

: ${omg_has_untracked_files_symbol:='?'}        #                ?    
: ${omg_has_adds_symbol:=''}
: ${omg_has_deletions_symbol:='-'}
: ${omg_has_cached_deletions_symbol:='-'}
: ${omg_has_modifications_symbol:=' '}
: ${omg_has_cached_modifications_symbol:=' '}
: ${omg_ready_to_commit_symbol:=' '}            #   →
: ${omg_is_on_a_tag_symbol:=''}                #   
: ${omg_needs_to_merge_symbol:='ᄉ'}
: ${omg_detached_symbol:=''}
: ${omg_can_fast_forward_symbol:=''}
: ${omg_has_diverged_symbol:=''}               #   
: ${omg_not_tracked_branch_symbol:=''}
: ${omg_rebase_tracking_branch_symbol:=''}     #   
: ${omg_merge_tracking_branch_symbol:=''}      #  
: ${omg_should_push_symbol:=''}                #    
: ${omg_has_stashes_symbol:=' '}
: ${omg_has_action_in_progress_symbol:=' '}     #                  

autoload -U colors && colors

PROMPT='%{%f%b%k%}$(build_prompt)%{%f%b%k%} '
RPROMPT='%{%f%b%k%}$(build_r_prompt)%{%f%b%k%}'

# Reset both PROMPT and RPROMTP. Use this on platform where rich prompt is not
# supported.
function reset_prompt() {
    PROMPT='$ '; export PROMPT
    unset RPROMPT
}

function _write() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    echo -n "%{$bg%}%{$fg%}$3"
}

function custom_build_prompt {
    local enabled=${1}
    local is_a_git_repo=${2}
    local retval=${3}

    # Is SSH session?
    SESSION_TYPE="local"
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        SESSION_TYPE="remote/ssh"
        # many other tests omitted
    else
        case $(ps -o comm= -p $PPID) in
            sshd|*/sshd) SESSION_TYPE="remote/ssh";;
        esac
    fi

    local host_bg_color=148      # green
    local path_bg_color=235      # dark
    local path_bg_sec_color=237  # ligther dark

    local host_fg_color=235
    local path_fg_color=247

    local hostname=""
    local hosticon=""
    local hostcolor=""

    # Context
    if [[ $SESSION_TYPE != "local" ]]; then
        hosticon="  "
        hostname=" (%m) "
    else
        hosticon="   "
    fi

    if [[ $is_a_git_repo == true ]]; then
        repopath="$(git rev-parse --show-toplevel 2> /dev/null)"
        reponame="$(basename $repopath)"
    fi

    # Hostname
    _write $host_bg_color $host_fg_color "$hosticon$hostname"
    _write $path_bg_color $host_bg_color ""

    # Repository name
    if [[ $is_a_git_repo == true ]]; then
        _write $path_bg_color $path_fg_color "   $reponame "
        _write $path_fg_color $repos_prompt_color ""
    fi

    if [[ $retval -ne 0 ]]; then
        end_prompt_color=124
    else
        end_prompt_color=241
    fi

    # Path
    if [[ $is_a_git_repo == true ]]; then
        if [[ $repopath != $PWD ]]; then
            _write 235 249 '⮁ %1~ '
        fi
    else
        _write 235 249 ' %1~ '
    fi
    _write $end_prompt_color 235 ""

    # End
    _write "" $end_prompt_color ""
}

function custom_build_r_prompt {
    # Parameters
    local enabled=${1}
    local current_commit_hash=${2}
    local is_a_git_repo=${3}
    local current_branch=$4
    local detached=${5}
    local just_init=${6}
    local has_upstream=${7}
    local has_modifications=${8}
    local has_modifications_cached=${9}
    local has_adds=${10}
    local has_deletions=${11}
    local has_deletions_cached=${12}
    local has_untracked_files=${13}
    local ready_to_commit=${14}
    local tag_at_current_commit=${15}
    local is_on_a_tag=${16}
    local has_upstream=${17}
    local commits_ahead=${18}
    local commits_behind=${19}
    local has_diverged=${20}
    local should_push=${21}
    local will_rebase=${22}
    local has_stashes=${23}
    local action=${24}

    # Virtualenv
    local virtualenv="$VIRTUAL_ENV"
    local disable_virtualenv_prompt=`[ -n $VIRTUAL_ENV_DISABLE_PROMPT ]`
    local virtualenv_bg=""

    # Colors
    local left_bg_color=235        # grey
    local right_bg_color=252       # orange

    local left_fg_color=247        # grey
    local left_fg_sep_color=250    # white
    local left_fg_sec_color=136    # orange
    local right_fg_color=235       # dark

    local state_bg=""
    local virtualenv_bg=""

    # Exit if not a git repository and no virtualenv (nothing to display)
    if [[ $is_a_git_repo == false && -z $virtualenv ]]; then
        return
    fi

    # Git repository
    if [[ $is_a_git_repo == true ]]; then
        virtualenv_bg=$left_bg_color

        _write "" $left_bg_color ""
        _write $left_bg_color "" " "
        state_bg=$left_bg_color

        # Used for testing
        #has_stashes=true
        #has_untracked_files=true
        #has_modifications=true
        #has_deletions=true
        #has_adds=true
        #has_modifications_cached=true
        #has_deletions_cached=true
        #ready_to_commit=true
        #action="rebase"

        if [[ $has_stashes == true ]]; then
            _write $left_bg_color 184 "$omg_has_stashes_symbol"
        fi

        # Mess
        if [[ $has_untracked_files == true ]]; then
            _write $left_bg_color 241 " $omg_has_untracked_files_symbol"
        fi

        if [[ $has_modifications == true ]]; then
            _write $left_bg_color 241 " $omg_has_modifications_symbol"
        fi

        if [[ $has_deletions == true ]]; then
            _write $left_bg_color 241 " $omg_has_deletions_symbol"
        fi

        # Ready
        if [[ $has_adds == true ]]; then
            _write $left_bg_color 32 " $omg_has_adds_symbol"
        fi

        if [[ $has_modifications_cached == true ]]; then
            _write $left_bg_color 32 " $omg_has_cached_modifications_symbol"
        fi

        if [[ $has_deletions_cached == true ]]; then
            _write $left_bg_color 32 " $omg_has_cached_deletions_symbol "
        fi

        if [[ $ready_to_commit == true || $action == true ]]; then
            _write $left_bg_color $left_fg_sep_color "⮃"
        fi

        # next operation
        if [[ $ready_to_commit == true ]]; then
            _write $left_bg_color 34 " $omg_ready_to_commit_symbol"
        fi

        if [[ -n $action ]]; then
            _write $left_bg_color 34 " $omg_has_action_in_progress_symbol $action"
        fi

        _write "$left_bg_color" $left_fg_sep_color " ⮃ "

        if [[ $detached == true ]]; then
            _write $left_bg_color $left_fg_sec_color "$omg_detached_symbol "
            _write $left_bg_color $left_fg_color " (${current_commit_hash:0:7})"
        else
            if [[ $has_upstream == false ]]; then
                _write $left_bg_color $left_fg_color "-- ${omg_not_tracked_branch_symbol}  --  (${current_branch})"
            else
                if [[ $will_rebase == true ]]; then
                    local type_of_upstream=$omg_rebase_tracking_branch_symbol
                else
                    local type_of_upstream=$omg_merge_tracking_branch_symbol
                fi

                if [[ $has_diverged == true ]]; then
                    _write $left_bg_color $left_fg_color "-${commits_behind} %F{$left_fg_sec_color}${omg_has_diverged_symbol}%F{$left_fg_color} +${commits_ahead}"
                else
                    if [[ $commits_behind -gt 0 ]]; then
                        _write $left_bg_color $left_fg_color "-${commits_behind} %F{$left_fg_sec_color}${omg_can_fast_forward_symbol}%F{black} --"
                    fi
                    if [[ $commits_ahead -gt 0 ]]; then
                        _write $left_bg_color $left_fg_color "-- %F{$left_fg_sec_color}${omg_should_push_symbol}%F{black}  +${commits_ahead}"
                    fi
                    if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
                         _write $left_bg_color $left_fg_color " --   -- "
                    fi

                fi
                _write $left_bg_color $left_fg_sep_color " ⮃ %F{$left_fg_color}$current_branch %F{$left_fg_sec_color}$type_of_upstream%F{black} "
            fi
        fi

        if [[ $is_on_a_tag == true ]]; then
            _write $left_bg_color $left_fg_sep_color " ⮃ %F{$left_fg_color}$omg_is_on_a_tag_symbol $tag_at_current_commit"
        fi
    fi

    # Virtualenv
    if [[ -n $virtualenv && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
        _write "$virtualenv_bg" $right_bg_color " "
        _write $right_bg_color "" " "
        _write $right_bg_color $right_fg_color "`basename $virtualenv` "
    else
        _write $left_bg_color "" " "
    fi
}

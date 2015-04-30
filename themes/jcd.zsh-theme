# vim:ft=zsh

: ${omg_has_untracked_files_symbol:=''}        #                ?    
: ${omg_has_adds_symbol:=''}
: ${omg_has_deletions_symbol:=''}
: ${omg_has_cached_deletions_symbol:=''}
: ${omg_has_modifications_symbol:=''}
: ${omg_has_cached_modifications_symbol:=''}
: ${omg_ready_to_commit_symbol:=''}            #   →
: ${omg_is_on_a_tag_symbol:=''}                #   
: ${omg_needs_to_merge_symbol:='ᄉ'}
: ${omg_detached_symbol:=''}
: ${omg_can_fast_forward_symbol:=''}
: ${omg_has_diverged_symbol:=''}               #   
: ${omg_not_tracked_branch_symbol:=''}
: ${omg_rebase_tracking_branch_symbol:=''}     #   
: ${omg_merge_tracking_branch_symbol:=''}      #  
: ${omg_should_push_symbol:=''}                #    
: ${omg_has_stashes_symbol:=''}
: ${omg_has_action_in_progress_symbol:=''}     #                  

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

    # Context
    if [[ $retval -ne 0 ]]; then
        _write 166 235 "   ($retval) "
        _write 235 166 ""
    elif [[ $is_a_git_repo == true ]]; then
        _write 39 235 "   "
        _write 235 39 ""
    elif [[ $SESSION_TYPE == "local" ]]; then
        _write 40 235 "   "
        _write 235 40 ""
    else
        _write 172 235 "   (%m) "
        _write 235 172 ""
    fi

    # Path or repository name
    if [[ $is_a_git_repo == true ]]; then
        _write 235 251 " $(basename `git rev-parse --show-toplevel 2> /dev/null`) "
    else
        _write 235 251 ' %1~ '
    fi
    _write 252 235 ""

    # End
    _write 252 235 ' $ '
    _write "" 252 ""
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
    local left_bg_color=237        # grey
    local middle_bg_color=252      # white
    local right_bg_color=93        # purple

    local state_bg=""
    local virtualenv_bg=""

    # Exit if not a git repository and no virtualenv (nothing to display)
    if [[ $is_a_git_repo == false && -z $virtualenv ]]; then
        return
    fi

    # Git repository
    if [[ $is_a_git_repo == true ]]; then
        virtualenv_bg=$middle_bg_color

        if [[ $has_stashes == true || $has_untracked_files == true || $has_modifications == true || $has_deletions == true || $has_adds == true || $has_modifications_cached == true || $has_deletions_cached == true || $ready_to_commit == true || $action == true ]]; then
            _write "" $left_bg_color ""
            _write $left_bg_color "" " "
            state_bg=$left_bg_color
        fi

        if [[ $has_stashes == true ]]; then
            _write $left_bg_color yellow "$omg_has_stashes_symbol  "
        fi

        # Mess
        if [[ $has_untracked_files == true ]]; then
            _write $left_bg_color red "$omg_has_untracked_files_symbol  "
        fi

        if [[ $has_modifications == true ]]; then
            _write $left_bg_color red "$omg_has_modifications_symbol  "
        fi

        if [[ $has_deletions == true ]]; then
            _write $left_bg_color red "$omg_has_deletions_symbol  "
        fi

        # Ready
        if [[ $has_adds == true ]]; then
            _write $left_bg_color 251 "$omg_has_adds_symbol  "
        fi

        if [[ $has_modifications_cached == true ]]; then
            _write $left_bg_color 251 "$omg_has_cached_modifications_symbol  "
        fi

        if [[ $has_deletions_cached == true ]]; then
            _write $left_bg_color 251 "$omg_has_cached_deletions_symbol  "
        fi

        if [[ $ready_to_commit == true || $action == true ]]; then
            _write $left_bg_color 251 "⮃ "
        fi

        # next operation
        if [[ $ready_to_commit == true ]]; then
            _write $left_bg_color red "$omg_ready_to_commit_symbol  "
        fi

        if [[ $action ]]; then
            _write $left_bg_color red "$omg_has_action_in_progress_symbol $action  "
        fi

        _write "$state_bg" $middle_bg_color ""
        _write $middle_bg_color "" " "

        if [[ $detached == true ]]; then
            _write $middle_bg_color 26 "$omg_detached_symbol "
            _write $middle_bg_color 235 " (${current_commit_hash:0:7})"
        else
            if [[ $has_upstream == false ]]; then
                _write $middle_bg_color 235 "-- ${omg_not_tracked_branch_symbol}  --  (${current_branch})"
            else
                if [[ $will_rebase == true ]]; then
                    local type_of_upstream=$omg_rebase_tracking_branch_symbol
                else
                    local type_of_upstream=$omg_merge_tracking_branch_symbol
                fi

                if [[ $has_diverged == true ]]; then
                    _write $middle_bg_color 26 "-${commits_behind} ${omg_has_diverged_symbol} +${commits_ahead}"
                else
                    if [[ $commits_behind -gt 0 ]]; then
                        _write $middle_bg_color 235 "-${commits_behind} %F{26}${omg_can_fast_forward_symbol}%F{black} --"
                    fi
                    if [[ $commits_ahead -gt 0 ]]; then
                        _write $middle_bg_color 235 "-- %F{26}${omg_should_push_symbol}%F{black}  +${commits_ahead}"
                    fi
                    if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
                         _write $middle_bg_color 235 " --   -- "
                    fi

                fi
                _write $middle_bg_color 235 " ⮃ $current_branch $type_of_upstream ${upstream//\/$current_branch/}"
            fi
        fi

        if [[ $is_on_a_tag == true ]]; then
            _write $middle_bg_color 235 " ⮃ $omg_is_on_a_tag_symbol $tag_at_current_commit"
        fi
    fi

    # Virtualenv
    if [[ -n $virtualenv && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
        _write "$virtualenv_bg" $right_bg_color " "
        _write $right_bg_color "" " "
        _write $right_bg_color 254 "`basename $virtualenv` "
    else
        _write $middle_bg_color "" " "
    fi
}

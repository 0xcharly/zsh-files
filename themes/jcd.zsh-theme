: ${omg_ungit_prompt:=$PS1}
: ${omg_second_line:="%~ • "}
: ${omg_is_a_git_repo_symbol:=''}
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

CURRENT_BG='NONE'
CURRENT_R_BG='NONE'
SEGMENT_SEPARATOR=''
R_SEGMENT_SEPARATOR=''
SUB_SEGMENT_SEPARATOR='⮁'

PROMPT='%{%f%b%k%}$(build_prompt)%{%f%b%k%} '
RPROMPT='%{%f%b%k%}$(build_rprompt)%{%f%b%k%}'

# Reset both PROMPT and RPROMTP. Use this on platform where rich prompt is not
# supported.
function reset_prompt() {
    PROMPT='$ '; export PROMPT
    unset RPROMPT
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
function prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
function prompt_sub_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n "$3%{%F{239}%}⮁"
}

# End the prompt, closing any open segments
function prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
        echo -n " %{%K{252}%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
        echo -n "%{%k%}"
    fi
    echo -n "%{%K{252}%F{234}%}    %{%f%k%}"
    echo -n "%{%k%F{252}%}$SEGMENT_SEPARATOR"
    CURRENT_BG=''
}

# Begin a right segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
function r_prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_R_BG != 'NONE' && $1 != $CURRENT_R_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_R_BG}%}$R_SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%F{$1%}$R_SEGMENT_SEPARATOR%{$bg%}%{$fg%} "
    fi
    CURRENT_R_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# End the prompt
function r_prompt_end() {
    if [[ -n $CURRENT_R_BG ]]; then
        echo -n "%{%K{$CURRENT_R_BG}%} "
    else
        echo -n "%{%k%}."
    fi
    CURRENT_R_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
function prompt_context() {
    prompt_segment 172 234 "%m"
}

# Dir: current working directory
function prompt_dir() {
    prompt_segment 235 251 '%1~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
function prompt_status() {
    local symbols
    symbols=()

    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%} "
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$RETVAL"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}"

    [[ -n "$symbols" ]] && prompt_segment 235 default "$symbols %F{251}$SUB_SEGMENT_SEPARATOR"
}

# Virtualenv: current working virtualenv
function r_prompt_virtualenv() {
    local virtualenv_path="$VIRTUAL_ENV"
    if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
        r_prompt_segment 252 234 "(`basename $virtualenv_path`)"
    fi
}

## Right prompt
function build_rprompt() {
    r_prompt_virtualenv
    r_prompt_end
}

function enrich_append {
    local flag=$1
    local symbol=$2
    local color=${3:-$omg_default_color_on}
    if [[ $flag == false ]]; then symbol=' '; fi

    echo -n "${color}${symbol}  "
}

function custom_build_prompt {
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

    local prompt=""
    local original_prompt=$PS1

    local black_on_orange="%K{33}%F{234}"
    local orange_on_grey="%K{235}%F{33}"
    local white_on_grey="%K{235}%F{251}"
    local yellow_on_grey="%K{235}%F{yellow}"
    local red_on_grey="%K{235}%F{red}"
    local grey_on_white="%K{252}%F{235}"
    local blue_on_white="%K{252}%F{26}"
    local orange_on_white="%K{252}%F{33}"

    local black_on_white="%K{252}%F{black}"
    local yellow_on_white="%K{252}%F{yellow}"
    local red_on_white="%K{252}%F{red}"
    local red_on_black="%K{black}%F{red}"
    local black_on_red="%K{red}%F{black}"
    local white_on_red="%K{red}%F{252}"
    local yellow_on_red="%K{red}%F{yellow}"

    # Flags
    local omg_default_color_on="${black_on_white}"
    local current_path="%~"

    if [[ $is_a_git_repo == true ]]; then
        # on filesystem
        prompt="${black_on_orange} "
        prompt+=$(enrich_append $is_a_git_repo $omg_is_a_git_repo_symbol "${black_on_orange}")
        prompt="${prompt} ${orange_on_grey} ${white_on_grey}"
        prompt+=$(enrich_append $has_stashes $omg_has_stashes_symbol "${yellow_on_grey}")

        prompt+=$(enrich_append $has_untracked_files $omg_has_untracked_files_symbol "${red_on_grey}")
        prompt+=$(enrich_append $has_modifications $omg_has_modifications_symbol "${red_on_grey}")
        prompt+=$(enrich_append $has_deletions $omg_has_deletions_symbol "${red_on_grey}")

        # ready
        prompt+=$(enrich_append $has_adds $omg_has_adds_symbol "${white_on_grey}")
        prompt+=$(enrich_append $has_modifications_cached $omg_has_cached_modifications_symbol "${white_on_grey}")
        prompt+=$(enrich_append $has_deletions_cached $omg_has_cached_deletions_symbol "${white_on_grey}")

        # next operation
        prompt+=$(enrich_append $ready_to_commit $omg_ready_to_commit_symbol "${red_on_grey}")
        prompt+=$(enrich_append $action "${omg_has_action_in_progress_symbol} $action" "${red_on_grey}")

        # where
        prompt="${prompt} ${grey_on_white} ${grey_on_white}"

        if [[ $detached == true ]]; then
            prompt+=$(enrich_append $detached $omg_detached_symbol "${blue_on_white}")
            prompt+=$(enrich_append $detached "(${current_commit_hash:0:7})" "${grey_on_white}")
        else
            if [[ $has_upstream == false ]]; then
                prompt+=$(enrich_append true "-- ${omg_not_tracked_branch_symbol}  --  (${current_branch})" "${grey_on_white}")
            else
                if [[ $will_rebase == true ]]; then
                    local type_of_upstream=$omg_rebase_tracking_branch_symbol
                else
                    local type_of_upstream=$omg_merge_tracking_branch_symbol
                fi

                if [[ $has_diverged == true ]]; then
                    prompt+=$(enrich_append true "-${commits_behind} ${omg_has_diverged_symbol} +${commits_ahead}" "${blue_on_white}")
                else
                    if [[ $commits_behind -gt 0 ]]; then
                        prompt+=$(enrich_append true "-${commits_behind} %F{26}${omg_can_fast_forward_symbol}%F{black} --" "${grey_on_white}")
                    fi
                    if [[ $commits_ahead -gt 0 ]]; then
                        prompt+=$(enrich_append true "-- %F{26}${omg_should_push_symbol}%F{black}  +${commits_ahead}" "${grey_on_white}")
                    fi
                    if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
                         prompt+=$(enrich_append true " --   -- " "${grey_on_white}")
                    fi

                fi
                prompt+=$(enrich_append true "(${current_branch} ${type_of_upstream} ${upstream//\/$current_branch/})" "${grey_on_white}")
            fi
        fi
        prompt+=$(enrich_append ${is_on_a_tag} "${omg_is_on_a_tag_symbol} ${tag_at_current_commit}" "${grey_on_white}")
        prompt+="%k%F{252}%k%f"
        echo "${prompt}"
    fi

    prompt_context
    prompt_status
    prompt_dir
    prompt_end
}

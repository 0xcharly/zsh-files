# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
CURRENT_R_BG='NONE'
SEGMENT_SEPARATOR=''
R_SEGMENT_SEPARATOR=''
SUB_SEGMENT_SEPARATOR='⮁'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
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
prompt_sub_segment() {
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
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%K{252}%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%K{252}%F{235}%} ❯ %{%f%k%}"
  echo -n "%{%k%F{252}%}$SEGMENT_SEPARATOR"
  CURRENT_BG=''
}

# Begin a right segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
r_prompt_segment() {
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
r_prompt_end() {
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
prompt_context() {
  prompt_segment 148 234 "%(!.%{%F{yellow}%}.)%m"
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '+ '
    zstyle ':vcs_info:git:*' unstagedstr '● '
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats '%u%c'
    vcs_info

    if [[ -n $dirty ]]; then
      prompt_sub_segment 234 166 "${ref/refs\/heads\// }${vcs_info_msg_0_}"
    else
      prompt_sub_segment 234 34 "${ref/refs\/heads\// }${vcs_info_msg_0_}"
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment 234 244 '%1~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    r_prompt_segment 148 234 "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$RETVAL"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment 235 default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_git
  prompt_dir
  prompt_end
}

## Right prompt
build_rprompt() {
  prompt_virtualenv
  r_prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt)%{%f%b%k%} '
RPROMPT=' %{%f%b%k%}$(build_rprompt)%{%f%b%k%}'

reset_prompt() {
  PROMPT='$ '; export PROMPT
  unset RPROMPT
}

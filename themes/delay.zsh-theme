autoload -U colors && colors

PROMPT="%(?..%F{208}%K{235}[%?] $(date -u +'%Y-%m-%dT%H%M%SZ')$(tput el)
)%{%k%}%{%F{241}%}[%m]%{%k%}%{%F{244}%}:%{❯%G%}%{%k%}%{%f%} "
RPROMPT=""

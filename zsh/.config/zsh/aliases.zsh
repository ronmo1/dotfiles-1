#!/usr/bin/env zsh
# Note: this file depends on functions.zsh being sourced first (for the is-supported function)

(( ${+aliases[run-help]} )) && unalias run-help
(( ${+aliases[which-command]} )) && unalias which-command

# Directory listing/traversal

LS_COLORIZED=$(is-supported "ls --color" --color -G)
LS_TIMESTYLEISO=$(is-supported "ls --time-style=long-iso" --time-style=long-iso)
LS_GROUPDIRSFIRST=$(is-supported "ls --group-directories-first" --group-directories-first)

alias ls="ls -lA $LS_COLORIZED"
alias lt="ls -lhAtr $LS_COLORIZED $LS_TIMESTYLEISO $LS_GROUPDIRSFIRST"
alias ld="ls -ld $LS_COLORIZED */"
alias lp="stat -f '%A %N' *"

# cd
alias ..="cd .."              # Go back 1 directory level (for fast typers).
alias ...="cd ../../"         # Go back 2 directory levels.
alias ....="cd ../../../"     # Go back 3 directory levels.
alias .....="cd ../../../../" # Go back 4 directory levels.

# grep
alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}'

# Editors
alias vi="$EDITOR"
alias code="$VISUAL"

# Misc
alias r="exec ${SHELL} -l"
alias c="clear && printf '\e[3J'"

# dbt
alias dbtc="${HOMEBREW_PREFIX}/bin/dbt"
alias dbtf="${HOME}/.local/bin/dbt"

# brew
alias bup='brew update && brew upgrade'
alias bin='brew install'
alias brm='brew uninstall'
alias bcl='brew cleanup'
alias bdr='brew doctor $(brew doctor --list-checks | grep -v stray_headers)'
alias bdep='brew leaves | xargs brew deps --formula --for-each | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"'

# uv
alias uva='uv add'
alias uvexp='uv export --format requirements-txt --no-hashes --output-file requirements.txt --quiet'
alias uvl='uv lock'
alias uvlr='uv lock --refresh'
alias uvlu='uv lock --upgrade'
alias uvp='uv pip'
alias uvpy='uv python'
alias uvr='uv run'
alias uvrm='uv remove'
alias uvs='uv sync'
alias uvsr='uv sync --refresh'
alias uvsu='uv sync --upgrade'
alias uvup='uv self update'
alias uvv='uv venv'

# sqlfluff
alias sqff='git diff --name-only --diff-filter=AM --relative | grep "\.sql$" | xargs -r uv run sqlfluff fix'
alias sqfl='git diff --name-only --diff-filter=AM --relative | grep "\.sql$" | xargs -r uv run sqlfluff lint'

# snowsql
alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql

#!/usr/bin/env zsh

# ================================================================
# General
# ================================================================

function mcd() {
  mkdir -p "$1" && cd "$1" || return
}

# Feature probe used by aliases.zsh.
# is-supported CMD            -> returns 0 if CMD runs successfully
# is-supported CMD YES [NO]   -> prints YES if CMD succeeds, else NO (no newline)
function is-supported() {
  if (( $# == 1 )); then
    eval "$1" &>/dev/null
  elif eval "$1" &>/dev/null; then
    print -rn -- "$2"
  else
    print -rn -- "${3-}"
  fi
}

# ================================================================
# AWS
# ================================================================
s3ls() {
  local BUCKET="$1"
  local PREFIX="$2"

  aws s3api list-objects-v2 \
    --bucket $BUCKET \
    --prefix $PREFIX \
    --query "Contents[][Key, Size, LastModified]" \
    --output text \
    --no-cli-pager
}

# ================================================================
# Python
# ================================================================
: "${PYTHON_VENV_NAME:=.venv}"

# Activate the Python virtual environment in the current directory.
# Usage: vrun [venv_name]
# If no name is given, uses $PYTHON_VENV_NAME (default: .venv).
function vrun() {
  local name="${1:-$PYTHON_VENV_NAME}"
  local venvpath="./${name}"

  if [[ ! -d "$venvpath" ]]; then
    echo "Error: No such virtual environment directory: $venvpath" >&2
    return 1
  fi

  if [[ ! -f "${venvpath}/bin/activate" ]]; then
    echo "Error: '$venvpath' is not a valid Python virtual environment" >&2
    return 1
  fi

  source "${venvpath}/bin/activate"
}

# ================================================================
# Homebrew
# ================================================================

# List all installed formulae and casks with their dependencies.
function brews() {
  local formulae="$(brew leaves | xargs brew deps --installed --for-each)"
  local casks="$(brew list --cask 2>/dev/null)"

  local blue="$(tput setaf 4)"
  local bold="$(tput bold)"
  local off="$(tput sgr0)"

  echo "${blue}==>${off} ${bold}Formulae${off}"
  echo "${formulae}" | sed "s/^\(.*\):\(.*\)$/\1${blue}\2${off}/"
  echo "\n${blue}==>${off} ${bold}Casks${off}\n${casks}"
}

# ================================================================
# Git
# ================================================================

# Get current branch
function git_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

# Check for develop and similarly named branches
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return
    fi
  done
  echo staging
}

# Check if main exists and use instead of master
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done
  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

function git_switch_interactive() {
  local branches branch

  branches=$(git branch --sort=-committerdate --color=always | grep -v '^* ' || true)

  branch=$(
    echo "$branches" |
      fzf --ansi \
        --border \
        --exact \
        --layout reverse \
        --header="Current branch: $(git branch --show-current)" \
        --height=25% \
        --prompt='Switch branch > ' \
        --bind='enter:accept' \
        --pointer='▶' |
      awk '{print $1}'
  )

  [ -z "$branch" ] || git switch $branch --quiet

}

# Force-delete branches locally, and on the remote only when a same-named
# remote branch exists. Never deletes the upstream a branch merely tracks
# (e.g. origin/develop for a branch created from it), and never the main branch.
function git_branch_delete() {
  if [[ -z "$1" ]]; then
    echo "Usage: gbd <branch-name> [branch-name...]" >&2
    return 1
  fi

  local main_branch branch remote
  main_branch=$(git_main_branch)

  for branch in "$@"; do
    if [[ "$branch" == "$main_branch" ]]; then
      echo "Refusing to delete $main_branch." >&2
      continue
    fi

    remote=$(git config "branch.$branch.remote" || echo "origin")

    echo "Deleting $branch..."
    git branch -D "$branch" || true

    # Skip if remote is local
    [[ "$remote" = "." ]] && continue

    if git show-ref --quiet --verify "refs/remotes/$remote/$branch"; then
      # Fall back to pruning a stale remote-tracking ref if the remote branch is already gone.
      git push "$remote" --delete "$branch" || git branch -d -r "$remote/$branch"
    else
      echo "No $remote/$branch; skipping remote delete."
    fi
  done
}

# Rebase current branch onto origin/main without pushing.
# Automatically aborts rebase on conflicts for manual resolution.
function git_rebase_main() {
  local main_branch
  main_branch=$(git_main_branch)
  local before after

  git fetch origin "$main_branch" || {
    echo "Fetch failed."
    return 1
  }

  before=$(git rev-parse HEAD)
  if ! git rebase "origin/$main_branch"; then
    git rebase --abort
    echo "Rebase failed, please resolve conflicts manually."
    return 1
  fi

  after=$(git rev-parse HEAD)
  if [[ "$before" == "$after" ]]; then
    echo "Already up to date."
    return 0
  fi

  echo "Rebased onto origin/$main_branch."
}

# Fast-forward merge current branch into main and push.
# Requires a clean working tree and that the branch is already rebased onto origin/main.
function git_land() {
  local main_branch feature_branch
  main_branch=$(git_main_branch)
  feature_branch=$(git_current_branch)

  if [[ "$feature_branch" == "$main_branch" ]]; then
    echo "Already on $main_branch; nothing to land." >&2
    return 1
  fi

  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Working tree not clean. Commit or stash first." >&2
    return 1
  fi

  git fetch origin "$main_branch" || {
    echo "Fetch failed." >&2
    return 1
  }

  if ! git merge-base --is-ancestor "origin/$main_branch" "$feature_branch"; then
    echo "$feature_branch is not rebased onto origin/$main_branch. Run gsync or grbm first." >&2
    return 1
  fi

  git switch "$main_branch" --quiet || return 1

  if ! git merge --ff-only "$feature_branch"; then
    echo "Fast-forward merge failed." >&2
    return 1
  fi

  git push origin "$main_branch" || {
    echo "Push failed." >&2
    return 1
  }

  echo "Landed $feature_branch into $main_branch and pushed."
}

# Sync current branch with main: fetch, rebase, and force-push.
# Automatically aborts rebase on conflicts for manual resolution.
function git_sync() {
  local main_branch
  main_branch=$(git_main_branch)
  local before after

  # Fetch latest main
  git fetch origin "$main_branch" || {
    echo "Fetch failed."
    return 1
  }

  # Attempt rebase onto main
  before=$(git rev-parse HEAD)
  if ! git rebase "origin/$main_branch"; then
    git rebase --abort
    echo "Rebase failed, please resolve conflicts manually."
    return 1
  fi

  # Check if rebase made changes
  after=$(git rev-parse HEAD)
  if [[ "$before" == "$after" ]]; then
    echo "Already up to date."
    return 0
  fi

  # Push rebased changes
  git push --force-with-lease || {
    echo "Push failed."
    return 1
  }
  echo "Rebased and pushed."
}

# ================================================================
# Yazi
# ================================================================

function y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd" || true
  rm -f -- "$tmp"
}

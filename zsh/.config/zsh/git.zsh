#!/usr/bin/env zsh

typeset -g _git_log_fuller_format='%C(bold yellow)commit %H%C(auto)%d%n%C(bold)Author: %C(blue)%an <%ae> %C(cyan)%ai (%ar)%n%C(bold)Commit: %C(blue)%cn <%ce> %C(cyan)%ci (%cr)%C(reset)%n%+B'
typeset -g _git_log_oneline_format='%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)'
typeset -g _git_log_oneline_medium_format='%C(bold yellow)%h%C(reset) %<(50,trunc)%s %C(bold blue)%an %C(cyan)%as (%ar)%C(auto)%d%C(reset)'

gprefix='g'

alias ${gprefix}='git'

# Add
alias ${gprefix}a='git add' # stage files
alias ${gprefix}aa='git add --all' # stage all changes
alias ${gprefix}ap='git add --patch' # interactively stage hunks

# Branch
alias ${gprefix}b='git branch' # list branches
alias ${gprefix}ba='git branch --all' # list all branches including remote
alias ${gprefix}bd='git_branch_delete' # force-delete branch locally and its same-named remote branch

# Commit
alias ${gprefix}c='git commit' # commit staged changes
alias ${gprefix}cv='git commit --verbose' # commit with diff in editor
alias ${gprefix}cm='git commit --message' # commit with inline message
alias ${gprefix}cf='git commit --fixup' # create fixup commit for rebase
alias ${gprefix}cav='git commit --amend --verbose' # amend last commit with diff
alias ${gprefix}cam='git commit --amend --message' # amend with new message
alias ${gprefix}cane='git commit --amend --no-edit' # amend without changing message

# Cherry-pick
alias ${gprefix}cp='git cherry-pick' # apply commit from another branch
alias ${gprefix}cpa='git cherry-pick --abort' # abort cherry-pick
alias ${gprefix}cpc='git cherry-pick --continue' # continue after resolving conflicts

# Clean
alias ${gprefix}cl='git clean -fd' # remove untracked files and directories
alias ${gprefix}cln='git clean -fdn' # dry run, show what would be removed

# Diff
alias ${gprefix}d='git diff' # show unstaged changes
alias ${gprefix}ds='git diff --staged' # show staged changes
alias ${gprefix}dw='git diff --word-diff' # show word-level diff

# Fetch
alias ${gprefix}f='git fetch' # download objects from remote
alias ${gprefix}fa='git fetch --all' # fetch from all remotes

# Pull
alias ${gprefix}pl='git pull' # fetch and merge remote changes
alias ${gprefix}plr='git pull --rebase' # fetch and rebase local commits

# Log
alias ${gprefix}l='git log --date-order --pretty=format:"${_git_log_fuller_format}"' # detailed log
alias ${gprefix}ls='git log --date-order --stat --pretty=format:"${_git_log_fuller_format}"' # log with file stats
alias ${gprefix}lo='git log --date-order --pretty=format:"${_git_log_oneline_format}"' # one line per commit
alias ${gprefix}lg='git log --date-order --graph --pretty=format:"${_git_log_oneline_format}"' # graph view
alias ${gprefix}la='git log --all --graph --pretty=format:"${_git_log_oneline_format}"' # graph all branches
alias ${gprefix}lm='git log --date-order --pretty=format:"${_git_log_oneline_medium_format}" -n 10' # last 10 commits

# Merge
alias ${gprefix}m='git merge' # merge branch into current
alias ${gprefix}ma='git merge --abort' # abort merge
alias ${gprefix}mc='git merge --continue' # continue after resolving conflicts
alias ${gprefix}mff='git merge --ff-only' # only fast-forward merge

# Push
alias ${gprefix}pu='git push' # push commits to remote
alias ${gprefix}puf='git push --force-with-lease' # force push safely
alias ${gprefix}pufo='git push --force' # force push (dangerous)
alias ${gprefix}puu='git push --set-upstream origin $(git_current_branch)' # push and set upstream

# Rebase
alias ${gprefix}rb='git rebase' # rebase current branch
alias ${gprefix}rba='git rebase --abort' # abort rebase
alias ${gprefix}rbc='git rebase --continue' # continue after resolving conflicts
alias ${gprefix}rbi='git rebase --interactive --autosquash' # interactive rebase with autosquash
alias ${gprefix}rbm='git_rebase_main' # rebase current branch onto origin/main (no push)
alias ${gprefix}rbs='git rebase --skip' # skip current commit

# Remote
alias ${gprefix}r='git remote' # manage remotes
alias ${gprefix}rv='git remote --verbose' # list remotes with URLs

# Reset (move HEAD, affects commits)
alias ${gprefix}rs='git reset' # unstage files, keep changes
alias ${gprefix}rsh='git reset --hard' # discard all changes
alias ${gprefix}rso='git reset origin/$(git_current_branch) --hard' # reset to remote branch

# Restore (discard working tree changes)
alias ${gprefix}rt='git restore' # discard unstaged changes
alias ${gprefix}rts='git restore --source' # restore from specific commit
alias ${gprefix}rtt='git restore --staged' # unstage files

# Show
alias ${gprefix}sh='git show' # show commit details
alias ${gprefix}shs='git show --stat' # show commit with file stats

# Stash
alias ${gprefix}st='git stash' # stash changes
alias ${gprefix}stp='git stash pop' # apply and remove stash
alias ${gprefix}stl='git stash list' # list stashes
alias ${gprefix}sts='git stash show --text' # show stash diff

# Status
alias ${gprefix}s='git status' # show working tree status
alias ${gprefix}ss='git status --short' # compact status
alias ${gprefix}ssb='git status --short --branch' # compact status with branch

# Switch
alias ${gprefix}sw='git switch' # switch branches
alias ${gprefix}swc='git switch --create' # create and switch to new branch
alias ${gprefix}swm='git switch $(git_main_branch) --quiet' # switch to main
alias ${gprefix}swd='git switch $(git_develop_branch) --quiet' # switch to develop
alias ${gprefix}swi='git_switch_interactive' # interactive branch picker

# Worktree
alias ${gprefix}wt='git worktree' # manage worktrees
alias ${gprefix}wta='git worktree add' # add new worktree
alias ${gprefix}wtl='git worktree list' # list worktrees
alias ${gprefix}wtr='git worktree remove' # remove worktree

# Workflow shortcuts
alias ${gprefix}undo='git reset --soft HEAD~1' # undo last commit, keep changes staged
alias ${gprefix}wip='git commit -am "WIP" --no-verify' # quick WIP commit
alias ${gprefix}dmer='git branch --merged | grep -Ev "(^\*|master|main|dev)" | xargs -n 1 git branch -d' # delete merged branches
alias ${gprefix}sync='git_sync' # Sync current branch with main and push if rebased
alias ${gprefix}land='git_land' # fast-forward merge current branch into main and push

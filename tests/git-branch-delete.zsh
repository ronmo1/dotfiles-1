#!/usr/bin/env zsh
# Regression test for git_branch_delete (gbd). Runs entirely in a temp dir.
# No `set -u`: the function reads "$1" with no args (case E), which would abort the script.
repo_root=${0:A:h:h}
source "$repo_root/zsh/.config/zsh/functions.zsh"

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

tmp=$(mktemp -d "${TMPDIR:-/tmp}/gbd-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
fail=0
check() { if ! eval "$2"; then echo "FAIL: $1"; fail=1; fi; }
remote_has() { git ls-remote --heads origin "refs/heads/$1" | grep -q .; }

setup() {
  rm -rf "$tmp/remote.git" "$tmp/work"
  git init -q --bare -b main "$tmp/remote.git"
  git clone -q "$tmp/remote.git" "$tmp/work" 2>/dev/null
  cd "$tmp/work"
  git switch -q -c main
  git commit -q --allow-empty -m init
  git push -q origin main
  git push -q origin main:develop
  git fetch -q origin
}

# A: branch tracks origin/develop but was pushed as origin/foo
setup
git switch -q -c foo origin/develop
git push -q origin foo
git switch -q main
git_branch_delete foo >/dev/null 2>&1
check "A: develop must survive on remote" 'remote_has develop'
check "A: main must survive on remote" 'remote_has main'
check "A: foo must be gone on remote" '! remote_has foo'
check "A: foo must be gone locally" '! git show-ref -q --verify refs/heads/foo'

# B: normal branch pushed with -u
setup
git switch -q -c bar
git push -q -u origin bar
git switch -q main
git_branch_delete bar >/dev/null 2>&1
check "B: bar must be gone on remote" '! remote_has bar'
check "B: bar must be gone locally" '! git show-ref -q --verify refs/heads/bar'

# C: local-only branch, never pushed
setup
git switch -q -c baz
git switch -q main
git_branch_delete baz >/dev/null 2>&1
check "C: baz must be gone locally" '! git show-ref -q --verify refs/heads/baz'
check "C: remote main/develop untouched" 'remote_has main && remote_has develop'

# D: refuses to delete the main branch
setup
git switch -q -c other
git_branch_delete main >/dev/null 2>&1
check "D: main must survive locally" 'git show-ref -q --verify refs/heads/main'
check "D: main must survive on remote" 'remote_has main'

# E: no args -> usage, non-zero
git_branch_delete >/dev/null 2>&1
check "E: no args returns non-zero" '(( $? != 0 ))'

cd /
(( fail )) || echo "PASS: git_branch_delete"
exit $fail

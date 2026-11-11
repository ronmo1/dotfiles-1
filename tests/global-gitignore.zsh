#!/usr/bin/env zsh
# Asserts the global gitignore hides only OS/editor/tool files, never project dirs.
set -u
repo_root=${0:A:h:h}
excludes="$repo_root/git/.gitignore"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/gitignore-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
git init -q .

must_track=(src/lib/a.ts lib/a.rb build/a.txt dist/a.txt var/a.txt env/a.txt
  instance/a.txt logs/a.txt target/a.txt tags app.log x.spec site/index.html
  parts/a.txt downloads/a.txt)
must_ignore=(.DS_Store .env .venv/a __pycache__/a.pyc a.pyc .a.swp
  .idea/workspace.xml .claude/settings.local.json .claude/.cc-writes/x
  .pytest_cache/a .mypy_cache/a .ipynb_checkpoints/a)

for p in $must_track $must_ignore; do mkdir -p "${p:h}"; : > "$p"; done
listed=("${(@f)$(git -c core.excludesFile="$excludes" ls-files --others --exclude-standard)}")

fail=0
for p in $must_track; do
  (( ${listed[(Ie)$p]} )) || { echo "FAIL: $p is ignored but must be tracked"; fail=1; }
done
for p in $must_ignore; do
  (( ${listed[(Ie)$p]} )) && { echo "FAIL: $p is not ignored"; fail=1; }
done
cd /
(( fail )) || echo "PASS: global gitignore"
exit $fail

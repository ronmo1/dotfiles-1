# dotfiles

GNU Stow repo: each top-level directory is a package whose tree mirrors `$HOME`. `make install` stows the packages listed in `PACKAGES` in the `Makefile`.

## Editing configs

- Edit the file inside its package; the path under `~` is a symlink back into this repo.
- New file or package: add a new package to `PACKAGES` and to the README's Packages table, then run `make restow`. Done when `make check` passes and `make dry-run` (run from `~/.dotfiles`) reports no conflicts.
- Files a package keeps out of `~` go in its `.stow-local-ignore` (example: `git/`).
- Repo-root `.claude/` holds this repo's project settings. `claude/.claude/` is the stowed global `~/.claude`: the global `CLAUDE.md` and `settings.json` for every project.

## Skills and rules

Source of truth is `skillshare/.config/skillshare/skills/` (skills) and `skillshare/.config/skillshare/extras/rules/` (rules). `skillshare sync` fans them out to `~/.claude/skills`, `~/.codex/skills`, and `~/.claude/rules`, overwriting the targets, so edit the source and then sync. The `skillshare` skill covers the CLI.

## Commits

Scope is the package name: `chore(tmux): ...`, `feat(skillshare): ...`.

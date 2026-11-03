# dotfiles

Personal development environment managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Features

- **GNU Stow** symlink management -- one command to install everything
- **XDG Base Directory** compliant (`~/.config/` for all app configs)
- **Everforest dark** theme applied consistently across terminal, editor, and fzf
- **Modular zsh** configuration split into focused files (aliases, functions, git, keybindings, fzf)
- **115+ shell aliases**, each documented with an inline comment

## Installation

Requires macOS with [Homebrew](https://brew.sh).

```bash
brew install stow git
git clone https://github.com/ronmorgen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
make brew
```

`make install` symlinks all packages into `~/`. `make brew` then installs the formulae and casks from the stowed `~/Brewfile`.

## Packages

| Package      | What it configures | Key features                                                        |
| ------------ | ------------------ | ------------------------------------------------------------------- |
| `atuin`      | Shell history      | Searchable, synced shell history with SQLite backend                |
| `brew`       | Homebrew           | Brewfile of formulae and casks, installed with `make brew`          |
| `claude`     | Claude Code CLI    | AI assistant configuration and custom skills                        |
| `fd`         | File finder        | Ignore patterns for fd searches                                     |
| `flow`       | Flow Control       | Terminal text editor with Vim input mode                            |
| `ghostty`    | Terminal emulator  | Everforest color scheme, font, and key bindings                     |
| `git`        | Git                | Global gitconfig, gitignore, and delta diff pager                   |
| `harper-ls`  | Grammar checker    | Custom dictionary for the Harper language server                    |
| `herdr`      | Terminal workspace | Everforest terminal colors and tmux-style key bindings              |
| `helix`      | Helix editor       | Language servers, keymaps, Everforest theme                         |
| `lazygit`    | Git TUI            | Custom key bindings and UI preferences                              |
| `mitos`      | Mitos editor       | Helix-based config, languages, Everforest theme                     |
| `ripgrep`    | ripgrep            | Smart-case search, ignore patterns                                  |
| `sesh`       | Session manager    | tmux session picker configuration                                   |
| `skillshare` | AI skill sync      | Skills and rules synced to Claude Code and Codex                    |
| `starship`   | Shell prompt       | Minimal prompt with git status, Python venv, and AWS context        |
| `task`       | Taskwarrior        | Default project and custom reports                                  |
| `tmux`       | Terminal mux       | Prefix remapping, vim-style pane navigation, plugins                |
| `vim`        | Vim                | Settings, keymaps, and plugin configuration                         |
| `vscode`     | VS Code (macOS)    | Settings, key bindings, and extensions list                         |
| `yazi`       | File manager       | File previews, custom keymaps, Everforest theme                     |
| `zsh`        | Zsh shell          | Aliases, functions, fzf (Everforest, bat previews), git completions |

## Aliases

Every alias has an inline comment in its source file: `zsh/.config/zsh/aliases.zsh`, `git.zsh`, `fzf.zsh`, and shell functions in `functions.zsh`.

## Structure

```console
dotfiles/
├── Makefile              # Install/uninstall/restow targets
├── <package>/
│   ├── .config/<app>/    → ~/.config/<app>/
│   └── .<dotfile>        → ~/.<dotfile>
└── zsh/
    ├── .zshenv              → ~/.zshenv
    ├── .zshrc               → ~/.zshrc
    ├── .zprofile            → ~/.zprofile
    └── .config/zsh/
        ├── aliases.zsh      # General aliases
        ├── functions.zsh    # Shell functions (mcd, brews, vrun, etc.)
        ├── fzf.zsh          # fzf config and aliases (Everforest, bat previews)
        ├── git.zsh          # 70+ git aliases
        ├── keybindings.zsh  # Key bindings
        └── options.zsh      # Shell options
```

## Customization

**Add a new package:**

```bash
mkdir -p newpkg/.config/newpkg
mv ~/.config/newpkg/config.toml newpkg/.config/newpkg/
# Add "newpkg" to PACKAGES in Makefile and to the Packages table above
make restow
make check    # no stow conflicts, Packages table matches PACKAGES
```

**Machine-specific overrides:** Create `~/.zshrc.local` for settings that should not be version-controlled (work credentials, local PATHs, etc.). `.zshrc` sources it automatically after loading the zsh modules.

**Modify existing configs:** Files in `~` are symlinks into this repo, so edits take effect immediately. Run `make restow` only after adding or removing files in a package.

## Commands

| Command          | Description                                                    |
| ---------------- | -------------------------------------------------------------- |
| `make install`   | Symlink all packages to `~/`                                   |
| `make uninstall` | Remove all symlinks                                            |
| `make restow`    | Re-symlink after adding or removing files                      |
| `make dry-run`   | Preview without applying                                       |
| `make brew`      | Install Homebrew packages from `~/Brewfile`                    |
| `make skills`    | Sync skills and rules with `skillshare`                        |
| `make update`    | Pull latest dotfiles, restow, and sync skills                  |
| `make check`     | Lint shell files, check stow conflicts and the Packages table  |
| `make help`      | List targets (default when running `make`)                     |

`.macos` sets macOS system defaults. Run it by hand once per machine: `./.macos`.

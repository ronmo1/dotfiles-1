PACKAGES := vim zsh ripgrep git atuin flow ghostty herdr helix lazygit mitos starship tmux vscode yazi claude fd harper-ls sesh skillshare task brew

.PHONY: install
install: ## Stow all packages
	@stow -v $(PACKAGES)

.PHONY: uninstall
uninstall: ## Unstow all packages
	@stow -vD $(PACKAGES)

.PHONY: restow
restow: ## Restow (useful after modifying package contents)
	@stow -vR $(PACKAGES)

.PHONY: dry-run
dry-run: ## Preview changes without applying
	@stow -nv $(PACKAGES)

ZSH_FILES := zsh/.zshenv zsh/.zprofile zsh/.zshrc $(wildcard zsh/.config/zsh/*.zsh)
# VS Code user files are JSONC (comments allowed), so they are excluded from jq validation.
JSON_FILES := $(shell git ls-files '*.json' ':!:vscode/*' ':!:skillshare/*')

.PHONY: check
check: ## Syntax-check shell files, validate JSON, run tests
	@for f in $(ZSH_FILES); do zsh -n "$$f" || { echo "zsh syntax error: $$f"; exit 1; }; done
	@bash -n .macos
	@shellcheck .macos
	@for f in $(JSON_FILES); do jq empty "$$f" || { echo "invalid JSON: $$f"; exit 1; }; done
	@for t in $(wildcard tests/*.zsh); do zsh "$$t" || exit 1; done
	@echo "check: OK"

.PHONY: brew
brew: ## Install all Homebrew packages from Brewfile
	@brew bundle install --file=$(HOME)/Brewfile

.PHONY: update
update: ## Pull latest dotfiles and restow
	@git pull --rebase && $(MAKE) restow

.PHONY: help
help:
	@awk -F':.*?## ' '/^[a-zA-Z_-]+:.*?## /{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

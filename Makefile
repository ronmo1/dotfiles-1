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

.PHONY: brew
brew: ## Install all Homebrew packages from Brewfile
	@brew bundle install --file=$(HOME)/Brewfile

.PHONY: skills
skills: ## Sync skills and rules to AI tools with skillshare
	@skillshare sync

.PHONY: update
update: ## Pull latest dotfiles, restow, and sync skills
	@git pull --rebase && $(MAKE) restow && $(MAKE) skills

ZSH_FILES := zsh/.zshenv zsh/.zshrc zsh/.zprofile $(wildcard zsh/.config/zsh/*.zsh)

.PHONY: check
check: ## Lint shell files, check stow conflicts and README package table
	@shellcheck .macos
	@for f in $(ZSH_FILES); do zsh -n "$$f" || exit 1; done
	@stow -n $(PACKAGES)
	@readme=$$(awk '/^## Packages/{p=1;next} /^## /{p=0} p && /^\| `/{split($$0,a,"`"); print a[2]}' README.md | sort); \
	pkgs=$$(printf '%s\n' $(PACKAGES) | sort); \
	if [ "$$readme" != "$$pkgs" ]; then \
		echo "README Packages table does not match PACKAGES in Makefile:"; \
		echo "  README:   $$(echo $$readme)"; \
		echo "  Makefile: $$(echo $$pkgs)"; \
		exit 1; \
	fi
	@echo "check: OK"

.PHONY: help
help:
	@awk -F':.*?## ' '/^[a-zA-Z_-]+:.*?## /{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

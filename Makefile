OS := $(shell uname -s)

.PHONY: install install-mac install-linux

install:
	@if [ "$(OS)" = "Darwin" ]; then \
		$(MAKE) install-mac; \
	elif [ "$(OS)" = "Linux" ]; then \
		$(MAKE) install-linux; \
	else \
		echo "Unsupported OS: $(OS). Please install dependencies manually."; \
		exit 1; \
	fi

install-mac:
	@echo "🍎 macOS detected. Installing dependencies via Homebrew..."
	@if ! command -v brew >/dev/null; then \
		echo "Error: Homebrew is not installed. Please install it first: https://brew.sh/"; \
		exit 1; \
	fi
	brew update
	@echo "Installing/Updating Neovim (HEAD for v0.11+)..."
	brew install neovim --HEAD || brew upgrade neovim --HEAD
	@echo "Installing tools..."
	brew install ripgrep fd cmake
	@echo "✅ Installation complete! Run 'nvim' to start."

install-linux:
	@echo "🐧 Linux detected. Assuming Ubuntu/Debian..."
	@if ! command -v apt-get >/dev/null; then \
		echo "Error: apt-get not found. This script supports Ubuntu/Debian only."; \
		exit 1; \
	fi
	sudo apt-get update
	sudo apt-get install -y software-properties-common curl git build-essential
	@echo "Adding Neovim Unstable PPA (for v0.11+)..."
	sudo add-apt-repository -y ppa:neovim-ppa/unstable
	sudo apt-get update
	@echo "Installing Neovim and dependencies..."
	sudo apt-get install -y neovim ripgrep fd-find cmake python3-venv
	@echo "Setting up 'fd' alias (fdfind -> fd)..."
	@mkdir -p ~/.local/bin
	@ln -sf $$(which fdfind) ~/.local/bin/fd
	@echo "⚠️  NOTE: Please ensure ~/.local/bin is in your PATH to use 'fd' command."
	@echo "✅ Installation complete! Run 'nvim' to start."

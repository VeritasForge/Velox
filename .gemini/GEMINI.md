# Velox: VS Code Style Neovim Configuration

This directory contains a Neovim configuration designed to replicate the user experience of VS Code while leveraging the speed and efficiency of Neovim. It is branded as **Velox** (Latin for "Swift").

## Project Overview

*   **Core Philosophy:** A hybrid editor setup combining Neovim's modal editing and performance with VS Code's modern UI and features (file explorer, tabs, intelligent code completion, terminal integration).
*   **Base Version:** Requires Neovim v0.11+ (uses `vim.lsp.config`/`vim.lsp.enable`).
*   **Plugin Manager:** `lazy.nvim` is used for efficient plugin management.
*   **Language Support:** Pre-configured for Python, Go, Kotlin, Lua, and more.

## Architecture & File Structure

The configuration follows a modular Lua-based structure:

*   **`init.lua`**: The entry point. Sets leader keys and loads core modules.
*   **`lua/config/`**: Core Neovim settings.
    *   `options.lua`: General editor options (line numbers, indentation, etc.).
    *   `keymaps.lua`: Global keybindings (window navigation, buffer management).
    *   `lazy.lua`: Bootstrapping for the `lazy.nvim` plugin manager.
*   **`lua/plugins/`**: Plugin specifications and configurations.
    *   `ui.lua`: UI elements (Neo-tree, Lualine, Bufferline).
    *   `lsp.lua`: Language Server Protocol setup (Mason, nvim-lspconfig, nvim-cmp).
    *   `treesitter.lua`: Syntax highlighting and parsing.
    *   `telescope.lua`: Fuzzy finding (files, text, buffers).
    *   `dap.lua`: Debug Adapter Protocol (debugging).
    *   `git.lua`: Git integration (Gitsigns).

## Installation & Usage

### Automated Installation (Makefile)

A `Makefile` is provided to automate the installation of Neovim and external dependencies on macOS and Ubuntu.

*   **Command:** `make install`
*   **macOS:** Installs Neovim (HEAD), ripgrep, fd, cmake via Homebrew.
*   **Ubuntu:** Installs Neovim (unstable PPA), ripgrep, fd-find, cmake, etc., via `apt`.

### Key Features & Bindings

*   **Navigation:**
    *   `<Ctrl> + p`: Smart file search (Telescope).
    *   `<Space> + e`: Toggle File Explorer (Neo-tree).
    *   `<Space> + fg`: Live Grep.
*   **Editor:**
    *   `<Space> + x`: Close current buffer.
    *   `<Space> + n`: New empty buffer.
    *   `<Shift> + h/l`: Navigate buffers (tabs).
*   **LSP:**
    *   `gd`: Go to definition.
    *   `K`: Hover documentation.
    *   `<Space> + cf`: Format code.

## Development Conventions

*   **Code Style:** Lua configuration files are formatted with `stylua` (implied by `conform.nvim` setup).
*   **Plugin Management:** All plugins are defined in `lua/plugins/` and managed by `lazy.nvim`. A `lazy-lock.json` file tracks exact versions to ensure reproducibility.
*   **Updates:** Run `:Lazy` inside Neovim to manage plugin updates.

## Troubleshooting

*   **Treesitter:** Pinned to tag `v0.9.3` to avoid stability issues with the `main` branch.
*   **External Tools:** `fd` and `ripgrep` are required for optimal performance of Telescope. The `Makefile` ensures they are installed.

## Current Implementation Context

*   **2026-01-16**:
    *   Renamed project to **Velox** in `README.md`.
    *   Added Gemini CLI agent configuration (`.gemini/GEMINI.md`, `.gemini/commands/commit.toml`).
    *   Transitioned command definition from `.md` to `.toml` format.
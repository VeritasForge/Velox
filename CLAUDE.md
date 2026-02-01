# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Velox** is a Neovim (v0.11+) configuration combining Neovim's speed with VS Code-style usability. Written entirely in Lua, targeting Python, Go, and Kotlin development.

## Common Commands

```bash
make install          # Install all dependencies (Neovim, ripgrep, fd, cmake) - detects macOS/Linux
nvim                  # Launch Neovim (plugins auto-install on first run via lazy.nvim)
```

Inside Neovim:
- `:Lazy` - Plugin manager UI (install, update, clean plugins)
- `:Mason` - LSP/formatter/linter installer UI
- `:checkhealth` - Diagnose configuration issues

## Architecture

### Bootstrap Flow

`init.lua` → sets leader key (Space) → loads three modules in order:
1. `lua/config/options.lua` - Vim options (2-space indent, system clipboard, etc.)
2. `lua/config/keymaps.lua` - Core keybindings (window nav, buffer management)
3. `lua/config/lazy.lua` - Bootstraps lazy.nvim, which auto-imports all `lua/plugins/*.lua`

### Plugin Organization

Each file in `lua/plugins/` is a self-contained lazy.nvim plugin spec (table with deps, events, config). Lazy.nvim auto-discovers them via `{ import = "plugins" }`.

| File | Responsibility |
|------|---------------|
| `lsp.lua` | LSP configs (pyright, gopls, kotlin_language_server), nvim-cmp completion, Mason auto-install |
| `ui.lua` | Neo-tree file explorer, lualine statusline, bufferline tabs, colorscheme, fidget |
| `editor.lua` | Comment.nvim, autopairs, indent-blankline |
| `telescope.lua` | Fuzzy finder with fzf-native, smart git_files→find_files fallback |
| `treesitter.lua` | Syntax highlighting and parsing |
| `formatting.lua` | conform.nvim (format-on-save) + nvim-lint |
| `git.lua` | gitsigns (hunks, blame, diff) |
| `whichkey.lua` | Keymap discovery popup |
| `dap.lua` | Debug adapter protocol (debugpy, delve) |
| `neotest.lua` | Test runner (pytest, Go, Plenary adapters) |
| `terminal.lua` | toggleterm integrated terminal |

### Key Patterns

**LSP setup uses Neovim 0.11+ native API** - `vim.lsp.config()` and `vim.lsp.enable()` instead of the older lspconfig `setup()` pattern. Do not use the deprecated approach.

**Python venv detection** - Both `lsp.lua` and `neotest.lua` contain logic to find virtual environments by checking `.uv/bin/python`, `.venv/bin/python`, and `venv/bin/python` relative to the project root. Keep these in sync when modifying.

**Format-on-save** is handled by conform.nvim with language-specific formatters:
- Python: ruff (fix + format)
- Lua: stylua
- Go: gofmt + goimports
- Kotlin: ktlint

**Lazy loading** - Plugins use event triggers (`InsertEnter`, `BufReadPre`, `LspAttach`, etc.) for fast startup. Preserve this when adding new plugins.

## Adding a New Plugin

Create a new file in `lua/plugins/` returning a lazy.nvim spec table. It will be auto-imported. Use appropriate lazy-loading events to avoid slowing startup.

## Adding a New Language

1. `lsp.lua` - Add LSP server config via `vim.lsp.config()` + `vim.lsp.enable()`, add to Mason ensure_installed
2. `formatting.lua` - Add formatter in conform and linter in nvim-lint
3. `treesitter.lua` - Add parser to ensure_installed list
4. `dap.lua` / `neotest.lua` - Add debug adapter and test adapter if needed

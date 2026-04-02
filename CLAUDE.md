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
| `lsp.lua` | LSP configs (pyright, gopls, kotlin_language_server, jsonls+schemastore), nvim-cmp completion, Mason auto-install |
| `colorscheme.lua` | Darcula colorscheme + Python PyCharm-style treesitter highlight overrides |
| `ui.lua` | Neo-tree file explorer, lualine statusline (with winbar relative path, OS icon), bufferline tabs, fidget |
| `editor.lua` | mini.bufremove (safe buffer delete), Comment.nvim, autopairs, indent-blankline |
| `telescope.lua` | Fuzzy finder with fzf-native, smart git_files→find_files fallback |
| `treesitter.lua` | Syntax highlighting and parsing |
| `formatting.lua` | conform.nvim (format-on-save) + nvim-lint |
| `git.lua` | gitsigns (hunks, blame, diff) |
| `whichkey.lua` | Keymap discovery popup |
| `dap.lua` | Debug adapter protocol (debugpy, delve) |
| `neotest.lua` | Test runner (pytest, Go, Plenary adapters) |
| `terminal.lua` | toggleterm integrated terminal |
| `im-select.lua` | Auto-switch macOS IME to English in Normal mode (im-select.nvim) |

### Key Patterns

**LSP setup uses Neovim 0.11+ native API** - `vim.lsp.config()` and `vim.lsp.enable()` instead of the older lspconfig `setup()` pattern. Do not use the deprecated approach.

**Python venv detection** - Both `lsp.lua` and `neotest.lua` contain logic to find virtual environments by checking `.uv/bin/python`, `.venv/bin/python`, and `venv/bin/python` relative to the project root. Keep these in sync when modifying.

**Format-on-save** is handled by conform.nvim with language-specific formatters:
- Python: ruff (fix + format)
- Lua: stylua
- Go: gofmt + goimports
- Kotlin: ktlint
- JSON: jq (2-space indent)

**Buffer deletion uses mini.bufremove** - Never use `:bd` or `:bdelete` for buffer close keymaps. Neo-tree's `close_if_last_window = true` causes Neovim to exit when `:bd` removes the last non-sidebar window. Use `require("mini.bufremove").delete()` instead (preserves window layout). Bufferline's `close_command` and `right_mouse_command` are also configured to use mini.bufremove.

**Lazy loading** - Plugins use event triggers (`InsertEnter`, `BufReadPre`, `LspAttach`, etc.) for fast startup. Preserve this when adding new plugins.

**Korean IME auto-switch** - `im-select.nvim` requires the `im-select` CLI (`~/.local/bin/im-select`). It auto-switches to English (`com.apple.keylayout.ABC`) on `InsertLeave`/`CmdlineLeave` and restores the previous IME on `InsertEnter`. This prevents Korean characters from being inserted in Normal mode.

**Treesitter folding** - Code folding uses `vim.treesitter.foldexpr()` with `foldlevel=99` so all folds start expanded. Configured in `options.lua`.

**Plugin update notifications** - `lazy.lua` listens for the `LazyCheck` User autocmd and routes update counts through `vim.notify` (displayed by fidget.nvim as non-blocking notifications). The default `checker.notify` is disabled to prevent modal popups.

**Neo-tree lazy loading** - Neo-tree uses `cmd = "Neotree"` and `keys` spec for lazy loading instead of eagerly loading on startup. The `<leader>e` keymap is defined in the lazy.nvim `keys` table, not via `vim.keymap.set`.

**Lualine winbar** - lualine is configured with `winbar` and `inactive_winbar` sections showing relative file paths (`path = 1`) at the top of each window split.

**Lualine OS icon** - The statusline `lualine_x` section replaces the default `fileformat` component with a custom function that detects the actual OS via `vim.uv.os_uname().sysname` and shows a Nerd Font icon (Darwin=`\u{f179}`, Linux=`\u{f17c}`, Windows=`\u{f17a}`). Use Lua `\u{...}` escapes for Nerd Font icons instead of pasting literal glyphs (they may be stripped during file write).

**Pyright diagnosticMode** - Set to `"openFilesOnly"` (not `"workspace"`). Workspace mode causes pyright to scan the entire project and can get stuck on "1 file to analyze" indefinitely, especially without a detected virtual environment.

## Adding a New Plugin

Create a new file in `lua/plugins/` returning a lazy.nvim spec table. It will be auto-imported. Use appropriate lazy-loading events to avoid slowing startup.

## Adding a New Language

1. `lsp.lua` - Add LSP server config via `vim.lsp.config()` + `vim.lsp.enable()`, add to Mason ensure_installed
2. `formatting.lua` - Add formatter in conform and linter in nvim-lint
3. `treesitter.lua` - Add parser to ensure_installed list
4. `dap.lua` / `neotest.lua` - Add debug adapter and test adapter if needed

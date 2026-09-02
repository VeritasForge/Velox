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

`init.lua` → sets leader key (Space) → disables netrw → sets up stdin detection → loads three modules in order:
1. `lua/config/options.lua` - Vim options (2-space indent, system clipboard, etc.)
2. `lua/config/keymaps.lua` - Core keybindings (window nav, buffer management)
3. `lua/config/lazy.lua` - Bootstraps lazy.nvim, which auto-imports all `lua/plugins/*.lua`

### Plugin Organization

Each file in `lua/plugins/` is a self-contained lazy.nvim plugin spec (table with deps, events, config). Lazy.nvim auto-discovers them via `{ import = "plugins" }`.

| File | Responsibility |
|------|---------------|
| `lsp.lua` | LSP configs (pyright, gopls, kotlin_language_server, jsonls+schemastore), nvim-cmp completion, Mason auto-install |
| `markdown-preview.lua` | Browser-based live markdown preview with Mermaid rendering (`selimacerbas/markdown-preview.nvim`), manual `<leader>mp` toggle |
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
| `session.lua` | persistence.nvim 세션 자동 저장/복원 (디렉토리+브랜치별) |
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

**Lazy loading** - Plugins use event triggers (`InsertEnter`, `BufReadPre`, `LspAttach`, etc.) for fast startup. Preserve this when adding new plugins. Lazy-load 플러그인의 `config` 블록은 플러그인 로드 후에만 실행되므로, startup에서 실행되어야 하는 autocmd(예: VimEnter)는 `init` 블록에 배치할 것. `init` 안의 `require("plugin")`은 콜백 안에서 호출하면 lazy-load를 트리거하므로 안전.

**Korean IME auto-switch** - `im-select.nvim` requires the `macism` CLI (installed via `make install` from the `laishulu/homebrew` tap; lands on PATH at `/opt/homebrew/bin/macism`). It auto-switches to English (`com.apple.keylayout.ABC`) on `InsertLeave`/`CmdlineLeave` and restores the previous IME on `InsertEnter`. This prevents Korean characters from being inserted in Normal mode. `macism` replaced the older `im-select` binary because upstream `im-select.nvim` documents it as the only tool that reliably switches CJK input sources on macOS.

**Treesitter folding** - Code folding uses `vim.treesitter.foldexpr()` with `foldlevel=99` so all folds start expanded. Configured in `options.lua`.

**Plugin update notifications** - `lazy.lua` listens for the `LazyCheck` User autocmd and routes update counts through `vim.notify` (displayed by fidget.nvim as non-blocking notifications). The default `checker.notify` is disabled to prevent modal popups.

**Neo-tree lazy loading** - Neo-tree uses `cmd = "Neotree"` and `keys` spec for lazy loading instead of eagerly loading on startup. The `<leader>e` keymap is defined in the lazy.nvim `keys` table, not via `vim.keymap.set`.

**Lualine winbar** - lualine is configured with `winbar` and `inactive_winbar` sections showing relative file paths (`path = 1`) at the top of each window split.

**Lualine OS icon** - The statusline `lualine_x` section replaces the default `fileformat` component with a custom function that detects the actual OS via `vim.uv.os_uname().sysname` and shows a Nerd Font icon (Darwin=`\u{f179}`, Linux=`\u{f17c}`, Windows=`\u{f17a}`). Use Lua `\u{...}` escapes for Nerd Font icons instead of pasting literal glyphs (they may be stripped during file write).

**Pyright diagnosticMode** - Set to `"openFilesOnly"` (not `"workspace"`). Workspace mode causes pyright to scan the entire project and can get stuck on "1 file to analyze" indefinitely, especially without a detected virtual environment.

**Session auto-restore** - persistence.nvim이 VimLeavePre에서 디렉토리+브랜치별 세션을 자동 저장. `nvim` (인수 없이)로 같은 디렉토리에서 열면 VimEnter autocmd가 자동 복원. `nvim file.lua`처럼 파일을 지정하거나 stdin 파이프 시에는 복원하지 않음. `<leader>qs`로 수동 복원, `<leader>qd`로 저장 중지. 세션 저장 전 Neo-tree, DAP UI, toggleterm 버퍼를 자동 정리.

**netrw disabled** - `init.lua`에서 `vim.g.loaded_netrw = 1`로 비활성화. Neo-tree가 대체하며, 디렉토리 인수(`nvim .`)는 Neo-tree의 `init` 블록 VimEnter autocmd가 처리. netrw를 다시 활성화하지 않도록 주의.

**Treesitter v0.9.3 directive patch** - `nvim-treesitter` is pinned to tag `v0.9.3` (see `treesitter.lua`), whose bundled query directives (`set-lang-from-info-string!`, `downcase!`, `trim!`) assume `match[capture_id]` is a single `TSNode`. Neovim 0.11+ always wraps query captures in a list, so those directives crash with "attempt to call method 'range' (a nil value)" on markdown fenced-code-block info strings, bash heredocs, and (via `trim!`, used by markdown's `folds.scm` `@fold` captures) markdown code folding. `treesitter.lua`'s `config` function re-registers all three directives with `force = true`, unwrapping the list before calling `get_node_text` or `node:range()`. If the pinned tag is ever upgraded past the point upstream fixes this, these overrides can be removed.

**Neotest output panel replaces the auto-popup** - `output.open_on_run` is set to `false`, disabling neotest's default float that popped up over a failed test's position when results came in. Instead, `<leader>tr`/`<leader>tf` call `neotest.output_panel.open()` right after `neotest.run.run(...)`, so every run (pass or fail) opens the bottom split (`output_panel.open` config, default `botright split | resize 15`) and streams the raw pytest output into it as a terminal buffer. `status.virtual_text` still marks pass/fail per test in the buffer gutter.

**Diagnostic float on CursorHold** - A `CursorHold` autocmd in `lsp.lua` automatically opens a floating window (`vim.diagnostic.open_float`) showing the full diagnostic message at the cursor position. This supplements `virtual_text` which can be truncated on long lines. The float is `focusable = false` and `scope = "cursor"`. Responsiveness depends on `updatetime` (default 4s; lower to ~300ms in `options.lua` if needed).

**Markdown preview toggle state** - `markdown-preview.nvim`은 `:MarkdownPreview`/`:MarkdownPreviewStop`만 제공하고 토글 커맨드가 없다. `lua/plugins/markdown-preview.lua`가 어떤 버퍼를 프리뷰 중인지(`preview_buf`, 불리언이 아니라 bufnr) 직접 추적해 `<leader>mp` 하나로 시작/중지/재타겟을 처리한다 — 플러그인 기본값(`instance_mode = "takeover"`)이 서버 인스턴스 하나를 공유하기 때문에 불리언만으로는 다른 마크다운 버퍼로 옮겼을 때 잘못 꺼버리는 버그가 생긴다. 이 키맵은 `keys`의 `ft = "markdown"` 필드로 마크다운 버퍼에만 스코프된다. `whichkey.lua`의 해당 그룹 항목도 `cond`가 아니라 `FileType` 오토커맨드로 등록된다 — which-key의 `cond`는 로드 시 한 번만 평가되어 동적 버퍼 스코프에 쓸 수 없기 때문. Neovim에는 커스텀 커맨드라인 플래그(`-mp`류)를 추가할 방법이 없어서, 커맨드라인에서 바로 프리뷰를 켜고 싶으면 `nvim -c MarkdownPreviewOpen file.md`(표준 `-c` 플래그로 실행)를 쓴다 — 셸 별칭 `mdp`(`~/.zshrc`)가 이를 감싼다. `MarkdownPreviewOpen`은 `:MarkdownPreview`를 직접 호출하는 대신 `preview_buf`까지 같이 맞춰서, 이렇게 켠 뒤 처음 누르는 `<leader>mp`도 바로 꺼지도록 한다.

## Adding a New Plugin

Create a new file in `lua/plugins/` returning a lazy.nvim spec table. It will be auto-imported. Use appropriate lazy-loading events to avoid slowing startup.

## Adding a New Language

1. `lsp.lua` - Add LSP server config via `vim.lsp.config()` + `vim.lsp.enable()`, add to Mason ensure_installed
2. `formatting.lua` - Add formatter in conform and linter in nvim-lint
3. `treesitter.lua` - Add parser to ensure_installed list
4. `dap.lua` / `neotest.lua` - Add debug adapter and test adapter if needed

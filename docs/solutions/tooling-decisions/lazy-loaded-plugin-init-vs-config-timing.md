---
title: lazy.nvim init-vs-config timing and buffer-scoped keymap gotchas
date: 2026-08-09
category: tooling-decisions
module: neovim-config
problem_type: tooling_decision
component: tooling
severity: medium
applies_when:
  - "Adding a filetype-scoped keymap or which-key entry to a plugin lazy-loaded on an event other than the target filetype (e.g. VeryLazy, BufReadPre)"
  - "Wiring a toggle keymap for a plugin that only exposes separate start/stop commands"
  - "Writing a shell one-liner to check whether a named background process is still running"
tags: [lazy.nvim, which-key.nvim, init-vs-config, filetype-autocmd, buffer-scope, ps-grep-self-match, markdown-preview]
---

# lazy.nvim init-vs-config timing and buffer-scoped keymap gotchas

## Context

Adding a markdown preview feature (`selimacerbas/markdown-preview.nvim` + a hand-rolled `<leader>mp` toggle, plus a which-key.nvim entry for it) surfaced three separate, non-obvious lazy.nvim/which-key.nvim timing and scoping bugs — each one only caught by reading the actual plugin manager source and reproducing the exact failure scenario, not by inspecting the new code in isolation.

## Guidance

**1. `keys` spec's `ft` field creates a real buffer-scoped keymap, not just a lazy-load trigger.**

```lua
keys = {
  { "<leader>mp", my_toggle_fn, desc = "Toggle X", ft = "markdown" },
},
```

Per-key `ft` in a lazy.nvim `keys` entry makes lazy.nvim register the keymap from a `FileType` autocmd with `buffer = <matching buf>` (`lazy.nvim/lua/lazy/core/handler/keys.lua`), so the mapping only exists in buffers of that filetype — verified empirically with a headless Neovim reproduction (map present in a `.md` buffer, absent after switching to `.lua`).

**2. which-key.nvim's `cond` field is evaluated exactly once, at spec-drain time — not per popup open.**

```lua
-- WRONG: looks like it should dynamically hide/show based on current buffer,
-- but cond() runs once when the queued wk.add() spec is drained (shortly
-- after the VeryLazy event), then which-key discards it (mapping.cond = nil).
wk.add({
  { "<leader>m", group = "markdown", cond = function() return vim.bo.filetype == "markdown" end },
})
```

`which-key/mappings.lua` (`M.add`) evaluates `mapping.cond()` once and permanently drops the entry if it returns false at that moment — almost always "not markdown," since VeryLazy fires long before the user opens anything. **Fix:** register the entry from a `FileType` autocmd instead, and pass `buffer = event.buf` so which-key scopes visibility to that buffer (`which-key/buf.lua`: an unset/nil `buffer` field means "show in every buffer forever," which silently turns one filetype-specific group into a permanent, non-functional entry in every other filetype's popup after the first time it's triggered).

**3. A lazy-loaded plugin's `config()` only runs after its lazy-load event fires — `init()` runs at startup regardless.**

`event = "VeryLazy"` fires on `UIEnter`, which is documented to fire after `VimEnter`, which itself fires after Neovim has already loaded the buffers passed as command-line arguments (and thus already fired `FileType` for them). So `nvim somefile.md` sees its first buffer's `FileType` event **before** any `VeryLazy`-gated `config()` autocmd registration exists — a `FileType` autocmd registered inside `config()` misses that very first buffer. Register it in `init()` instead (this repo already uses this exact pattern in `session.lua` for a `VimEnter` autocmd — `init` runs pre-load, and `require(plugin)` inside the callback is safe because it only triggers the lazy-load when the callback actually fires):

```lua
init = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(event)
      require("which-key").add({
        { "<leader>m", group = "markdown", buffer = event.buf },
      })
    end,
  })
end,
```

**4. Classic `ps`/`grep`/`lsof` self-match and header-match footguns.**

- `ps aux | grep <name>` always matches at least one line: grep's own process, whose argv contains the search string. It will report "found" even when nothing else is running. Use `pgrep -f <name>` (or `pgrep -fl` to also print the matched command) — it excludes its own process.
- `lsof -iTCP -sTCP:LISTEN | grep -iE 'node|lua'` can false-positive on `lsof`'s own column header line (`... TYPE DEVICE SIZE/OFF NODE NAME`) — `NODE` there is the inode-number column, unrelated to Node.js, but case-insensitive grep matches it whenever *any* TCP listener exists on the machine.
- Unquoted `grep -i node\|lua` (backslash-escaped pipe, no quotes) is not regex alternation under BSD grep/zsh — it searches for the literal string `node|lua` and virtually never matches, producing a false negative instead.

**5. Third-party plugin internals worth checking directly instead of assuming, when a plugin only exposes start/stop (not toggle) commands and reports failure via `vim.notify` rather than a Lua error:**

A hand-rolled toggle wrapper that tracks "am I running" via a local variable needs a reliable success signal from the wrapped plugin. `markdown-preview.nvim`'s `M._server_instance` is only set on the "primary" instance path — a "takeover secondary" (another Neovim instance already owns the shared preview server) succeeds without ever setting it. `M._is_primary` (set to `true` or `false` on every successful start, `nil` on every failure path and after `M.stop()`) is the field that's actually reliable across both roles. Read the actual dependency source (`grep -n "^function M\.\|^M\."` on the plugin's init.lua) rather than guessing which internal field signals success — plugins built for "shared server across multiple editor instances" scenarios often have more than one success path.

## Why This Matters

Each of these is easy to get subtly wrong in a way that only manifests in a specific, easy-to-miss scenario: opening a markdown file *directly at startup* (not from within an already-running session), switching between multiple markdown buffers, or checking a background process on a machine that already has *something else* listening on a port. None of them produce an error on the "obvious" happy path (open Neovim, open a file, edit it), which is exactly why they survived multiple rounds of manual testing before being caught by reading the actual plugin-manager source and reproducing the exact cold-start / multi-buffer / multi-instance scenario.

## When to Apply

- Any time a keymap or which-key entry is meant to be scoped to a filetype/buffer, on a plugin that itself lazy-loads on a *different* event (VeryLazy, BufReadPre, a command, etc.).
- Any time a wrapper is built around a third-party plugin's commands to add behavior (like toggling) the plugin doesn't natively provide — verify the wrapper's state-tracking against the plugin's actual success/failure signaling, not just its documented happy path.
- Any shell command checking "is process X still running" — default to `pgrep -f`, never `ps aux | grep`.

## Examples

Before (buggy — evaluated once, no buffer scope):
```lua
wk.add({
  { "<leader>m", group = "markdown", cond = function() return vim.bo.filetype == "markdown" end },
})
```

After (correct — registered per-buffer via FileType, scoped to that buffer):
```lua
init = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(event)
      require("which-key").add({
        { "<leader>m", group = "markdown", buffer = event.buf },
        { "<leader>mp", desc = "Toggle preview", buffer = event.buf },
      })
    end,
  })
end,
```

Verification command for the `ps`/`grep` self-match trap:
```bash
# Always "finds" something, even with nothing running:
ps aux | grep live-server   # prints grep's own process line

# Correct:
pgrep -fl live-server        # empty / exit 1 when nothing is running
```

## Related

- `lua/plugins/markdown-preview.lua`, `lua/plugins/whichkey.lua` — the implementation these lessons came from
- `lua/plugins/session.lua` — the pre-existing `init` + `VimEnter` pattern this repo already established, reused here for `init` + `FileType`
- `docs/superpowers/specs/2026-08-09-markdown-preview-mermaid-design.md`, `docs/superpowers/plans/2026-08-09-markdown-preview-mermaid.md` — full design/plan history including the ce-doc-review and rl-verify findings that led to these fixes

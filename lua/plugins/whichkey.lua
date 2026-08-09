return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    -- init runs at startup, before the VeryLazy-gated config() below. A
    -- markdown file passed on the command line fires FileType before
    -- VeryLazy ever does (VeryLazy waits for UIEnter, which is itself after
    -- VimEnter and buffer loading), so registering this autocmd inside
    -- config() would miss that first buffer entirely. require() inside the
    -- callback is safe -- it only triggers which-key's lazy-load when a
    -- markdown buffer is actually entered. `buffer = event.buf` scopes the
    -- popup entries to that buffer -- without it, which-key shows "markdown"
    -- in every filetype's popup forever after the first markdown file opens.
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
    config = function()
      local wk = require("which-key")
      wk.setup({})

      wk.add({
        { "<leader>f", group = "find/search" },
        { "<leader>ff", desc = "Find files" },
        { "<leader>fg", desc = "Live grep" },
        { "<leader>fb", desc = "Buffers" },
        { "<leader>/", desc = "Fuzzy find in buffer" },
        { "<leader>e", desc = "Explorer" },
        { "<leader>t", group = "terminal" },
        { "<leader>tt", desc = "Toggle terminal" },

        { "<leader>c", group = "code" },
        { "<leader>cf", desc = "Format" },
        { "<leader>cl", desc = "Lint" },

        { "<leader>h", group = "git(hunk)" },
        { "<leader>hs", desc = "Stage hunk" },
        { "<leader>hr", desc = "Reset hunk" },
        { "<leader>hS", desc = "Stage buffer" },
        { "<leader>hu", desc = "Undo stage hunk" },
        { "<leader>hp", desc = "Preview hunk" },
        { "<leader>hb", desc = "Toggle blame" },
        { "<leader>hd", desc = "Diff this" },

        { "<leader>q", group = "session" },
        { "<leader>qs", desc = "Restore session (cwd)" },
        { "<leader>ql", desc = "Restore last session" },
        { "<leader>qd", desc = "Stop session save" },

        { "<leader>d", group = "debug" },
        { "<leader>db", desc = "Toggle breakpoint" },
        { "<leader>dB", desc = "Conditional breakpoint" },
        { "<leader>dr", desc = "REPL" },
        { "<leader>du", desc = "DAP UI" },
        { "<leader>dt", desc = "Go test debug (tags)" },
      })
    end,
  },
}

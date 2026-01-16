return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
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
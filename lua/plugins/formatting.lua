return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters = {
          ruff_fix = {
            command = "ruff",
            args = { "check", "--fix", "--exit-zero", "$FILENAME" },
            stdin = false,
          },
          ruff_format = {
            command = "ruff",
            args = { "format", "$FILENAME" },
            stdin = false,
          },
          ktlint_format = {
            command = "ktlint",
            args = { "-F", "$FILENAME" },
            stdin = false,
          },
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_fix", "ruff_format" },
          go = { "gofmt", "goimports" },
          kotlin = { "ktlint_format" },
        },
        format_on_save = function(_)
          return { timeout_ms = 2000, lsp_fallback = false }
        end,
      })

      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        conform.format({ async = true })
      end, { desc = "Format (conform)" })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        go = { "golangcilint" },
        kotlin = { "ktlint" },
      }

      local function try_lint() pcall(lint.try_lint) end

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged" }, {
        callback = try_lint,
      })

      vim.keymap.set("n", "<leader>cl", try_lint, { desc = "Lint (nvim-lint)" })
    end,
  },
}
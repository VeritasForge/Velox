return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-plenary",
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            -- .uv 환경 자동 인식을 위해 python 명령어 경로 지정 가능
            python = function()
              local cwd = vim.fn.getcwd()
              local possible_venvs = {
                cwd .. "/.uv/bin/python",
                cwd .. "/.venv/bin/python",
                cwd .. "/venv/bin/python",
              }
              for _, p in ipairs(possible_venvs) do
                if vim.fn.executable(p) == 1 then return p end
              end
              return "python3"
            end,
          }),
          require("neotest-go")({
            experimental = { test_table = true },
            args = { "-count=1", "-timeout=60s" },
          }),
          require("neotest-plenary"),
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
      })

      -- Keymaps
      local map = vim.keymap.set
      map("n", "<leader>tr", function() neotest.run.run() end, { desc = "Run nearest test" })
      map("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run file tests" })
      map("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle test summary" })
      map("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Show test output" })
      map("n", "<leader>tp", function() neotest.output_panel.toggle() end, { desc = "Toggle output panel" })
      map("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
    end,
  },
}
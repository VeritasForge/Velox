return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      { "mason-org/mason.nvim" },
      { "jay-babu/mason-nvim-dap.nvim", dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" } },
      { "mfussenegger/nvim-dap-python" },
      { "leoluz/nvim-dap-go" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP UI Toggle" })

      require("mason-nvim-dap").setup({
        ensure_installed = { "debugpy", "delve" },
        automatic_installation = true,
      })

      local function find_python()
        local cwd = vim.fn.getcwd()
        local candidates = {
          cwd .. "/.venv/bin/python",
          cwd .. "/venv/bin/python",
          cwd .. "/.venv/Scripts/python.exe",
          cwd .. "/venv/Scripts/python.exe",
        }
        for _, p in ipairs(candidates) do
          if vim.fn.executable(p) == 1 then return p end
        end
        if vim.fn.executable("python3") == 1 then return vim.fn.exepath("python3") end
        if vim.fn.executable("python") == 1 then return vim.fn.exepath("python") end
        return nil
      end

      local py = find_python()
      if py then pcall(function() require("dap-python").setup(py) end) end

      pcall(function() require("dap-go").setup() end)

      vim.keymap.set("n", "<leader>dt", function()
        local tags = vim.fn.input("Go build tags (optional): ")
        local opts = {}
        if tags ~= "" then opts.buildFlags = "-tags=" .. tags end
        require("dap-go").debug_test(opts)
      end, { desc = "DAP Go: debug test (tags)" })
    end,
  },
}
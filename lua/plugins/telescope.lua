return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- 빌드 필요 :contentReference[oaicite:2]{index=2}
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          preview = { hide_on_startup = false },
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.95,
            height = 0.90,
          },
          file_ignore_patterns = {
            "node_modules/",
            ".git/",
            "dist/",
            "build/",
            ".venv/",
            "target/",
          },
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      pcall(telescope.load_extension, "fzf")

      -- Ctrl+P: git repo면 git_files 우선, 아니면 find_files
      vim.keymap.set("n", "<C-p>", function()
        local ok = pcall(builtin.git_files, { show_untracked = true })
        if not ok then
          builtin.find_files({ hidden = true })
        end
      end, { desc = "Find files (Ctrl+P)" })

      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (project)" })

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
      vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })
    end,
  },
}
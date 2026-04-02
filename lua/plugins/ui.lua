return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    init = function()
      -- netrw 비활성화 상태에서 nvim . (디렉토리 인수) 처리
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 1 then
            local arg = vim.fn.argv(0)
            local stat = vim.uv.fs_stat(arg)
            if stat and stat.type == "directory" then
              vim.cmd("Neotree dir=" .. vim.fn.fnameescape(arg))
            end
          end
        end,
        nested = true,
      })
    end,
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true, -- OS 레벨 파일 감시로 외부 변경 자동 감지
          filtered_items = { hide_dotfiles = false, hide_gitignored = true },
        },
        window = { position = "left", width = 32 },
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { globalstatus = true, icons_enabled = true, theme = "auto" },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = {
            "encoding",
            function()
              local icons = {
                Darwin = "\u{f179}",  -- nf-fa-apple
                Linux  = "\u{f17c}",  -- nf-fa-linux
                Windows = "\u{f17a}", -- nf-fa-windows
              }
              return icons[vim.uv.os_uname().sysname] or ""
            end,
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        winbar = {
          lualine_c = {
            { "filename", path = 1, icons_enabled = true }, -- path=1: 프로젝트 기준 상대 경로
          },
        },
        inactive_winbar = {
          lualine_c = {
            { "filename", path = 1, icons_enabled = true },
          },
        },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          close_command = function(n) require("mini.bufremove").delete(n, false) end,
          right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
          offsets = {
            { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
          },
        },
      })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
    end,
  },

  -- LSP 진행 상태 UI
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = { notification = { window = { winblend = 0 } } },
  },
}
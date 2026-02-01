return {
  -- 윈도우 레이아웃을 유지하면서 버퍼 삭제 (:bd 대체)
  {
    "echasnovski/mini.bufremove",
    version = false,
    keys = {
      { "<leader>x", function() require("mini.bufremove").delete(0, false) end, desc = "Close Buffer" },
    },
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({ check_ts = true })

      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = { char = "▏" },
      scope = { enabled = true },
    },
  },
}
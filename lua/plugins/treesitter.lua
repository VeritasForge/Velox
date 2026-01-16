return {
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.3", 
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "lua",
        "vim",
        "bash",
        "python",
        "go",
        "kotlin",
        "json",
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
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

      -- v0.9.3's directive handlers assume match[capture_id] is a single TSNode, but Neovim 0.11+ always wraps captures in a list, so node:range() fails with "attempt to call method 'range' (a nil value)" on markdown code fences and bash heredocs.
      local function unwrap_node(node)
        return (type(node) == "table") and node[1] or node
      end

      local non_filetype_aliases = { ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript" }
      vim.treesitter.query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
        local node = unwrap_node(match[pred[2]])
        if not node then
          return
        end
        local lang = vim.treesitter.get_node_text(node, bufnr):lower()
        metadata["injection.language"] = vim.filetype.match({ filename = "a." .. lang }) or non_filetype_aliases[lang] or lang
      end, { force = true })

      vim.treesitter.query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
        local id = pred[2]
        local node = unwrap_node(match[id])
        if not node then
          return
        end
        local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
        metadata[id] = metadata[id] or {}
        metadata[id].text = string.lower(text)
      end, { force = true })
    end,
  },
}
local preview_buf = nil -- nil = off; otherwise the bufnr currently being previewed

local function toggle_markdown_preview()
  local current = vim.api.nvim_get_current_buf()
  if preview_buf == current then
    vim.cmd("MarkdownPreviewStop")
    preview_buf = nil
  else
    vim.cmd("MarkdownPreview")
    -- MarkdownPreview reports failures (bad host, content read error, port
    -- bind failure) via vim.notify rather than a Lua error, so :MarkdownPreview
    -- always returns normally. M._is_primary is set to true or false on every
    -- successful start -- primary, or "takeover secondary" when another
    -- Neovim instance already owns the server -- and stays nil on every
    -- failure path and after M.stop(), so it's a reliable success signal
    -- across both takeover roles (unlike M._server_instance, which secondaries
    -- never set).
    if require("markdown_preview")._is_primary ~= nil then
      preview_buf = current
    end
  end
end

return {
  "selimacerbas/markdown-preview.nvim",
  ft = "markdown",
  dependencies = { "selimacerbas/live-server.nvim" },
  keys = {
    { "<leader>mp", toggle_markdown_preview, desc = "Toggle markdown preview", ft = "markdown" },
  },
  config = function()
    require("markdown_preview").setup({
      port = 0,
      default_theme = "dark",
      open_browser = true,
      mermaid_renderer = "js",
    })
  end,
}

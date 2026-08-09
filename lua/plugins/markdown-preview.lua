local preview_buf = nil -- nil = off; otherwise the bufnr currently being previewed

local function start_markdown_preview(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
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
    preview_buf = bufnr
    -- The plugin never clears its own state when the previewed buffer
    -- disappears (e.g. via this repo's mini.bufremove close keymap instead
    -- of toggling preview off first), so the server would otherwise keep
    -- running orphaned until the next toggle happens to retarget it.
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
      buffer = bufnr,
      once = true,
      callback = function()
        if preview_buf == bufnr then
          vim.cmd("MarkdownPreviewStop")
          preview_buf = nil
        end
      end,
    })
  end
end

local function toggle_markdown_preview()
  local current = vim.api.nvim_get_current_buf()
  if preview_buf == current then
    vim.cmd("MarkdownPreviewStop")
    preview_buf = nil
  else
    start_markdown_preview(current)
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
    -- Lets `nvim -c MarkdownPreviewOpen file.md` (or a shell alias wrapping
    -- it) open straight into a running preview, syncing preview_buf so the
    -- very first <leader>mp press afterward correctly toggles it off.
    vim.api.nvim_create_user_command("MarkdownPreviewOpen", function()
      start_markdown_preview()
    end, {})
  end,
}

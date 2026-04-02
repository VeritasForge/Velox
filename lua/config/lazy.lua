local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})

-- 플러그인 업데이트 감지 시 fidget으로 non-blocking 알림
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyCheck",
  callback = function()
    local updates = require("lazy.status").updates()
    if updates then
      vim.notify("📦 " .. updates, vim.log.levels.INFO)
    end
  end,
})
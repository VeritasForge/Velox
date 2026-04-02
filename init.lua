vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- netrw 비활성화 (Neo-tree가 대체)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- stdin 파이프 감지 (세션 자동 복원 방지용)
vim.api.nvim_create_autocmd("StdinReadPre", {
  callback = function()
    vim.g.started_with_stdin = true
  end,
})

require("config.options")
require("config.keymaps")
require("config.lazy")
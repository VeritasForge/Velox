local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>w", "<cmd>w<cr>", opts)
map("n", "<leader>q", "<cmd>q<cr>", opts)

-- 탭(버퍼) 관리 (<leader>x는 mini.bufremove가 담당)
map("n", "<leader>ba", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close All Other Buffers" })
map("n", "<leader>n", "<cmd>enew<cr>", { desc = "New Empty Buffer" })

-- Cmd+/ 주석 토글 (Comment.nvim)
map("n", "<D-/>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle Comment" })
map("v", "<D-/>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", { desc = "Toggle Comment" })

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- 검색 하이라이트 자동 제거 (Insert 모드 종료 시)
map("i", "<Esc>", "<Esc><cmd>nohlsearch<cr>", { desc = "Exit insert and clear search highlight" })
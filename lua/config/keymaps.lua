local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>w", "<cmd>w<cr>", opts)
map("n", "<leader>q", "<cmd>q<cr>", opts)

-- 탭(버퍼) 관리
map("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close Buffer" })
map("n", "<leader>n", "<cmd>enew<cr>", { desc = "New Empty Buffer" })

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
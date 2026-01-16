local opt = vim.opt

opt.number = true
opt.relativenumber = false -- 절대 라인 번호만 사용 (상대 번호 끄기)
opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 200
opt.timeoutlen = 400

opt.splitright = true
opt.splitbelow = true
opt.hidden = true

opt.ignorecase = true
opt.smartcase = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
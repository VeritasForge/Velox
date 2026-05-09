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

-- 외부에서 파일이 변경되면 자동 리로드 (실제 트리거는 autocmds.lua의 checktime)
opt.autoread = true

opt.ignorecase = true
opt.smartcase = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

-- Treesitter 기반 코드 접기 (folding)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- 파일 열 때 모든 폴드 펼친 상태로 시작
opt.foldlevelstart = 99

-- 세션 복원 시 저장할 항목 (folds 제외: treesitter foldexpr과 충돌 방지)
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
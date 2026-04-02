return {
  "folke/persistence.nvim",
  event = "BufReadPre", -- 파일을 열면 세션 자동 저장 활성화
  opts = {
    need = 1, -- 최소 1개 파일 버퍼가 있어야 저장 (빈 세션 방지)
    branch = true, -- git 브랜치별 세션 분리 (main/master 제외)
  },
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session (cwd)" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Stop Session Save" },
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    -- 자동 복원: nvim을 인수 없이 열었을 때만
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
      callback = function()
        if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
          persistence.load()
        end
      end,
      nested = true, -- 복원된 버퍼의 autocmd도 발동되도록
    })

    -- 세션 저장 전 특수 버퍼 정리
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        -- Neo-tree 닫기
        pcall(vim.cmd, "Neotree close")
        -- 특수 버퍼 삭제 (DAP UI, toggleterm 등)
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local ft = vim.bo[buf].filetype
            if
              vim.startswith(ft, "dapui_") -- dapui_scopes, dapui_breakpoints 등 6종
              or ft == "dap-repl"
              or ft == "dap-float"
              or ft == "toggleterm"
            then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end
      end,
    })
  end,
}

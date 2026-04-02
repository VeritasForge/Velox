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
  -- init은 startup 시 실행 (플러그인 로드 전). VimEnter 콜백 안의
  -- require("persistence")가 lazy-load를 트리거하므로 정상 작동.
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
      callback = function()
        if vim.g.started_with_stdin then
          return
        end
        local argc = vim.fn.argc()
        if argc == 0 then
          require("persistence").load()
        elseif argc == 1 then
          local arg = vim.fn.argv(0)
          local stat = vim.uv.fs_stat(arg)
          if stat and stat.type == "directory" then
            vim.cmd("bwipeout")
            require("persistence").load()
          end
        end
      end,
      nested = true,
    })
  end,
  config = function(_, opts)
    require("persistence").setup(opts)

    -- 세션 저장 전 특수 버퍼 정리
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        pcall(vim.cmd, "Neotree close")
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local ft = vim.bo[buf].filetype
            if
              vim.startswith(ft, "dapui_")
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

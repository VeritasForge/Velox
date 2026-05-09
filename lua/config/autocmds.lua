-- 외부 파일 변경 자동 감지 및 버퍼 리로드
-- options.lua의 autoread = true 와 짝꿍. autoread만으로는 트리거가 부족하므로
-- 포커스 변경/버퍼 진입/커서 정지 시점에 명시적으로 checktime을 호출한다.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  desc = "Check for external file changes",
  pattern = "*",
  command = "checktime",
})

-- 외부 변경으로 버퍼가 리로드된 직후 사용자에게 알림 (몰래 바뀌면 위험하므로)
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  desc = "Notify when buffer reloaded due to external change",
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

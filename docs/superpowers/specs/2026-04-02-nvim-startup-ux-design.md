# Neovim Startup UX Improvement

## Summary

Neovim 시작 시 두 가지 UX 개선:
1. Plugin Updates 알림을 blocking → non-blocking(fidget.nvim)으로 변경
2. Neo-tree file explorer를 시작 시 자동 열림 → lazy loading으로 변경

## Changes

### 1. Plugin Updates: fidget.nvim non-blocking notification

**File**: `lua/config/lazy.lua`

- `checker.notify = false` 설정으로 기본 blocking 알림 비활성화
- `LazyCheck` autocmd로 업데이트 감지 시 `vim.notify` 호출
- fidget.nvim이 `vim.notify`를 override하므로 우측 하단에 toast 스타일로 표시

### 2. Neo-tree: lazy loading

**File**: `lua/plugins/ui.lua`

- `cmd = "Neotree"` 추가로 명령어 실행 시에만 로드
- `keys` 필드로 keymap을 lazy.nvim에 위임 (config 밖으로 이동)
- 시작 시 로드되지 않으므로 file tree가 보이지 않음
- `<leader>e`로 필요 시 토글

## Verification

- `nvim` 실행 시 바로 빈 편집 화면 진입 (file tree 없음, Enter 불필요)
- 플러그인 업데이트가 있으면 우측 하단에 잠깐 알림 표시 후 자동 사라짐
- `<leader>e`로 file tree 정상 토글

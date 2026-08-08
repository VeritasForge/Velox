# Markdown Preview with Mermaid Rendering

## Summary

마크다운 파일을 편집하면서 다른 창(브라우저 탭)에서 실시간으로 렌더링 결과를 확인하는 기능을 추가한다. Mermaid 다이어그램 렌더링을 필수로 지원한다.

`<leader>mp`로 토글하는 수동 실행 방식이며, `.md` 파일을 열 때 자동으로 켜지지는 않는다.

## Why this plugin

`markdown-preview.nvim`(iamcco)과 `peek.nvim`(toppair)은 한때 널리 쓰였지만, GitHub API로 확인한 결과 둘 다 2024년 이후 커밋이 없고 이슈가 각각 264개/38개 쌓여 있어 사실상 방치된 상태다(2026-08-09 기준).

대신 `selimacerbas/markdown-preview.nvim` + `selimacerbas/live-server.nvim`을 채택한다:

- 최근 커밋이 1개월 이내(2026-07-07)이며, 커밋 메시지가 실사용자 이슈 번호(#17, #26, #27)를 근거로 원인과 수정 내용을 남기는 등 활발히 대응하고 있다.
- 순수 Lua로 작성되어 npm/Node.js/빌드 스텝이 전혀 필요 없다.
- Mermaid는 브라우저에 로드되는 mermaid.js가 클라이언트 사이드에서 그리므로 GitHub 등에서 보는 렌더링과 동일한 정확도를 갖는다.

**대안으로 검토했으나 채택하지 않은 방식**: `delphinus/md-render.nvim`은 Neovim 창 자체를 `:split`으로 나눠 그 안에 Mermaid를 이미지로 렌더링하는, 브라우저를 전혀 열지 않는 방식이다. 하지만 Mermaid 렌더링에 필요한 mermaid-cli(mmdc)가 내부적으로 매번 헤드리스 크롬을 띄우는 구조라 공식 문서에도 "첫 실행이 상당히 느리다"고 명시되어 있고, 이 프로젝트 최소 버전(v0.11+)보다 높은 Neovim 0.12를 요구한다. 브라우저 창을 별도로 배치하는 불편함을 감수하더라도 의존성이 가볍고 렌더링이 안정적인 쪽을 우선했다.

## Changes

### 1. 신규 파일: `lua/plugins/markdown-preview.lua`

```lua
{
  "selimacerbas/markdown-preview.nvim",
  ft = "markdown",
  dependencies = { "selimacerbas/live-server.nvim" },
  config = function()
    require("markdown_preview").setup({
      port = 0,                  -- 자동 할당, 다른 로컬 서버와 포트 충돌 방지
      default_theme = "dark",    -- 이 저장소의 Darcula 다크 테마와 통일
      open_browser = true,
      mermaid_renderer = "js",   -- 브라우저 내장 mermaid.js, 추가 설치 프로그램 없음
    })
  end,
}
```

- `ft = "markdown"`으로 지연 로드하여 시작 속도에 영향을 주지 않는다(이 저장소의 Lazy loading 원칙 유지).
- 플러그인은 `:MarkdownPreview`(시작)와 `:MarkdownPreviewStop`(중지)만 제공하고 토글 커맨드가 없으므로, 켜짐 여부를 불리언 상태로 추적해 두 커맨드 중 하나를 호출하는 토글 함수를 이 파일 안에 정의하고 `<leader>mp`에 매핑한다.

### 2. `lua/plugins/whichkey.lua`

- `<leader>m` 그룹("markdown") 추가
- `<leader>mp`("Toggle preview") 항목 추가

### 3. `CLAUDE.md`

- Plugin Organization 표에 `markdown-preview.lua` 행 추가
- Key Patterns에 "플러그인이 토글 커맨드를 제공하지 않아 불리언 상태로 직접 추적한다"는 노트 추가 (이 저장소가 mini.bufremove 사용 이유 등 비직관적 동작을 Key Patterns에 남기는 기존 관례를 따름)

## Data Flow

```
.md 파일 열기 → ft=markdown 이벤트로 플러그인 지연 로드 (서버는 아직 안 뜸)
      │
<leader>mp → 상태=꺼짐이면 :MarkdownPreview 실행
      │
live-server.nvim이 로컬호스트에 서버 기동 → 기본 브라우저 탭 자동 오픈
      │
타이핑 → TextChanged/TextChangedI/InsertLeave 이벤트 → 약 0.3초 디바운스
      │
SSE(Server-Sent Events)로 변경분을 브라우저에 실시간 푸시
      │
브라우저가 재렌더링, Mermaid 코드블록은 브라우저 내 mermaid.js가 그 자리에서 그림
      │
<leader>mp → 상태=켜짐이면 :MarkdownPreviewStop 실행 → 서버 종료, 상태 리셋
```

## Considerations / Risks

- **유지보수 리스크**: 채택한 플러그인은 star 수가 많지 않은 신생 프로젝트(183개)다. 현재는 활발하지만 향후 관리가 끊길 가능성을 배제할 수 없다. 문제가 생기면 이 문서의 "Why this plugin" 비교 기준으로 대안을 재검토한다.
- **오프라인 환경**: mermaid.js는 기본적으로 CDN에서 로드된다. 마크다운 원문은 로컬 서버라 외부로 나가지 않지만, 인터넷이 끊기면 다이어그램만 그려지지 않을 수 있다. 로컬 번들 옵션 존재 여부는 구현 중 실제로 필요해지면 확인한다.
- **Neovim 종료 시 서버 잔류 여부**: 문서에 `VimLeavePre` 자동 정리 언급이 없다. 구현 중 실제로 서버가 남는지 확인하고, 남으면 종료 시 자동으로 `:MarkdownPreviewStop`을 호출하는 autocmd를 추가한다.
- **마크다운이 아닌 파일에서 키를 눌렀을 때**: `ft = "markdown"` 조건으로 애초에 플러그인이 로드되지 않으므로 별도 방어 코드가 불필요하다.

## Verification

설정 파일 변경이므로 자동화 테스트 대신 수동 검증 절차로 완료를 확인한다:

1. Mermaid 코드블록이 포함된 테스트 `.md` 파일을 열고 `<leader>mp` → 브라우저가 뜨고 다이어그램이 그려지는지 확인
2. Neovim에서 텍스트 수정 → 저장하지 않아도 브라우저가 자동 갱신되는지 확인
3. `<leader>mp` 재입력 → 프리뷰가 꺼지는지 확인
4. `:checkhealth` 실행 → 관련 에러/경고 없는지 확인
5. 마크다운이 아닌 파일로 `nvim` 실행 → 시작 속도에 체감 영향 없는지 확인

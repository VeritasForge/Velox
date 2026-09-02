# ⚡️ Velox

> **"Swift, Rapid."** (Latin)

**Velox**는 Neovim의 압도적인 **속도**와 VS Code의 **현대적인 사용성**을 결합한 하이브리드 에디터 설정입니다. Neovim v0.11+을 기반으로 하며, 복잡한 설정 없이도 직관적으로 사용할 수 있도록 설계되었습니다.

## 🛠️ 필수 요구 사항

- **Neovim**: v0.11.5 이상 권장
- **의존성 도구**:
  - `ripgrep` (텍스트 검색)
  - `fd` (파일 탐색)
  - `cmake`, `make` (fzf 빌드용)

> **팁**: 포함된 `Makefile`을 사용하면 위 도구들을 한번에 설치할 수 있습니다. (아래 "빠른 설치" 참고)

## ⚡️ 빠른 설치 (Automated Installation)

`make` 명령어를 통해 OS(Mac/Ubuntu)에 맞춰 필수 프로그램을 자동으로 설치할 수 있습니다.

```bash
# 설치 스크립트 실행
make install
```

이 명령어는 다음 작업을 수행합니다:
- **macOS**: `Homebrew`를 사용하여 Neovim(HEAD), ripgrep, fd, cmake, go, macism(한글 입력기 자동 전환용) 설치
- **Ubuntu**: `apt` 및 `ppa:neovim-ppa/unstable`을 사용하여 최신 Neovim 및 도구(golang-go 포함) 설치
  - *Ubuntu 주의*: `fd` 명령어를 사용하기 위해 `~/.local/bin`에 심볼릭 링크를 생성합니다. 해당 경로가 `PATH`에 포함되어 있는지 확인해주세요.

## 📂 폴더 구조

```text
~/.config/nvim/
├── init.lua          # 메인 엔트리
├── lua/
│   ├── config/       # 기본 설정 (옵션, 키맵, lazy 로더)
│   └── plugins/      # 개별 플러그인 설정
└── README.md         # 이 가이드 파일
```

## ⌨️ 주요 단축키 가이드

대부분의 명령어는 **Leader Key**인 `<Space>` 키를 먼저 누른 후 시작합니다.

### 1. 📂 파일 탐색 및 관리 (Navigation & Tabs)

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`<Ctrl> + p`** | **스마트 파일 찾기** (프로젝트 내 파일 검색) |
| `<Space> + e` | **파일 탐색기** (Neo-tree) 토글 |
| &nbsp; | *탐색기 너비 조절: 창에서 `5>` (확대), `5<` (축소)* |
| `<Space> + ff` | 일반 파일 찾기 (숨김 파일 포함) |
| `<Space> + fg` | **전체 텍스트 검색** (Live Grep) |
| `<Space> + fb` | 열린 버퍼 목록에서 찾기 |
| `<Space> + fh` | 도움말(Help) 검색 |
| `<Space> + /` | 현재 버퍼 내에서 퍼지 검색 |
| `<Shift> + l / h` | **다음 / 이전 탭으로 이동** |
| **`<Space> + x`** | **현재 탭(버퍼) 닫기** |
| `<Space> + ba` | **다른 모든 탭 닫기** (Close Others) |
| `<Space> + bA` | 열린 버퍼 전체 닫기 (Close All, 안전하게) |
| `<Space> + n` | 새 빈 문서(Buffer) 열기 |
| `:ls` | 열린 버퍼 목록 보기 |
| `:b <이름>` | 특정 버퍼로 이동 (탭 자동완성 지원) |

### 2. 🪟 창 분할 및 관리 (Window Splitting)

| 단축키/명령어 | 기능 설명 |
| :--- | :--- |
| `:vs` 또는 `<Ctrl>+w v` | **좌우 분할** (Vertical Split) |
| `:sp` 또는 `<Ctrl>+w s` | **상하 분할** (Horizontal Split) |
| `<Ctrl> + h/j/k/l` | **분할된 창 사이 이동** |
| `<Ctrl>+w >` / `<` | 창 너비 조절 |
| `<Space> + q` 또는 `<Ctrl>+w c` | **분할된 창 닫기** |

### 3. 📦 코드 접기 (Folding)

Treesitter 기반으로 함수, 클래스, JSON 블록 등을 자동으로 접고 펼 수 있습니다.

| 단축키 | 기능 설명 |
| :--- | :--- |
| `za` | 현재 위치 **폴드 토글** (접기/펼치기) |
| `zc` | 현재 폴드 접기 |
| `zo` | 현재 폴드 펼치기 |
| `zM` | **전체 접기** |
| `zR` | **전체 펼치기** |

### 4. 🧠 코드 지능형 기능 (LSP)

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`g + d`** | **정의로 이동** (Definition) |
| `g + D` | 선언으로 이동 (Declaration) |
| `g + r` | 참조 찾기 (References) |
| `g + i` | 구현으로 이동 (Implementation) |
| **`K`** | **문서 보기** (Hover) |
| `<Space> + rn` | 이름 변경 (Rename) |
| `<Space> + ca` | 코드 액션 (Code Action) |
| `<Space> + ds` | 현재 줄 진단 메시지 보기 (Line Diagnostics) |
| `[d` / `]d` | 이전 / 다음 에러 위치 이동 |
| **`<Ctrl> + o`** | **이전 위치로 돌아가기** (Jump Back) |
| `<Ctrl> + i` | 다음 위치로 이동 (Jump Forward) |

### 5. ✍️ 편집 및 도구 (Editing & Tools)

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`<Cmd> + /`** | **주석 토글** (현재 줄 또는 선택 영역, GUI Neovim 전용) |
| **`<Space> + cf`** | **코드 포맷팅** (Format on Save 포함) |
| `<Space> + cl` | 코드 린트(Lint) 실행 |
| `<Space> + w` | 파일 저장 |
| `<Space> + q` | Neovim 종료 |

### 6. 💻 터미널 (toggleterm)

Neovim 안에서 터미널을 열어 셸 명령을 바로 실행할 수 있습니다.

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`<Space> + tt`** | **터미널 열기/닫기** (토글) |
| `<Ctrl+\> <Ctrl+n>` | 터미널 모드 → **Normal 모드로 전환** |

> **사용 흐름**: `<Space>tt`로 터미널 열기 → 명령 실행 (예: `python -m pytest`) → `<Ctrl+\><Ctrl+n>`으로 Normal 모드 전환 → `<Space>tt`로 터미널 닫기

### 7. 🐙 Git 통합 (Gitsigns)

| 단축키 | 기능 설명 |
| :--- | :--- |
| `<Space> + hb` | 현재 줄의 Git Blame 보기 |
| `<Space> + hd` | 변경 사항 비교 (Diff) |
| `<Space> + hp` | 변경 사항 미리보기 (Preview) |
| `<Space> + hs` | 현재 Hunk 스테이지 (Stage Hunk) |
| `<Space> + hr` | 현재 Hunk 되돌리기 (Reset Hunk) |
| `<Space> + hS` | 버퍼 전체 스테이지 (Stage Buffer) |
| `<Space> + hu` | Hunk 스테이지 취소 (Undo Stage Hunk) |
| `]c` / `[c` | 다음 / 이전 변경 지점(Hunk) 이동 |

### 8. 🧪 테스트 실행 (Neotest)

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`<Space> + tr`** | **현재 테스트 실행** (Run Nearest) |
| `<Space> + tf` | 현재 파일의 모든 테스트 실행 |
| `<Space> + ts` | **테스트 요약 보기** (Summary) |
| `<Space> + to` | 테스트 결과 출력 보기 (Output, 플로팅 창) |
| `<Space> + tp` | 출력 패널 토글 (하단, pytest 원본 출력) |
| `<Space> + td` | 테스트 디버깅 (Debug) |

> **참고**: `tr`/`tf`로 테스트를 실행하면 성공/실패와 무관하게 화면 하단에 pytest 원본 출력 패널이 자동으로 열립니다. 코드 옆 아이콘(virtual text)으로도 개별 테스트의 성공/실패를 바로 확인할 수 있습니다.

### 9. 🐞 디버깅 (DAP)

| 단축키 | 기능 설명 |
| :--- | :--- |
| `<F5>` | 디버깅 시작 / 계속 |
| `<F10> / <F11> / <F12>` | Step Over / Step Into / Step Out |
| **`<Space> + db`** | **중단점 설정/해제** |
| `<Space> + dB` | 조건부 중단점 설정 (조건식 입력) |
| `<Space> + dr` | DAP REPL 열기 |
| `<Space> + du` | 디버깅 UI 토글 |
| `<Space> + dt` | Go 테스트 디버깅 (빌드 태그 입력 가능) |

### 10. 📝 마크다운 프리뷰 (Markdown Preview)

Mermaid 다이어그램 렌더링을 지원하는 브라우저 기반 실시간 마크다운 프리뷰입니다. 마크다운(`.md`) 파일을 열었을 때만 활성화됩니다.

| 단축키/명령어 | 기능 설명 |
| :--- | :--- |
| **`<Space> + mp`** | **프리뷰 토글** (켜기/끄기, 브라우저 자동으로 열림) |
| `:MarkdownPreviewOpen` | 프리뷰가 켜진 상태로 바로 시작 (커맨드라인 진입용) |

> **커맨드라인에서 바로 켜기**: `nvim -c MarkdownPreviewOpen file.md`. 자주 쓴다면 셸 별칭을 등록해 `mdp file.md`처럼 짧게 쓸 수 있습니다 (예: `~/.zshrc`에 `mdp() { nvim -c "MarkdownPreviewOpen" "$1"; }` 추가).
>
> **참고**: 다크 테마로 렌더링되며, ` ```mermaid ` 코드 블록 안의 다이어그램도 자동으로 그려집니다. 다른 마크다운 파일로 이동해도 `<Space> + mp` 하나로 프리뷰를 새 파일 기준으로 다시 켜고 끌 수 있습니다.

### 11. 💾 세션 관리 (Session)

같은 디렉토리 + 같은 git 브랜치 조합으로 작업하던 버퍼/창 레이아웃을 자동으로 저장하고 복원합니다. 인수 없이 `nvim`으로 열면 자동 복원되므로, 아래 단축키는 자동 복원을 원치 않거나 수동으로 다시 불러올 때만 필요합니다.

| 단축키 | 기능 설명 |
| :--- | :--- |
| `<Space> + qs` | 현재 디렉토리+브랜치 세션 복원 |
| `<Space> + ql` | 가장 최근 세션 복원 |
| `<Space> + qd` | 세션 자동 저장 중지 |

> **참고**: `nvim file.lua`처럼 파일을 지정하거나 stdin으로 파이프할 때는 자동 복원이 동작하지 않습니다.

---

## 🌐 지원 언어 및 도구

| 언어 | LSP | Formatter | Linter |
| :--- | :--- | :--- | :--- |
| Python | pyright | ruff (fix + format) | ruff |
| Go | gopls | gofmt + goimports | golangci-lint |
| Kotlin | kotlin_language_server | ktlint | ktlint |
| JSON | jsonls + schemastore | jq (2-space indent) | jsonls |
| Lua | — | stylua | — |

> **JSON 참고**: `jq`가 시스템에 설치되어 있어야 합니다 (`brew install jq`). jsonls는 `package.json`, `tsconfig.json` 등 주요 JSON 파일에 대해 스키마 기반 자동완성과 유효성 검사를 제공합니다.

## 💡 유용한 팁

1.  **명령어 힌트**: `<Space>` 키를 누르고 잠시 기다리면 하단에 가능한 단축키 목록이 자동으로 나타납니다.
2.  **창 이동**: 여러 창을 나누었을 때 `<Ctrl> + h/j/k/l` 키로 자유롭게 이동할 수 있습니다.
3.  **플러그인 관리**: 새로운 플러그인을 추가하거나 업데이트하려면 `:Lazy` 명령어를 입력하세요.
4.  **한글 입력 자동 전환**: Normal mode 진입 시 자동으로 영문 입력기로 전환되고, Insert mode 진입 시 이전 입력기(한글)로 복원됩니다. (`macism` CLI 필요 — `make install`로 자동 설치됨)
5.  **검색 하이라이트 제거**:
    - **자동 제거**: Insert 모드에서 `<Esc>`를 누르면 자동으로 검색 하이라이트가 제거됩니다.
    - **수동 제거**: `:noh` (또는 `:nohlsearch`) 명령어로 언제든 제거 가능합니다.
    - **배경**: `/` 또는 `?`로 검색한 후 해당 키워드가 파일 전체에서 강조 표시되는데, 검색 완료 후에는 이를 제거하면 화면이 더 깔끔합니다.
6.  **빈 파일 생성하기**:
    - **명령어로**: `:e newfile.txt` → `:w` (빈 버퍼를 열고 저장하면 디스크에 파일 생성)
    - **Neo-tree에서**: `<Space> + e`로 탐색기를 열고, 원하는 디렉토리에서 `a` 키를 누른 뒤 파일명 입력
    - **경로 포함**: `:e lua/plugins/newplugin.lua` → `:w` (중간 디렉토리가 없으면 `:!mkdir -p <경로>` 먼저 실행)

# 🚀 Neovim Configuration (VS Code Style)

이 설정은 Neovim v0.11+을 기반으로 하며, VS Code와 유사한 사용자 경험을 제공하도록 설계되었습니다.

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
- **macOS**: `Homebrew`를 사용하여 Neovim(HEAD), ripgrep, fd, cmake 설치
- **Ubuntu**: `apt` 및 `ppa:neovim-ppa/unstable`을 사용하여 최신 Neovim 및 도구 설치
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
| `<Space> + ff` | 일반 파일 찾기 (숨김 파일 포함) |
| `<Space> + fg` | **전체 텍스트 검색** (Live Grep) |
| `<Shift> + l / h` | **다음 / 이전 탭으로 이동** |
| **`<Space> + x`** | **현재 탭(버퍼) 닫기** |
| `<Space> + n` | 새 빈 문서(Buffer) 열기 |

### 2. 🧠 코드 지능형 기능 (LSP)

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`g + d`** | **정의로 이동** (Definition) |
| `g + r` | 참조 찾기 (References) |
| **`K`** | **문서 보기** (Hover) |
| `<Space> + rn` | 이름 변경 (Rename) |
| `<Space> + ca` | 코드 액션 (Code Action) |
| `[d` / `]d` | 이전 / 다음 에러 위치 이동 |

### 3. ✍️ 편집 및 도구 (Editing & Tools)

| 단축키 | 기능 설명 |
| :--- | :--- |
| **`<Space> + cf`** | **코드 포맷팅** (Format on Save 포함) |
| `<Space> + cl` | 코드 린트(Lint) 실행 |
| `<Space> + tt` | **통합 터미널** 토글 |
| `<Space> + w` | 파일 저장 |
| `<Space> + q` | Neovim 종료 |

### 4. 🐙 Git 통합 (Gitsigns)

| 단축키 | 기능 설명 |
| :--- | :--- |
| `<Space> + hb` | 현재 줄의 Git Blame 보기 |
| `<Space> + hd` | 변경 사항 비교 (Diff) |
| `<Space> + hp` | 변경 사항 미리보기 (Preview) |
| `]c` / `[c` | 다음 / 이전 변경 지점(Hunk) 이동 |

### 5. 🐞 디버깅 (DAP)

| 단축키 | 기능 설명 |
| :--- | :--- |
| `<F5>` | 디버깅 시작 / 계속 |
| `<F10> / <F11>` | Step Over / Step Into |
| **`<Space> + db`** | **중단점 설정/해제** |
| `<Space> + du` | 디버깅 UI 토글 |

---

## 💡 유용한 팁

1.  **명령어 힌트**: `<Space>` 키를 누르고 잠시 기다리면 하단에 가능한 단축키 목록이 자동으로 나타납니다.
2.  **창 이동**: 여러 창을 나누었을 때 `<Ctrl> + h/j/k/l` 키로 자유롭게 이동할 수 있습니다.
3.  **플러그인 관리**: 새로운 플러그인을 추가하거나 업데이트하려면 `:Lazy` 명령어를 입력하세요.

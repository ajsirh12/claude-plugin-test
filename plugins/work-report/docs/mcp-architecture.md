# work-report MCP 아키텍처

## MCP 설정 계층 구조

### 1. 글로벌 MCP 설정 (선택사항)

**위치**: `~/.claude/config.json` 또는 `~/.config/claude/mcp.json`

```json
{
  "mcpServers": {
    "github": {
      "type": "sse",
      "url": "https://mcp.github.com/sse"
    }
  }
}
```

**특징**:
- 모든 Claude 세션에서 사용 가능
- 모든 플러그인에서 접근 가능
- 수동 설정 필요

### 2. 플러그인 레벨 MCP 설정 (자동)

**위치**: `plugins/work-report/.mcp.json`

```json
{
  "notion": {
    "type": "sse",
    "url": "https://mcp.notion.com/mcp"
  }
}
```

**특징**:
- work-report 플러그인 전용
- 플러그인 설치 시 자동으로 포함됨
- 사용자 추가 설정 불필요
- 플러그인 범위 내에서만 동작

## 독립성 보장

### work-report는 글로벌 MCP 설정이 없어도 작동

```
사용자 환경:
└─ Claude CLI 설치됨
   ├─ 글로벌 MCP 설정 없음 ✅ OK!
   └─ work-report 플러그인 설치
      └─ .mcp.json 자동 로드
         └─ Notion MCP 연결 성공 ✅
```

**필요한 것**:
1. ✅ Claude CLI 설치
2. ✅ work-report 플러그인 설치
3. ✅ `NOTION_API_TOKEN` 환경변수 설정

**필요하지 않은 것**:
1. ❌ 글로벌 `~/.claude/config.json` MCP 설정
2. ❌ 수동 MCP 서버 설정
3. ❌ 다른 플러그인

## MCP 서버 라이프사이클

### 플러그인 로드 시

```
1. Claude Code 시작
   ↓
2. 플러그인 디렉토리 스캔
   - plugins/work-report/ 발견
   ↓
3. 플러그인 메타데이터 읽기
   - plugin.json 파싱
   - .mcp.json 발견
   ↓
4. MCP 서버 초기화
   - type: "sse" 확인
   - URL: https://mcp.notion.com/mcp 연결
   ↓
5. 인증
   - NOTION_API_TOKEN 환경변수 읽기
   - OAuth 또는 Token 인증
   ↓
6. 도구 등록
   - mcp__plugin_work_report_notion__* 도구들 사용 가능
   ↓
7. 플러그인 준비 완료
```

### 플러그인 언로드 시

```
1. 플러그인 비활성화 또는 Claude Code 종료
   ↓
2. MCP 연결 정리
   - 활성 요청 완료 대기
   - 연결 종료
   ↓
3. 도구 등록 해제
   - mcp__plugin_work_report_notion__* 제거
```

## MCP 도구 네이밍 규칙

### 플러그인별 네임스페이스

```
mcp__plugin_{plugin_name}_{server_name}__{tool_name}
         └─────┬──────┘ └────┬─────┘  └────┬────┘
          플러그인 ID    서버 이름    도구 이름
```

**work-report 예시**:
```
mcp__plugin_work_report_notion__query_database
mcp__plugin_work_report_notion__read_page
mcp__plugin_work_report_notion__search
```

**글로벌 MCP 예시** (비교):
```
mcp__github__create_issue
mcp__github__search_repos
```

### 네임스페이스 충돌 방지

```
플러그인 A:
  mcp__plugin_plugin_a_notion__query_database
                └──┬───┘
              고유 플러그인 ID

플러그인 B:
  mcp__plugin_plugin_b_notion__query_database
                └──┬───┘
              다른 플러그인 ID

→ 충돌 없음! 각각 독립적으로 작동
```

## 인증 처리

### Notion MCP 인증 흐름

```
1. work-report 플러그인 로드
   ↓
2. .mcp.json 읽기
   - type: "sse"
   - url: "https://mcp.notion.com/mcp"
   ↓
3. 환경변수 확인
   - NOTION_API_TOKEN 존재?
   ↓
   YES                          NO
   ↓                            ↓
4a. Token 사용               4b. OAuth 플로우 시작
   - Bearer 토큰 헤더 추가      - 브라우저 열기
   - 연결 시도                  - 사용자 인증
                              - 토큰 저장
   ↓
5. 연결 성공
```

### 환경변수 우선순위

```
1. 시스템 환경변수 (최우선)
   - Windows: setx NOTION_API_TOKEN "..."
   - Linux/Mac: export NOTION_API_TOKEN="..."

2. .env 파일 (있다면)
   - 프로젝트 루트 .env

3. 인라인 설정 (플러그인에서는 권장하지 않음)
   - 보안상 위험
```

## 설정 우선순위

### MCP 서버 중복 시

같은 이름의 MCP 서버가 여러 곳에 정의되어 있다면:

```
우선순위 (높음 → 낮음):
1. 플러그인 레벨 .mcp.json
2. 프로젝트 레벨 .claude/mcp.json
3. 글로벌 레벨 ~/.claude/config.json
```

**예시**:
```
글로벌:
  "notion": { "url": "https://old-server.com" }

work-report 플러그인:
  "notion": { "url": "https://mcp.notion.com/mcp" }

→ work-report에서는 플러그인 설정 사용
→ 다른 곳에서는 글로벌 설정 사용
```

## 설치 시나리오

### 시나리오 1: 완전히 새로운 사용자

```
사용자 상태:
- Claude CLI 설치됨
- MCP 설정 전혀 없음
- work-report 플러그인 설치 원함

필요한 단계:
1. work-report 플러그인 설치
2. NOTION_API_TOKEN 환경변수 설정
3. /work-report:daily 실행

→ 작동 ✅ (글로벌 MCP 설정 불필요)
```

### 시나리오 2: 다른 MCP 서버 이미 사용 중

```
사용자 상태:
- ~/.claude/config.json에 GitHub MCP 설정됨
- work-report 플러그인 설치 원함

기존 설정:
{
  "mcpServers": {
    "github": {
      "type": "sse",
      "url": "https://mcp.github.com/sse"
    }
  }
}

→ work-report 설치 후:
  - GitHub MCP는 계속 글로벌로 사용
  - Notion MCP는 work-report 플러그인에서만 사용
  - 서로 독립적 ✅
```

### 시나리오 3: Notion을 글로벌로도 사용하고 싶음

```
원하는 구성:
- work-report에서 Notion 사용
- 다른 곳(ChatGPT, Cursor 등)에서도 Notion 사용

방법:
1. work-report 플러그인 설치 (자동으로 Notion MCP 포함)
2. 글로벌 설정에도 Notion MCP 추가:

~/.claude/config.json:
{
  "mcpServers": {
    "notion": {
      "type": "sse",
      "url": "https://mcp.notion.com/mcp"
    }
  }
}

→ work-report: 플러그인 레벨 Notion MCP 사용
→ 일반 세션: 글로벌 Notion MCP 사용
```

## 문제 해결

### MCP 연결 확인

```bash
# Claude Code에서 MCP 서버 목록 확인
/mcp

# 출력 예시:
# Plugin MCP Servers:
#   work-report:
#     - notion (sse): https://mcp.notion.com/mcp ✅ connected
#
# Global MCP Servers:
#   (none)
```

### 디버깅

```bash
# 디버그 모드로 실행
claude --debug

# MCP 연결 로그 확인:
# [DEBUG] Loading plugin: work-report
# [DEBUG] Found .mcp.json in plugin
# [DEBUG] Initializing MCP server: notion (sse)
# [DEBUG] Connecting to https://mcp.notion.com/mcp
# [DEBUG] Authentication: using NOTION_API_TOKEN
# [DEBUG] Connection established ✅
# [DEBUG] Discovered tools:
#   - mcp__plugin_work_report_notion__query_database
#   - mcp__plugin_work_report_notion__read_page
#   - mcp__plugin_work_report_notion__search
```

### 일반적인 문제

#### 1. "MCP server not found"

```
원인: .mcp.json이 플러그인 루트에 없음

확인:
plugins/work-report/
├── .mcp.json  ← 이 파일이 있어야 함
├── plugin.json
└── ...

해결:
- .mcp.json 파일 존재 확인
- JSON 형식 오류 확인
```

#### 2. "NOTION_API_TOKEN not found"

```
원인: 환경변수 설정 안 됨

확인:
# PowerShell
$env:NOTION_API_TOKEN

# Bash
echo $NOTION_API_TOKEN

해결:
# PowerShell (현재 세션)
$env:NOTION_API_TOKEN = "secret_xxx"

# PowerShell (영구)
setx NOTION_API_TOKEN "secret_xxx"

# Bash
export NOTION_API_TOKEN="secret_xxx"
```

#### 3. "Connection failed"

```
원인: 네트워크 또는 인증 문제

확인:
1. 인터넷 연결 확인
2. Notion API 토큰 유효성 확인
3. Notion Integration이 활성화되었는지 확인

해결:
1. 새 토큰 발급
2. Integration 다시 연결
3. 프록시 설정 확인
```

## 보안 고려사항

### 플러그인 격리

```
work-report 플러그인:
├── 자체 MCP 서버 (notion)
├── 자체 도구 네임스페이스
└── 자체 인증

다른 플러그인:
├── work-report의 MCP에 접근 불가 ✅
└── 독립적인 MCP 서버 사용 가능
```

### 토큰 관리

```
✅ 권장:
- 환경변수 사용
- 시스템 키체인 저장 (OS 레벨)

❌ 비권장:
- .mcp.json에 토큰 하드코딩
- Git에 토큰 커밋
- 설정 파일에 평문 저장
```

## 성능 최적화

### 지연 로딩

```
플러그인 로드:
├── .mcp.json 파싱 (즉시)
├── MCP 서버 설정 저장 (즉시)
└── 실제 연결 (지연됨)
    └── 첫 도구 호출 시 연결 ⚡
```

**이점**:
- 빠른 플러그인 로드 시간
- 불필요한 연결 방지
- 리소스 절약

### 연결 풀링

```
MCP 연결:
├── 첫 도구 호출: 연결 생성
├── 이후 호출: 기존 연결 재사용 ⚡
└── 플러그인 언로드: 연결 종료
```

## 요약

### ✅ work-report MCP는 독립적

1. **글로벌 MCP 설정 불필요**
   - 플러그인 자체에 `.mcp.json` 포함
   - 자동으로 Notion MCP 연결

2. **환경변수만 필요**
   - `NOTION_API_TOKEN` 설정
   - 다른 설정 불필요

3. **플러그인 범위 격리**
   - work-report 전용 MCP 서버
   - 다른 플러그인/세션과 독립

4. **사용자 편의성**
   - 복잡한 MCP 설정 불필요
   - 플러그인 설치 → 즉시 사용 가능

### 📝 사용자가 해야 할 일

```bash
# 1. Notion Integration 생성
# https://www.notion.so/my-integrations

# 2. 환경변수 설정
export NOTION_API_TOKEN="secret_xxx"

# 3. 플러그인 사용
/work-report:daily

# 끝! ✅
```

**글로벌 MCP 설정은 선택사항이며, work-report는 독립적으로 작동합니다.**

---
description: MCP 서버 연결 상태 확인 및 설정 가이드 (Notion, Slack)
argument-hint: [service]
allowed-tools: Bash, Read, AskUserQuestion
---

MCP 서버의 연결 상태를 확인하고, 연결되지 않은 경우 설정을 안내한다.

## 인자 처리

- `$1`: 서비스 이름 (선택)
  - 미지정: 모든 MCP 서버 확인
  - `notion`: Notion MCP만 확인
  - `slack`: Slack MCP만 확인

## 검증 절차

### 1. 환경변수 확인

**Notion:**
```bash
# PowerShell
$env:NOTION_API_TOKEN

# Linux/macOS
echo $NOTION_API_TOKEN
```

**Slack:**
```bash
# PowerShell
$env:SLACK_BOT_TOKEN

# Linux/macOS
echo $SLACK_BOT_TOKEN
```

### 2. 플러그인 MCP 설정 확인

`.claude-plugin/.mcp.json` 파일을 읽어서 MCP 설정 확인:
- Notion: `https://mcp.notion.com/mcp`
- Slack: `https://mcp.slack.com/sse`

### 3. MCP 연결 테스트

Claude Code의 MCP 도구를 사용하여 API 호출 시도.

## 출력 형식

```
🔍 MCP 서버 연결 확인

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Notion MCP
[1/3] 환경변수 확인
✅ NOTION_API_TOKEN: 설정됨 (secret_abc***)

[2/3] 플러그인 설정 확인
✅ .mcp.json: 올바르게 구성됨
   - URL: https://mcp.notion.com/mcp
   - Type: sse

[3/3] 연결 테스트
✅ 연결 성공

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💬 Slack MCP
[1/3] 환경변수 확인
❌ SLACK_BOT_TOKEN: 설정되지 않음

[2/3] 플러그인 설정 확인
✅ .mcp.json: 올바르게 구성됨
   - URL: https://mcp.slack.com/sse
   - Type: sse

[3/3] 연결 테스트
⏭️  스킵 (환경변수 없음)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 결과 요약
✅ Notion: 연결됨
❌ Slack: 설정 필요

Slack 설정이 필요합니다. 설정을 진행할까요?
```

## MCP 미연결 시 설정 안내

### Notion 설정 안내

환경변수가 없는 경우:
```
⚠️  NOTION_API_TOKEN 환경변수가 설정되지 않았습니다.

📋 설정 방법:

1. Notion Integration 생성
   → https://www.notion.so/my-integrations
   → "New Integration" 클릭
   → 이름 입력 후 생성

2. Internal Integration Token 복사

3. 환경변수 설정:
   PowerShell: $env:NOTION_API_TOKEN = "secret_xxx..."
   영구설정:   setx NOTION_API_TOKEN "secret_xxx..."
   Linux/Mac:  export NOTION_API_TOKEN="secret_xxx..."

4. 데이터베이스 연결 (중요!)
   → Notion에서 사용할 데이터베이스 열기
   → 우측 상단 ... → "Add connections" → Integration 선택

자세한 내용은 README.md의 "Notion 통합" 섹션을 참조하세요.
```

### Slack 설정 안내

환경변수가 없는 경우:
```
⚠️  SLACK_BOT_TOKEN 환경변수가 설정되지 않았습니다.

📋 설정 방법:

1. Slack App 생성
   → https://api.slack.com/apps
   → "Create New App" → "From scratch" 선택
   → App 이름과 Workspace 선택

2. Bot Token Scopes 설정 (OAuth & Permissions)
   필수 권한:
   - channels:history (Public 채널 메시지 읽기)
   - channels:read (채널 목록 조회)
   - users:read (사용자 정보 조회)

   선택 권한 (Private 채널용):
   - groups:history (Private 채널 메시지 읽기)
   - groups:read (Private 채널 목록)

3. Install to Workspace
   → OAuth & Permissions 페이지에서 "Install to Workspace" 클릭
   → 권한 승인

4. Bot User OAuth Token 복사
   → xoxb-로 시작하는 토큰

5. 환경변수 설정:
   PowerShell: $env:SLACK_BOT_TOKEN = "xoxb-xxx..."
   영구설정:   setx SLACK_BOT_TOKEN "xoxb-xxx..."
   Linux/Mac:  export SLACK_BOT_TOKEN="xoxb-xxx..."

6. Bot을 채널에 초대 (Private 채널의 경우 필수)
   → 채널에서 /invite @봇이름

💡 참고: Public 채널은 Bot 초대 없이도 읽을 수 있습니다!
```

## 대화형 설정 지원

MCP가 연결되지 않은 경우 AskUserQuestion을 사용하여 설정 진행 여부를 물어본다:

```
질문: "Slack MCP 설정을 진행할까요?"
header: "Slack 설정"
options:
  - label: "지금 설정하기 (Recommended)"
    description: "Slack App 생성부터 환경변수 설정까지 단계별 안내"
  - label: "나중에 설정"
    description: "Slack 없이 Git/Claude/Notion만 사용"
  - label: "사용 안 함"
    description: "Slack 데이터 소스 비활성화"
```

"지금 설정하기" 선택 시:
1. 위의 설정 안내 출력
2. 단계별로 진행 확인
3. 환경변수 설정 후 재확인 안내

"사용 안 함" 선택 시:
- `.claude/work-report.local.md`의 `data_sources`에서 slack 제거 안내

## 문제 해결 가이드

### "Channel not found" 오류

**원인**: 채널명이 잘못되었거나 Bot 권한이 없음

**확인사항**:
1. 채널명에서 # 제외했는지 확인
2. Private 채널인 경우 Bot이 초대되었는지 확인
3. `channels:read` 권한이 있는지 확인

### "not_in_channel" 오류

**원인**: Private 채널에 Bot이 초대되지 않음

**해결**:
1. 해당 채널로 이동
2. `/invite @봇이름` 실행
3. Bot이 채널에 추가되었는지 확인

### "missing_scope" 오류

**원인**: 필요한 권한이 없음

**해결**:
1. https://api.slack.com/apps 에서 App 선택
2. OAuth & Permissions → Scopes
3. 필요한 권한 추가:
   - Public: `channels:history`, `channels:read`
   - Private: `groups:history`, `groups:read`
4. "Reinstall to Workspace" 클릭

### "invalid_auth" 오류

**원인**: 토큰이 잘못됨

**해결**:
1. 토큰이 `xoxb-`로 시작하는지 확인
2. 토큰 복사 시 앞뒤 공백 확인
3. 필요시 토큰 재생성

## 채널 접근 권한 정리

| 채널 타입 | Bot 초대 필요 | 필요 권한 |
|----------|--------------|----------|
| Public 채널 | ❌ 불필요 | `channels:history`, `channels:read` |
| Private 채널 | ✅ 필수 | `groups:history`, `groups:read` |
| DM | - | ❌ 지원 안 함 (프라이버시) |

## 사용 예시

```bash
# 모든 MCP 확인
/work-report:check-mcp

# Slack만 확인
/work-report:check-mcp slack

# Notion만 확인
/work-report:check-mcp notion
```

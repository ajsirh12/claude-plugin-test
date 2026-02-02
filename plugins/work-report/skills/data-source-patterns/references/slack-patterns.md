# Slack Data Collection Patterns

Patterns for collecting and summarizing Slack messages for work reports.

## ⚡ MCP 자동 포함 (Plug & Play)

**work-report 플러그인은 Slack MCP 서버를 자체 포함합니다.**

```
✅ 필요한 것:
1. work-report 플러그인 설치
2. SLACK_BOT_TOKEN 환경변수 설정

❌ 필요하지 않은 것:
1. 글로벌 Claude CLI MCP 설정
2. 별도 MCP 서버 설치
3. ~/.claude/config.json 수정
```

## 빠른 시작

### 1. Slack App 생성

1. [Slack API](https://api.slack.com/apps) 접속
2. "Create New App" → "From scratch" 선택
3. App 이름 입력 (예: "Work Report Bot")
4. Workspace 선택

### 2. Bot Token Scopes 설정

**OAuth & Permissions** 페이지에서 Bot Token Scopes 추가:

**필수 권한:**
| Scope | 설명 |
|-------|------|
| `channels:history` | Public 채널 메시지 읽기 |
| `channels:read` | 채널 목록 조회 |
| `users:read` | 사용자 정보 조회 (이름 표시용) |

**선택 권한 (Private 채널용):**
| Scope | 설명 |
|-------|------|
| `groups:history` | Private 채널 메시지 읽기 |
| `groups:read` | Private 채널 목록 |

### 3. Install to Workspace

"Install to Workspace" 클릭 → 권한 승인

### 4. Bot Token 복사

**Bot User OAuth Token** 복사 (xoxb-로 시작)

### 5. 환경변수 설정

```powershell
# PowerShell (현재 세션)
$env:SLACK_BOT_TOKEN = "xoxb-your-token-here"

# Windows 영구 설정
setx SLACK_BOT_TOKEN "xoxb-your-token-here"
```

```bash
# Linux/macOS
export SLACK_BOT_TOKEN="xoxb-your-token-here"

# 영구 설정 (~/.bashrc 또는 ~/.zshrc)
echo 'export SLACK_BOT_TOKEN="xoxb-your-token-here"' >> ~/.bashrc
```

### 6. MCP 연결 확인

```bash
/work-report:check-mcp slack
```

## Configuration Examples

### Basic Channel

```yaml
projects:
  - name: "team-chat"
    type: "slack"
    channel: "dev-team"
```

### With Thread Inclusion

```yaml
projects:
  - name: "discussions"
    type: "slack"
    channel: "engineering"
    include_threads: true
```

### Multiple Channels

```yaml
projects:
  - name: "frontend-chat"
    type: "slack"
    channel: "frontend"

  - name: "backend-chat"
    type: "slack"
    channel: "backend"

  - name: "standup"
    type: "slack"
    channel: "daily-standup"
```

### With Message Limit

```yaml
projects:
  - name: "busy-channel"
    type: "slack"
    channel: "general"
    include_threads: true
    limit: 100  # 최근 100개 메시지만 (Rate limit 방지)
```

## Channel Types & Access

| 채널 타입 | Bot 초대 필요 | 필요 권한 |
|----------|--------------|----------|
| Public 채널 | ❌ 불필요 | `channels:history`, `channels:read` |
| Private 채널 | ✅ 필수 | `groups:history`, `groups:read` |
| DM | - | ❌ 지원 안 함 (프라이버시) |

**Public 채널**: Bot이 멤버가 아니어도 메시지 읽기 가능!

**Private 채널**: Bot을 채널에 초대해야 함
```
/invite @your-bot-name
```

## Data Fields Collected

| Field | Description |
|-------|-------------|
| timestamp | Message time |
| user | Author display name |
| text | Message content |
| thread_ts | Thread identifier |
| reactions | Emoji reactions |
| reply_count | Number of thread replies |

## Filtering Options

### Time-Based

Messages are filtered based on report type:
- **Daily**: Last 24 hours
- **Weekly**: Last 7 days
- **Monthly**: Last 30 days

### Content-Based Summarization

메시지는 직접 포함되지 않고 **요약**됩니다:

1. **주요 논의**: 대화에서 핵심 토픽 추출
2. **결정사항**: 합의된 내용 정리
3. **공지사항**: 중요 안내 사항
4. **Action Items**: 할 일 목록 추출

## Report Output Format

Slack data appears in reports as summarized discussions:

```markdown
## 💬 Slack 논의 요약

### #dev-team (45개 메시지, 8개 스레드)

**📌 주요 논의:**
1. **API 성능 최적화**
   - Redis 캐싱 도입 결정
   - 응답 시간 50% 개선 목표
   - 참여: 김철수, 이영희 외 3명

2. **테스트 자동화 전략**
   - E2E 테스트 프레임워크 선정 (Playwright)
   - CI 파이프라인 통합 계획

**✅ 결정사항:**
- Redis 캐싱 레이어 도입 결정
- 다음 스프린트에서 구현 예정

**📢 공지사항:**
- 금요일 배포 일정 변경 (14:00 → 16:00)

**📝 Action Items:**
- [ ] 김철수: Redis 설계 문서 작성
- [ ] 이영희: 기존 캐시 로직 리뷰

### #daily-standup (15개 메시지)

**이번 주 스탠드업 요약:**
- 월: Auth 기능 구현 시작
- 화: 로그인 API 완료, 테스트 작성 중
- 수: 프로덕션 버그 핫픽스
- 목: 캐싱 레이어 설계 논의
- 금: 스프린트 마무리, 배포
```

## Privacy Considerations

- **DM 미지원**: 개인 메시지는 수집하지 않음
- **요약 위주**: 전체 메시지가 아닌 요약만 포함
- **업무 채널만**: 소셜/개인 채널 제외 권장
- **채널 권한 존중**: Bot 권한 범위 내에서만 수집

## MCP Server Setup

### Plugin-Level (Automatic)

work-report 플러그인은 `.mcp.json`에 Slack MCP 설정이 포함되어 있습니다:

```json
{
  "mcpServers": {
    "slack": {
      "type": "sse",
      "url": "https://mcp.slack.com/sse"
    }
  }
}
```

### Environment Variable

```bash
# Required
SLACK_BOT_TOKEN=xoxb-your-bot-token
```

## Troubleshooting

### "Channel not found"

1. 채널명에서 # 제외 확인
2. 채널명 정확한지 확인 (대소문자 구분)
3. Bot이 해당 Workspace에 설치되었는지 확인

### "not_in_channel"

Private 채널에서 Bot이 초대되지 않음:
1. 해당 채널로 이동
2. `/invite @봇이름` 실행

### "missing_scope"

필요한 권한이 없음:
1. https://api.slack.com/apps 에서 App 선택
2. OAuth & Permissions → Scopes
3. 필요한 권한 추가
4. "Reinstall to Workspace" 클릭

### "No messages collected"

1. 날짜 범위 확인 (해당 기간에 메시지가 있는지)
2. Bot 권한 확인
3. 채널에 활동이 있는지 확인

### "Rate limited"

1. `limit` 설정으로 메시지 수 제한
2. 채널 수 줄이기
3. 더 긴 시간 간격 사용

### "invalid_auth"

1. 토큰이 `xoxb-`로 시작하는지 확인
2. 토큰 복사 시 앞뒤 공백 확인
3. 토큰 재생성

## Git + Slack 통합 예시

**보고서 출력**:
```markdown
## 완료한 작업

### 코드 변경 (Git)
- feat: 사용자 인증 API 구현 (commit a1b2c3d)
  - 파일: 3개 변경
  - 라인: +234/-89

### 팀 논의 (Slack)
- ✅ [#dev-team] 인증 방식 결정: JWT + Refresh Token
  - 논의 참여: 김철수, 이영희
  - 관련 커밋: a1b2c3d

👉 **Git 커밋과 Slack 논의가 자동으로 연결됩니다!**
```

## Best Practices

1. **채널 선정**
   - 업무 관련 채널만 포함
   - 너무 많은 채널 피하기 (5개 이하 권장)

2. **Thread 활용**
   - `include_threads: true`로 맥락 파악
   - 스레드가 많은 채널에서 특히 유용

3. **Rate Limit 관리**
   - `limit` 설정으로 메시지 수 제한
   - 여러 채널 사용 시 분산 수집 고려

4. **보안**
   - Bot Token은 환경변수로만 관리
   - 코드나 설정 파일에 토큰 포함 금지

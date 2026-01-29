---
description: Notion MCP 연결 상태 확인 및 테스트
argument-hint:
allowed-tools: Bash, Read
---

Notion MCP 서버의 연결 상태를 확인하고 기본 기능을 테스트한다.

## 검증 항목

1. **환경변수 확인**: NOTION_API_TOKEN이 설정되어 있는지 확인
2. **플러그인 설정**: .mcp.json이 올바르게 구성되어 있는지 확인
3. **MCP 서버 연결**: Notion MCP 서버와 통신 가능한지 확인
4. **권한 테스트**: 기본 API 호출이 작동하는지 테스트

## 검증 절차

### 1. 환경변수 확인

```bash
# PowerShell
$env:NOTION_API_TOKEN

# Linux/macOS
echo $NOTION_API_TOKEN
```

**결과**:
- ✅ 설정됨: `secret_***...` (일부만 표시)
- ❌ 미설정: 환경변수가 설정되지 않음

환경변수가 없는 경우:
```
⚠️  NOTION_API_TOKEN 환경변수가 설정되지 않았습니다.

설정 방법:
1. Notion Integration 생성: https://www.notion.so/my-integrations
2. API Token 복사
3. 환경변수 설정:
   - PowerShell: $env:NOTION_API_TOKEN = "secret_xxx..."
   - Linux/macOS: export NOTION_API_TOKEN="secret_xxx..."

자세한 내용은 README.md의 "Notion 통합" 섹션을 참조하세요.
```

### 2. 플러그인 설정 확인

`.mcp.json` 파일을 읽어서 Notion MCP 설정 확인:
- URL: `https://mcp.notion.com/mcp`
- Type: `sse`

### 3. MCP 연결 테스트

Claude Code의 MCP 도구를 사용하여 Notion API 호출 시도:
- `notion_search` 도구 사용
- 단순 검색 쿼리 실행

**성공 시**:
```
✅ Notion MCP 연결 성공!

MCP 서버: https://mcp.notion.com/mcp
상태: 연결됨
사용 가능한 도구: notion_search, notion_query_database, notion_get_page 등
```

**실패 시**:
```
❌ Notion MCP 연결 실패

가능한 원인:
1. NOTION_API_TOKEN이 올바르지 않음
2. Notion Integration이 활성화되지 않음
3. 네트워크 연결 문제
4. MCP 서버 접근 불가

문제 해결:
- Token 재확인: https://www.notion.so/my-integrations
- Integration 권한 확인
- 네트워크 상태 확인
```

### 4. 데이터베이스 접근 테스트 (선택)

`.claude/work-report.local.md`에 database_id가 설정된 경우, 해당 데이터베이스 접근 테스트:

```yaml
projects:
  - name: "tasks"
    type: "notion"
    database_id: "abc123..."
```

**테스트**:
- `notion_query_database` 호출
- 데이터베이스 스키마 확인
- 접근 권한 확인

## 출력 형식

```
🔍 Notion MCP 연결 확인

[1/4] 환경변수 확인
✅ NOTION_API_TOKEN: 설정됨 (secret_abc***)

[2/4] 플러그인 설정 확인
✅ .mcp.json: 올바르게 구성됨
   - URL: https://mcp.notion.com/mcp
   - Type: sse

[3/4] MCP 서버 연결 테스트
✅ 연결 성공
   - 사용 가능한 도구: 15개

[4/4] 데이터베이스 접근 테스트
✅ Database abc123... 접근 가능
   - 제목: My Tasks
   - 필드: 8개 (Title, Status, Assignee, ...)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 모든 검증 통과!

Notion MCP가 정상적으로 작동합니다.
/work-report:daily, weekly, monthly 명령어에서 Notion 데이터를 사용할 수 있습니다.
```

## 문제 해결 가이드

### "Database not found" 오류

**원인**: Integration이 데이터베이스에 연결되지 않음

**해결**:
1. Notion에서 데이터베이스 열기
2. 우측 상단 `...` → "Add connections"
3. 생성한 Integration 선택

### "Unauthorized" 오류

**원인**: API Token이 잘못됨

**해결**:
1. https://www.notion.so/my-integrations 방문
2. Integration 확인
3. Token 재생성 또는 재설정

### MCP 서버 연결 실패

**원인**: 네트워크 또는 MCP 서버 문제

**해결**:
1. 인터넷 연결 확인
2. 방화벽 설정 확인
3. Claude Code 재시작

## 사용 예시

```bash
# 기본 검증
/work-report:check-mcp

# 자동으로 모든 검증 수행
# 결과를 터미널에 출력
```

## 추가 정보

- Notion Integration 생성: https://www.notion.so/my-integrations
- Notion API 문서: https://developers.notion.com/
- work-report README: plugins/work-report/README.md

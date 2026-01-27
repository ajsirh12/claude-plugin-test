# Notion Data Collection Patterns

Notion MCP 서버를 활용한 데이터 수집 패턴 및 보고서 통합 가이드

## Notion MCP 서버 개요

**공식 호스팅 서버**: `https://mcp.notion.com/mcp`

Notion MCP를 통해 다음을 수집할 수 있습니다:
- 페이지 및 하위 페이지 콘텐츠
- 데이터베이스 (Tasks, Projects, Notes 등)
- 댓글 및 토론
- 사용자 권한 기반 접근

## 보고서에 포함할 Notion 데이터

### 1. 작업 데이터베이스 (Tasks/TODO)

보고서에서 가장 유용한 데이터:

```
추천 데이터베이스 필드:
- Title (작업명)
- Status (상태: Not Started, In Progress, Done)
- Assignee (담당자)
- Due Date (마감일)
- Priority (우선순위)
- Tags/Category (카테고리)
- Created/Updated Time (생성/수정 시각)
```

**보고서 활용**:
- 완료한 작업 목록
- 진행 중인 작업
- 다음 주 계획
- 목표 달성률 추적

### 2. 프로젝트 데이터베이스 (Projects)

```
추천 필드:
- Project Name
- Status (Planning, Active, Completed)
- Progress (0-100%)
- Start/End Date
- Team Members
- Key Milestones
```

**보고서 활용**:
- 프로젝트별 진행 상황
- 마일스톤 달성 현황
- 리소스 배분 분석

### 3. 일일 노트 (Daily Notes)

```
구조:
- Date
- Work Summary (업무 요약)
- Learnings (배운 점)
- Blockers (장애물)
- Next Steps (다음 단계)
```

**보고서 활용**:
- 일일 작업 내역
- 회고 섹션 자동 생성
- 블로커 추적

### 4. 회의 기록 (Meeting Notes)

```
추천 필드:
- Meeting Title
- Date
- Attendees
- Key Decisions
- Action Items
- Follow-up Tasks
```

**보고서 활용**:
- 주요 결정사항 요약
- 액션 아이템 추적

## Notion 쿼리 패턴

### 기간 기반 필터링

```javascript
// 이번 주 완료된 작업
{
  filter: {
    and: [
      {
        property: "Status",
        status: { equals: "Done" }
      },
      {
        property: "Updated",
        date: { on_or_after: "2024-01-15" }
      }
    ]
  },
  sorts: [
    {
      property: "Updated",
      direction: "descending"
    }
  ]
}
```

### 담당자 필터링

```javascript
// 내가 담당한 작업
{
  filter: {
    property: "Assignee",
    people: { contains: "current_user_id" }
  }
}
```

### 상태별 그룹화

```javascript
// 상태별로 작업 분류
{
  filter: {
    property: "Status",
    status: { is_not_empty: true }
  },
  sorts: [
    {
      property: "Status",
      direction: "ascending"
    }
  ]
}
```

## 설정 예시

### 기본 Notion 통합

```yaml
# .claude/work-report.local.md
data_sources:
  - git
  - claude
  - notion

projects:
  - name: "notion-tasks"
    type: "notion"
    database_id: "abc123def456"  # Tasks 데이터베이스 ID
    filters:
      assignee: "me"
      status: ["In Progress", "Done"]
      date_range: "this_week"
```

### 다중 Notion 데이터베이스

```yaml
projects:
  - name: "tasks"
    type: "notion"
    database_id: "tasks-db-id"
    filters:
      status: ["Done"]
      date_property: "Updated"

  - name: "projects"
    type: "notion"
    database_id: "projects-db-id"
    filters:
      status: ["Active", "Completed"]

  - name: "daily-notes"
    type: "notion"
    page_id: "daily-notes-page-id"
    recursive: true  # 하위 페이지 포함
    date_range: "this_week"
```

### 고급 필터링

```yaml
projects:
  - name: "sprint-tasks"
    type: "notion"
    database_id: "tasks-db-id"
    filters:
      and:
        - property: "Sprint"
          select: "Sprint 23"
        - property: "Assignee"
          people: "me"
        - property: "Status"
          status: ["In Progress", "Done"]
    sorts:
      - property: "Priority"
        direction: "ascending"
      - property: "Updated"
        direction: "descending"
```

## 보고서 출력 형식

### Tasks 섹션

```markdown
## 📝 Notion Tasks

### ✅ 완료한 작업 (5개)
- **[TASK-001]** API 성능 최적화 완료
  - 상태: Done
  - 완료일: 2024-01-18
  - 우선순위: High
  - 태그: #backend #performance

- **[TASK-002]** 사용자 대시보드 UI 개선
  - 상태: Done
  - 완료일: 2024-01-17
  - 우선순위: Medium
  - 태그: #frontend #ui

### 🔄 진행 중 (3개)
- **[TASK-010]** 테스트 자동화 구축
  - 상태: In Progress
  - 진행률: 60%
  - 마감일: 2024-01-20
  - 담당자: 나

### 📅 다음 주 계획 (4개)
- **[TASK-015]** 모바일 반응형 적용
- **[TASK-016]** API 문서 업데이트
```

### Projects 섹션

```markdown
## 🎯 프로젝트 진행 현황

| 프로젝트 | 상태 | 진행률 | 마감일 | 비고 |
|---------|------|-------|--------|------|
| **사용자 인증 개선** | Active | ████████░░ 80% | 01/25 | 거의 완료 |
| **대시보드 v2** | Active | ██████░░░░ 60% | 02/15 | 정상 진행 |
| **성능 모니터링** | Planning | ███░░░░░░░ 30% | 03/01 | 기획 중 |
```

### Daily Notes 섹션

```markdown
## 📖 주간 작업 일지 (Notion Daily Notes)

### 01/15 (월)
**작업 요약**: Frontend 레이아웃 리팩토링
**배운 점**: CSS Grid의 고급 기능 활용법
**블로커**: 없음

### 01/16 (화)
**작업 요약**: API 엔드포인트 3개 추가
**배운 점**: GraphQL 스키마 설계 패턴
**블로커**: 외부 API 응답 지연 이슈

### 01/17 (수)
**작업 요약**: 테스트 커버리지 향상
**배운 점**: Jest mocking 전략
**블로커**: 없음
```

## 데이터 매핑 전략

### Notion → 보고서 매핑

| Notion 데이터 | 보고서 섹션 | 설명 |
|--------------|------------|------|
| Tasks (Done) | 완료한 작업 | 완료 상태의 작업만 |
| Tasks (In Progress) | 진행 중인 작업 | 현재 진행 중 |
| Tasks (Not Started) | 다음 계획 | 예정된 작업 |
| Projects | 프로젝트 현황 | 진행률과 마일스톤 |
| Daily Notes | 일일 요약, 회고 | 배운 점, 블로커 |
| Meeting Notes | 주요 결정사항 | 핵심 의사결정 |

### 우선순위 매핑

```yaml
# Notion의 Priority를 보고서 아이콘으로 변환
priority_mapping:
  High: "🔴"
  Medium: "🟡"
  Low: "🟢"
  None: "⚪"
```

### 상태 매핑

```yaml
# 상태 표시 아이콘
status_mapping:
  Done: "✅"
  In Progress: "🔄"
  Not Started: "⏸️"
  Blocked: "🚧"
  Cancelled: "❌"
```

## MCP 도구 사용 예시

### 데이터베이스 쿼리

```javascript
// Notion MCP 도구 호출 예시
mcp__plugin_work_report_notion__query_database({
  database_id: "abc123",
  filter: {
    property: "Status",
    status: { equals: "Done" }
  },
  sorts: [
    { property: "Updated", direction: "descending" }
  ]
})
```

### 페이지 콘텐츠 읽기

```javascript
// Daily Notes 페이지 읽기
mcp__plugin_work_report_notion__read_page({
  page_id: "page-id-123",
  include_children: true
})
```

### 검색

```javascript
// 특정 기간의 작업 검색
mcp__plugin_work_report_notion__search({
  query: "작업",
  filter: {
    property: "object",
    value: "page"
  },
  sort: {
    direction: "descending",
    timestamp: "last_edited_time"
  }
})
```

## 통합 워크플로우

### 1. 데이터 수집 단계

```
1. Git 데이터 수집 (커밋, 변경 통계)
2. Claude 세션 데이터 수집 (대화 요약)
3. Notion 데이터 수집:
   a. Tasks 데이터베이스 쿼리
   b. Projects 데이터베이스 쿼리
   c. Daily Notes 페이지 읽기
   d. Meeting Notes 검색
```

### 2. 데이터 병합

```
Git Commits + Notion Tasks = 완료한 작업 (이중 검증)
Claude Sessions + Notion Daily Notes = 일일 요약
Notion Projects = 프로젝트 현황
```

### 3. 보고서 생성

```markdown
# 일일 업무 보고서

## 📊 대시보드
[Git + Notion 통합 통계]

## 📝 완료한 작업
[Git 커밋 + Notion Done Tasks 병합]

## 🔄 진행 중인 작업
[Notion In Progress Tasks]

## 📅 다음 계획
[Notion Not Started Tasks]

## 🎯 프로젝트 현황
[Notion Projects 데이터베이스]

## 📖 작업 일지
[Notion Daily Notes + Claude Sessions]

## 🧠 회고
[Notion Daily Notes Learnings + Blockers]
```

## 인증 설정

### Notion API 키 발급

1. Notion 설정 → Integrations
2. "New Integration" 생성
3. Internal Integration Token 복사
4. 환경변수에 저장:

```bash
# Windows
setx NOTION_API_TOKEN "secret_xxx..."

# Linux/macOS
export NOTION_API_TOKEN="secret_xxx..."
```

### 워크스페이스 연결

1. 사용할 Notion 페이지/데이터베이스 열기
2. 우측 상단 "..." → "Add connections"
3. 생성한 Integration 선택

## 성능 최적화

### 배치 쿼리

```javascript
// 여러 데이터베이스를 한 번에 쿼리
const promises = [
  queryDatabase("tasks-db"),
  queryDatabase("projects-db"),
  readPage("daily-notes-page")
];

const [tasks, projects, notes] = await Promise.all(promises);
```

### 캐싱

```yaml
# Notion 데이터 캐싱 설정
notion_cache:
  enabled: true
  ttl: 300  # 5분
  strategy: "smart"  # 변경된 것만 갱신
```

### Rate Limiting

```yaml
# Notion API 속도 제한 준수
notion_rate_limit:
  requests_per_second: 3
  max_retries: 3
  backoff_strategy: "exponential"
```

## 문제 해결

### "Database not found"

- Integration이 데이터베이스에 연결되었는지 확인
- Database ID가 올바른지 확인

### "Unauthorized"

- `NOTION_API_TOKEN` 환경변수 설정 확인
- Token이 만료되지 않았는지 확인

### "Rate limit exceeded"

- 요청 빈도 줄이기
- 배치 쿼리 사용
- 캐싱 활성화

## 예시 시나리오

### 시나리오 1: 일일 스탠드업 보고서

**Notion 구성**:
- Tasks 데이터베이스 (어제 완료한 작업)
- Daily Notes (오늘 계획)

**보고서 생성**:
```bash
/work-report:daily
```

**포함 내용**:
- Git 커밋 (어제)
- Notion Tasks (Status=Done, 어제)
- Notion Daily Notes (오늘)
- 블로커 및 도움 필요 사항

### 시나리오 2: 주간 팀 보고서

**Notion 구성**:
- Tasks 데이터베이스 (주간 작업)
- Projects 데이터베이스 (프로젝트 진행률)
- Meeting Notes (주요 결정사항)

**보고서 생성**:
```bash
/work-report:weekly
```

**포함 내용**:
- Git 통계 (주간)
- Notion Tasks 완료율
- 프로젝트 진행 상황
- 주요 의사결정
- 다음 주 계획

### 시나리오 3: 월간 회고 보고서

**Notion 구성**:
- Projects (월간 마일스톤)
- Daily Notes (전체 회고)
- Retrospective 페이지

**보고서 생성**:
```bash
/work-report:monthly
```

**포함 내용**:
- 월간 성과 요약
- 목표 달성률
- 배운 점 종합
- 개선 사항
- 다음 달 OKR

## 추가 리소스

### Notion API 문서
- [Notion API Reference](https://developers.notion.com/reference)
- [Notion MCP Docs](https://developers.notion.com/docs/mcp)

### 데이터베이스 ID 찾기
URL에서 확인:
```
https://notion.so/myworkspace/[DATABASE_ID]?v=...
                              ^^^^^^^^^^^^^^^^
```

### 유용한 템플릿
- Tasks 데이터베이스 템플릿
- Project Tracker 템플릿
- Daily Notes 템플릿

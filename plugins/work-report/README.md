# Work Report Plugin

작업 내용을 자동으로 수집하여 보고서를 생성하는 Claude Code 플러그인입니다.

## ✨ 새로운 기능 (v1.5.0)

### 📊 Enhanced Report Format (v2.0)
- **시각화 요소**: 진행 바, 스파크라인, 히트맵
- **인사이트 분석**: 핫스팟 파일, 작업 패턴, 생산성 지표
- **비교 분석**: 주간 대비, 목표 대비 트렌드
- **대시보드**: 한눈에 보는 KPI 요약

[📸 Enhanced Report 예시 보기](#enhanced-report-예시)

## 기능

- **일일 보고서** (`/work-report:daily`): 오늘 작업한 내용 요약
- **주간 보고서** (`/work-report:weekly`): 이번 주 작업 내용 정리
- **월간 보고서** (`/work-report:monthly`): 이번 달 작업 내용 정리
- **설정** (`/work-report:configure`): 데이터 소스 및 템플릿 설정
- **멀티 프로젝트 지원**: 여러 프로젝트의 작업을 통합/개별 보고서로 생성

## 데이터 소스

- **Git**: 커밋 로그, 변경 통계 (기본 활성화)
- **Claude**: 현재 세션 대화 내용 분석 (기본 활성화)
- **Notion**: 페이지, 데이터베이스, 작업 관리 (선택적, MCP 자동 포함) ⭐ NEW
- **Jira**: 이슈 및 작업 내역 (선택적, 별도 MCP 필요)
- **Slack**: 메시지 및 스레드 (선택적, 별도 MCP 필요)

## 설치

```bash
# 플러그인 디렉토리에 복사
cp -r work-report ~/.claude/plugins/

# 또는 프로젝트에 직접 포함
cp -r work-report your-project/.claude-plugin/
```

## 설정

프로젝트 루트에 `.claude/work-report.local.md` 파일을 생성하여 설정을 커스터마이즈할 수 있습니다:

```markdown
---
language: ko
output_dir: ./reports
filename_pattern: report-{type}-{date}.md
data_sources:
  - git
  - claude
git_author: your-email@example.com
git_branches: all
---

## 커스텀 템플릿 (선택사항)

여기에 커스텀 보고서 템플릿을 작성할 수 있습니다.
```

### 설정 옵션

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `language` | 보고서 언어 (ko, en) | `ko` |
| `output_dir` | 보고서 저장 디렉토리 | `./reports` |
| `filename_pattern` | 파일명 패턴 | `report-{type}-{date}.md` |
| `data_sources` | 사용할 데이터 소스 | `[git, claude]` |
| `git_author` | Git author 필터 | 현재 사용자 |
| `git_branches` | Git 브랜치 범위 | `all` |
| `report_mode` | 보고서 모드 (combined/separate) | `combined` |
| `projects` | 추가 프로젝트 목록 | `[]` |
| `enable_session_logging` | 세션 작업 요약 자동 저장 | `false` |
| `session_log_dir` | 세션 로그 저장 디렉토리 | `.claude/sessions` |
| `report_format` | 보고서 형식 (enhanced/standard) | `enhanced` |
| `enable_visualizations` | 시각화 요소 활성화 | `true` |
| `enable_insights` | 인사이트 분석 활성화 | `true` |
| `enable_comparisons` | 비교 분석 활성화 | `true` |
| `data_sources` | 사용할 데이터 소스 목록 | `[git, claude]` |

## 세션 로깅 (Opt-in)

Claude 작업 세션의 내용을 자동으로 요약하여 저장하는 기능입니다.

### 활성화 방법

`.claude/work-report.local.md`에서 설정:

```yaml
enable_session_logging: true
# session_log_dir: .claude/sessions  # 기본값, 변경 시 주석 해제
```

### 동작 방식

1. Claude 작업 완료 시 Stop Hook이 트리거됨
2. 설정이 활성화(`true`)되어 있으면 작업 요약 생성
3. `.claude/sessions/` 디렉토리에 `session-{date}-{time}.md` 형식으로 저장

### 저장되는 내용

- 작업 유형 (버그 수정, 기능 추가, 리팩토링 등)
- 변경된 파일 목록
- 주요 결정사항
- 수행한 명령어 요약

### 프라이버시 보호

**⚠️ 민감 정보 보호를 위해 다음 내용은 저장되지 않습니다:**

- API 키, 토큰, 비밀번호
- 경로의 사용자명 (익명화됨)
- 환경변수 값
- 전체 대화 기록 (요약만 저장)

### 기본값이 `false`인 이유

사용자 동의 없이 데이터가 저장되는 것을 방지하기 위해 **Opt-in 방식**을 채택했습니다. 세션 로깅을 원하면 명시적으로 `enable_session_logging: true`로 설정해야 합니다.

### 보고서에서 세션 로그 활용

저장된 세션 로그를 보고서에 포함하려면 `add-project`로 claude 타입 프로젝트를 추가합니다:

```yaml
projects:
  - name: "AI-작업"
    type: "claude"
    path: ".claude/sessions"        # 세션 로그 디렉토리
    session_limit: 10               # 최근 10개 파일만
    file_pattern: "session-*.md"    # 선택: 파일 필터
```

## 멀티 프로젝트 지원

여러 프로젝트의 작업 내용을 한 번에 수집하여 보고서를 생성할 수 있습니다.

### 설정 예시

```yaml
report_mode: combined  # 또는 separate
projects:
  - name: "frontend"
    path: "C:/workspace/frontend-app"
  - name: "backend"
    path: "C:/workspace/backend-api"
    git_author: "backend@team.com"  # 프로젝트별 오버라이드 가능
```

### 보고서 모드

#### combined (통합 보고서)
- 모든 프로젝트를 하나의 보고서에 통합
- 프로젝트별 섹션으로 구분
- 전체 통계 요약 테이블 포함
- 파일명: `report-daily-2024-01-15.md`

#### separate (개별 보고서)
- 각 프로젝트별로 개별 파일 생성
- 파일명: `report-daily-frontend-2024-01-15.md`

### 프로젝트 관리 커맨드

```bash
# 프로젝트 추가
/work-report:configure add-project

# 프로젝트 제거
/work-report:configure remove-project

# 프로젝트 목록 확인
/work-report:configure list-projects
```

## 자동화 (스케줄러)

매일 자동으로 보고서를 생성하려면 `scripts/auto-report.sh`를 사용하세요.

> **보안 참고**: 자동화 스크립트는 `--dangerously-skip-permissions` 플래그를 사용하여
> 무인 실행을 가능하게 합니다. 이 플래그는 Claude Code의 권한 확인을 건너뛰므로,
> 신뢰할 수 있는 환경에서만 사용하세요. 스크립트는 Git 조회와 파일 쓰기만 수행합니다.

### Linux/macOS (cron)

```bash
# 매일 오후 6시에 일일 보고서 생성
0 18 * * * /path/to/work-report/scripts/auto-report.sh daily /path/to/project

# 매주 금요일 오후 6시에 주간 보고서 생성
0 18 * * 5 /path/to/work-report/scripts/auto-report.sh weekly /path/to/project
```

### Windows (Task Scheduler)

PowerShell에서:
```powershell
# 일일 작업 등록
schtasks /create /tn "DailyWorkReport" /tr "C:\path\to\work-report\scripts\auto-report.ps1 daily C:\path\to\project" /sc daily /st 18:00
```

## Enhanced Report 예시

Enhanced Report Format을 활성화하면 다음과 같은 시각화 요소가 포함됩니다:

### 📊 대시보드
```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│   📝 총 커밋 수     │   📂 변경 파일      │   ➕ 추가 라인      │
│       42개          │       67개          │     +2,345         │
│   ▲ +12% (전주)     │   ▲ +8% (전주)      │   ▲ +15% (전주)    │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

### 📈 트렌드 시각화
```
커밋 활동:  ▂▃▅▆▇█▇▅  (월~일)
코드 변경:  ▁▃▄▆▇▇▅▃  (월~일)
```

### 🗺️ 시간대별 히트맵
```
      00-06  06-12  12-18  18-24
월    ⬜⬜⬜  ⬜⬜⬜  🟨🟨🟨  🟩🟩🟩
화    ⬜⬜⬜  ⬜⬜⬜  🟧🟧🟧  🟨🟨🟨
```

### 🔥 핫스팟 파일 분석
| 파일 | 변경 횟수 | 총 변경량 | 분류 |
|------|---------|----------|------|
| `src/api/auth.ts` | 8회 | +234/-89 | 🔴 핫스팟 |
| `src/components/Dashboard.tsx` | 6회 | +189/-45 | 🟡 주의 |

### 📊 기간 비교 분석
| 지표 | 이번 주 | 지난 주 | 변화 | 트렌드 |
|-----|---------|--------|------|-------|
| 커밋 수 | 42 | 35 | +7 | 📈 +20% |
| 변경 파일 | 67 | 58 | +9 | 📈 +16% |

## 보고서 형식 선택

### Enhanced Format (v2.0) - 기본값
시각화 및 인사이트가 풍부한 상세 보고서:
- ✅ 시각적 요소 (진행 바, 차트, 히트맵)
- ✅ 자동 인사이트 생성
- ✅ 비교 분석 및 트렌드
- ✅ 대시보드 뷰

### Standard Format
전통적인 텍스트 기반 보고서:
- 간결한 텍스트 포맷
- 테이블 위주
- 빠른 스캔에 적합

**형식 변경**:
```yaml
# .claude/work-report.local.md
report_format: standard  # 또는 enhanced (기본값)
```

## 보고서 구성

### Standard Format
1. **요약**: 작업 내용 한 줄 요약
2. **완료한 작업**: 완료된 작업 목록
3. **진행 중인 작업**: 현재 진행 중인 작업
4. **다음 계획**: 예정된 작업
5. **코드 변경 통계**: 추가/삭제된 라인 수, 변경된 파일 수
6. **커밋 리스트**: 기간 내 커밋 목록
7. **회고**: 배운 점, 개선할 점

### Enhanced Format (v2.0)
Standard Format의 모든 섹션 + 추가:
1. **대시보드**: KPI 카드 및 주간 트렌드
2. **코드 인사이트**: 핫스팟 파일, 파일 유형 분포, 작업 패턴
3. **기술 스택 분석**: 사용된 언어/도구 통계
4. **기간별 비교**: 이전 기간 대비 변화 추적
5. **목표 추적**: 주간/월간 목표 대비 진행 상황

## 헬퍼 스크립트

Enhanced Report 생성에 사용되는 유틸리티:

```bash
# 기간 비교 분석
./skills/report-writing/scripts/compare-periods.sh "1 week ago" "now"

# 핫스팟 파일 분석
./skills/report-writing/scripts/analyze-hotspots.sh "1 week ago"

# 작업 패턴 분석
./skills/report-writing/scripts/analyze-patterns.sh "1 week ago"
```

PowerShell 버전도 제공됩니다 (`.ps1` 확장자)

## Notion 통합 (v1.5.0) ⭐ NEW

### 개요

Notion 워크스페이스의 데이터를 보고서에 통합하여 완전한 작업 내역을 생성할 수 있습니다.

**통합 효과**:
- Git 커밋 + Notion 작업 = 완전한 작업 목록
- 코드 변경 + 작업 관리 = 컨텍스트가 풍부한 보고서
- 기술적 작업 + 비즈니스 맥락 = 팀 커뮤니케이션 향상

### ⚡ 설정 불필요 (Plug & Play)

**중요**: work-report 플러그인은 Notion MCP 서버를 자체 포함합니다.

```
✅ 필요한 것:
1. work-report 플러그인 설치
2. NOTION_API_TOKEN 환경변수 설정

❌ 필요하지 않은 것:
1. 글로벌 Claude CLI MCP 설정
2. 별도 MCP 서버 설치
3. ~/.claude/config.json 수정
```

**작동 원리**:
- 플러그인 자체에 `.mcp.json` 포함
- 플러그인 로드 시 자동으로 Notion MCP 연결
- 다른 플러그인/세션과 독립적으로 작동

### 빠른 시작

#### 1. Notion Integration 생성

1. [Notion Integrations](https://www.notion.so/my-integrations) 페이지 방문
2. "New Integration" 클릭
3. 이름 입력 (예: "Work Report")
4. **Internal Integration Token** 복사

#### 2. 환경변수 설정

```powershell
# PowerShell (권장)
$env:NOTION_API_TOKEN = "secret_your_token_here"

# 영구 설정 (Windows)
setx NOTION_API_TOKEN "secret_your_token_here"
```

```bash
# Linux/macOS
export NOTION_API_TOKEN="secret_your_token_here"

# 영구 설정 (~/.bashrc 또는 ~/.zshrc에 추가)
echo 'export NOTION_API_TOKEN="secret_your_token_here"' >> ~/.bashrc
```

#### 3. 데이터베이스 연결

사용할 Notion 데이터베이스를 Integration에 연결:

1. Notion에서 Tasks 데이터베이스 열기
2. 우측 상단 `...` → **"Add connections"**
3. 생성한 Integration 선택

#### 4. Database ID 확인

Notion URL에서 Database ID 찾기:

```
https://www.notion.so/workspace/abc123def456789?v=...
                              ^^^^^^^^^^^^^^^^^
                              Database ID
```

#### 5. 설정 추가

`.claude/work-report.local.md` 파일에 추가:

> **💡 참고**: 글로벌 MCP 설정 (`~/.claude/config.json`)은 필요 없습니다!
> work-report 플러그인이 자체적으로 Notion MCP를 관리합니다.

```yaml
---
data_sources:
  - git
  - claude
  - notion  # Notion 활성화

projects:
  - name: "tasks"
    type: "notion"
    database_id: "abc123def456789"  # 여기에 Database ID 입력
    filters:
      assignee: "me"
      status: ["In Progress", "Done"]
      date_range: "this_week"
---
```

### 사용 예시

#### 시나리오 1: Tasks 데이터베이스 연동

**Notion 구성**:
```
Tasks 데이터베이스 필드:
- Title (작업명)
- Status (Not Started / In Progress / Done)
- Assignee (담당자)
- Due Date (마감일)
- Priority (High / Medium / Low)
- Tags (카테고리)
```

**설정**:
```yaml
projects:
  - name: "my-tasks"
    type: "notion"
    database_id: "your-database-id"
    filters:
      assignee: "me"
      status: ["Done", "In Progress"]
      date_property: "Updated"
      date_range: "this_week"
```

**보고서 결과**:
```markdown
## 📝 Notion Tasks

### ✅ 완료한 작업 (5개)
- **[TASK-001]** API 성능 최적화 완료
  - 상태: Done | 완료일: 01/18 | 우선순위: High
  - Git: commit a1b2c3d

- **[TASK-002]** 사용자 대시보드 UI 개선
  - 상태: Done | 완료일: 01/17 | 우선순위: Medium
  - Git: commit e4f5g6h

### 🔄 진행 중 (3개)
- **[TASK-010]** 테스트 자동화 구축 (60% 완료)
- **[TASK-011]** 모바일 반응형 적용
```

#### 시나리오 2: 다중 데이터베이스

**설정**:
```yaml
projects:
  - name: "sprint-tasks"
    type: "notion"
    database_id: "tasks-db-id"
    filters:
      status: ["Done"]
      tags: ["sprint-23"]

  - name: "projects"
    type: "notion"
    database_id: "projects-db-id"
    filters:
      status: ["Active", "Completed"]

  - name: "daily-notes"
    type: "notion"
    page_id: "notes-page-id"
    recursive: true  # 하위 페이지 포함
```

### 고급 필터링

```yaml
# AND 조건
filters:
  and:
    - property: "Sprint"
      select: "Sprint 23"
    - property: "Status"
      status: ["Done", "In Progress"]
    - property: "Priority"
      select: ["High", "Medium"]

# 정렬
sorts:
  - property: "Priority"
    direction: "ascending"
  - property: "Due Date"
    direction: "ascending"
```

### 데이터 매핑

| Notion 필드 | 보고서 섹션 | 표시 방식 |
|------------|------------|----------|
| Status: Done | 완료한 작업 | ✅ 체크 표시 |
| Status: In Progress | 진행 중 | 🔄 진행률 표시 |
| Status: Not Started | 다음 계획 | 📅 예정 표시 |
| Priority: High | 우선순위 | 🔴 High |
| Priority: Medium | 우선순위 | 🟡 Medium |
| Priority: Low | 우선순위 | 🟢 Low |
| Due Date | 마감일 | 날짜 표시 |

### Git + Notion 통합 예시

**보고서 출력**:
```markdown
## 완료한 작업

### 코드 작업 (Git)
- feat: 사용자 인증 API 구현 (commit a1b2c3d)
  - 파일: 3개 변경
  - 라인: +234/-89

### 작업 관리 (Notion)
- ✅ [TASK-123] 사용자 인증 시스템 구축
  - 상태: Done
  - 완료일: 2024-01-18
  - 관련 커밋: a1b2c3d

👉 **Git 커밋과 Notion 작업이 자동으로 연결됩니다!**
```

### 문제 해결

#### "Database not found" 오류

- Integration이 데이터베이스에 연결되었는지 확인
- Database ID가 정확한지 확인
- 페이지 접근 권한 확인

#### "Unauthorized" 오류

```bash
# 환경변수 확인
echo $NOTION_API_TOKEN  # Linux/macOS
echo %NOTION_API_TOKEN%  # Windows CMD
$env:NOTION_API_TOKEN    # PowerShell

# 재설정
export NOTION_API_TOKEN="secret_xxx..."
```

#### MCP 연결 확인

```bash
# Claude Code에서 MCP 서버 확인
/mcp

# Notion MCP가 목록에 있는지 확인
# notion: https://mcp.notion.com/mcp
```

### 상세 가이드

Notion 통합 패턴 및 예시는 다음 문서를 참조하세요:
- **`skills/data-source-patterns/references/notion-patterns.md`** - 상세 패턴 및 예시

## 라이선스

MIT

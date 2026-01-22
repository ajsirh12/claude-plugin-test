---
description: work-report 플러그인 설정 관리
argument-hint: [action]
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

work-report 플러그인의 설정을 관리한다.

## 인자 처리

- `$1`: 액션 (선택)
  - 미지정 또는 `show`: 현재 설정 표시
  - `init`: 새 설정 파일 생성 (대화형)
  - `edit`: 기존 설정 수정 (대화형)
  - `reset`: 설정을 기본값으로 초기화
  - `add-project`: 새 프로젝트 추가 (대화형)
  - `remove-project`: 프로젝트 제거 (대화형)
  - `list-projects`: 등록된 프로젝트 목록 표시

## 설정 파일 위치

프로젝트 루트: `.claude/work-report.local.md`

## 액션별 동작

### show (기본)

현재 설정을 읽어서 표시한다:

1. `.claude/work-report.local.md` 파일 확인
2. 파일이 있으면 YAML frontmatter 파싱하여 표시
3. 파일이 없으면 기본 설정값 표시

출력 형식:
```
📋 Work Report 설정

현재 설정:
┌─────────────────┬────────────────────────┐
│ 항목            │ 값                     │
├─────────────────┼────────────────────────┤
│ 언어            │ ko                     │
│ 저장 디렉토리   │ ./reports              │
│ 파일명 패턴     │ report-{type}-{date}.md│
│ 데이터 소스     │ git, claude            │
│ Git Author      │ user@example.com       │
│ Git 브랜치      │ all                    │
│ 보고서 모드     │ combined               │
└─────────────────┴────────────────────────┘

📁 등록된 프로젝트:
┌─────────────────┬────────────────────────────────────────┐
│ 이름            │ 경로                                   │
├─────────────────┼────────────────────────────────────────┤
│ code-pilot      │ C:/workspace/code-pilot (현재)         │
│ my-app          │ C:/workspace/my-app                    │
│ backend-api     │ C:/workspace/backend-api               │
└─────────────────┴────────────────────────────────────────┘

설정 파일: .claude/work-report.local.md
```

프로젝트가 없으면 "등록된 프로젝트" 섹션을 표시하지 않고 현재 디렉토리만 사용됨을 안내한다.

### init

대화형으로 새 설정 파일을 생성한다:

1. AskUserQuestion 도구를 사용하여 각 설정 항목 질문:
   - 보고서 언어 (ko/en)
   - 저장 디렉토리
   - 파일명 패턴
   - 데이터 소스 선택
   - Git author 이메일
   - Git 브랜치 범위
   - **보고서 모드 (combined/separate)** - 새로 추가
   - **추가 프로젝트 등록 여부** - 새로 추가

2. 입력받은 값으로 `.claude/work-report.local.md` 파일 생성:

```markdown
---
language: ko
output_dir: ./reports
filename_pattern: report-{type}-{date}.md
data_sources:
  - git
  - claude
git_author: user@example.com
git_branches: all

# 멀티 프로젝트 설정
report_mode: combined  # combined(통합) | separate(개별)
projects: []           # 추가 프로젝트 목록 (빈 배열이면 현재 디렉토리만 사용)
---

# Work Report 설정

이 파일은 work-report 플러그인의 설정을 저장합니다.
아래에 커스텀 템플릿을 추가할 수 있습니다.

## 커스텀 섹션 (선택사항)

보고서에 추가하고 싶은 커스텀 섹션이 있다면 여기에 작성하세요.
```

3. `.claude` 디렉토리가 없으면 먼저 생성

### add-project

새 프로젝트를 설정에 추가한다:

1. AskUserQuestion으로 프로젝트 정보 입력받기:
   - 프로젝트 이름 (식별용)
   - 프로젝트 경로 (절대 경로 권장)
   - Git author 오버라이드 (선택, 글로벌 설정 상속 가능)
   - Git branches 오버라이드 (선택, 글로벌 설정 상속 가능)

2. 경로 유효성 검사:
   - 디렉토리 존재 여부 확인
   - .git 폴더 존재 여부 확인
   - 중복 등록 방지

3. 설정 파일의 `projects` 배열에 추가:

```yaml
projects:
  - name: "new-project"
    path: "/path/to/project"
    git_author: "optional@override.com"  # 선택적
    git_branches: "main"                  # 선택적
```

### remove-project

등록된 프로젝트를 제거한다:

1. 현재 등록된 프로젝트 목록 표시
2. AskUserQuestion으로 제거할 프로젝트 선택
3. 확인 후 `projects` 배열에서 제거

### list-projects

등록된 프로젝트 목록을 상세히 표시한다:

```
📁 등록된 프로젝트 (3개)

1. code-pilot (현재 디렉토리)
   경로: C:/workspace/code-pilot
   Author: ajsirh12@withnetworks.com (글로벌)
   Branches: all (글로벌)
   상태: ✓ 유효

2. my-app
   경로: C:/workspace/my-app
   Author: ajsirh12@withnetworks.com (글로벌)
   Branches: main (오버라이드)
   상태: ✓ 유효

3. old-project
   경로: C:/workspace/old-project
   상태: ✗ 경로 없음
```

### edit

기존 설정을 대화형으로 수정한다:

1. 현재 설정 파일 읽기
2. 수정할 항목 선택 (AskUserQuestion 사용)
3. 선택한 항목의 새 값 입력받기
4. 설정 파일 업데이트

### reset

설정을 기본값으로 초기화한다:

1. 사용자에게 확인 요청
2. 확인 시 기본 설정으로 파일 재생성

기본 설정값:
```yaml
language: ko
output_dir: ./reports
filename_pattern: report-{type}-{date}.md
data_sources:
  - git
  - claude
git_author: (git config user.email 값)
git_branches: all
report_mode: combined
projects: []
```

## 설정 항목 상세

### language
- 설명: 보고서 작성 언어
- 타입: string
- 값: `ko` (한국어), `en` (영어)
- 기본값: `ko`

### output_dir
- 설명: 보고서 저장 디렉토리
- 타입: string (경로)
- 예시: `./reports`, `~/Documents/reports`
- 기본값: `./reports`

### filename_pattern
- 설명: 보고서 파일명 패턴
- 타입: string
- 변수: `{type}` (daily/weekly/monthly), `{date}` (YYYY-MM-DD)
- 기본값: `report-{type}-{date}.md`

### data_sources
- 설명: 데이터 수집 소스
- 타입: array
- 값: `git`, `claude`, `jira`, `slack`
- 기본값: `[git, claude]`
- 참고: jira, slack은 별도 MCP 서버 설정 필요

### git_author
- 설명: Git 커밋 필터링할 author 이메일
- 타입: string
- 기본값: `git config user.email` 값

### git_branches
- 설명: Git 데이터 수집 브랜치 범위
- 타입: string
- 값: `all` (모든 브랜치), `current` (현재 브랜치만), 특정 브랜치명
- 기본값: `all`

### report_mode
- 설명: 멀티 프로젝트 보고서 생성 모드
- 타입: string
- 값:
  - `combined`: 모든 프로젝트를 하나의 통합 보고서로 생성
  - `separate`: 각 프로젝트별 개별 보고서 생성
- 기본값: `combined`

### projects
- 설명: 추가로 데이터를 수집할 프로젝트 목록
- 타입: array
- 각 항목:
  - `name`: 프로젝트 식별 이름 (필수)
  - `path`: 프로젝트 절대 경로 (필수)
  - `git_author`: Git author 오버라이드 (선택, 글로벌 설정 상속)
  - `git_branches`: Git 브랜치 오버라이드 (선택, 글로벌 설정 상속)
- 기본값: `[]` (빈 배열 - 현재 디렉토리만 사용)
- 예시:
```yaml
projects:
  - name: "frontend"
    path: "C:/workspace/frontend-app"
  - name: "backend"
    path: "C:/workspace/backend-api"
    git_author: "backend@team.com"
    git_branches: "main,develop"
```

## 멀티 프로젝트 동작 방식

### combined 모드
- 모든 프로젝트의 커밋을 하나의 보고서에 통합
- 프로젝트별 섹션으로 구분하여 표시
- 전체 통계 요약 제공
- 파일명: `report-{type}-{date}.md`

### separate 모드
- 각 프로젝트별로 개별 보고서 파일 생성
- 파일명: `report-{type}-{project}-{date}.md`
- 예: `report-daily-frontend-2024-01-15.md`

### 프로젝트 우선순위
1. `projects` 배열에 등록된 프로젝트
2. 현재 작업 디렉토리 (projects가 비어있을 경우)

## 데이터 소스별 추가 설정

### Jira (선택적)
```yaml
jira:
  project_key: PROJ
  include_subtasks: true
```
참고: Jira MCP 서버가 별도로 설정되어 있어야 합니다.

### Slack (선택적)
```yaml
slack:
  channels:
    - general
    - dev-team
  include_threads: true
```
참고: Slack MCP 서버가 별도로 설정되어 있어야 합니다.

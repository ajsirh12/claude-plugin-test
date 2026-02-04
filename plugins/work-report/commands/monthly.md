---
description: 월간/스프린트 업무 보고서 생성
argument-hint: [period] [output-path]
allowed-tools: Read, Write, Bash, Glob, Grep
---

지정된 기간의 작업 내용을 분석하여 월간 또는 스프린트 보고서를 생성한다.

## 인자 처리

- `$1`: 기간 지정 (선택)
  - `month` 또는 미지정: 이번 달 (기본값)
  - `last-month`: 지난 달
  - `sprint`: 최근 2주
  - `YYYY-MM`: 특정 년월 (예: 2024-01)
- `$2`: 저장 경로 (선택)

## 데이터 수집

### 1. 설정 파일 확인
먼저 `.claude/work-report.local.md` 파일이 있는지 확인하고, 있으면 YAML frontmatter에서 설정을 읽는다:
- `language`: 보고서 언어 (기본: ko)
- `output_dir`: 저장 디렉토리 (기본: ./reports)
- `git_author`: Git author 필터 (기본: 현재 사용자)
- `git_branches`: Git 브랜치 범위 (기본: all)
- `report_mode`: 보고서 모드 (기본: combined)
- `projects`: 추가 프로젝트 목록 (기본: [] - 현재 디렉토리만)

### 2. 기간 계산
- `month`: 이번 달 1일부터 오늘까지
- `last-month`: 지난 달 1일부터 말일까지
- `sprint`: 오늘로부터 14일 전부터 오늘까지
- `YYYY-MM`: 해당 년월 1일부터 말일까지

### 3. Git 데이터 수집

#### 단일 프로젝트 (projects가 비어있는 경우)
현재 디렉토리에서 Git 명령어를 실행:

```bash
# 기간 내 커밋 로그 조회 (모든 브랜치, 본인 커밋만)
git log --all --author="$(git config user.email)" --since="[시작일]" --until="[종료일]" --format="%h|%s|%ad" --date=short

# 변경된 파일 통계
git log --all --author="$(git config user.email)" --since="[시작일]" --until="[종료일]" --stat --format=""

# 추가/삭제된 라인 수
git log --all --author="$(git config user.email)" --since="[시작일]" --until="[종료일]" --numstat --format=""

# 주별 커밋 수
git log --all --author="$(git config user.email)" --since="[시작일]" --until="[종료일]" --format="%ad" --date=format:"%Y-W%V" | sort | uniq -c
```

#### 멀티 프로젝트 (projects에 프로젝트가 등록된 경우)
각 프로젝트 디렉토리로 이동하여 Git 명령어를 실행:

```bash
# 각 프로젝트별로 반복 실행
for project in projects:
  cd {project.path}
  AUTHOR={project.git_author || global.git_author}
  BRANCHES={project.git_branches || global.git_branches}

  git log --all --author="$AUTHOR" --since="[시작일]" --until="[종료일]" --format="%h|%s|%ad" --date=short
  git log --all --author="$AUTHOR" --since="[시작일]" --until="[종료일]" --stat --format=""
  git log --all --author="$AUTHOR" --since="[시작일]" --until="[종료일]" --numstat --format=""
  git log --all --author="$AUTHOR" --since="[시작일]" --until="[종료일]" --format="%ad" --date=format:"%Y-W%V" | sort | uniq -c
```

수집된 데이터는 프로젝트별로 구분하여 저장한다.

### 4. Slack 데이터 수집 (data_sources에 slack이 포함된 경우)

설정의 `data_sources`에 `slack`이 포함되어 있거나, `projects`에 `type: "slack"` 항목이 있는 경우 수집한다.

#### 사전 조건 확인
1. `SLACK_BOT_TOKEN` 환경변수 설정 확인
2. MCP 연결 상태 확인 (연결 안 됨 시 경고 출력 후 스킵)

#### 데이터 수집 절차
projects에서 `type: "slack"`인 항목을 찾아 각각 처리:

```
for project in projects where type == "slack":
  channel = project.channel
  include_threads = project.include_threads || false
  limit = project.limit || 500  # 월간은 더 많은 메시지

  1. 채널 접근 확인
  2. 기간에 따라 메시지 수집:
     - month: 이번 달 1일부터 (최근 30일)
     - last-month: 지난 달 전체
     - sprint: 최근 14일
     - YYYY-MM: 해당 월 전체
  3. 메시지 분석 및 요약:
     - 주요 논의 추출 (주별로 그룹화)
     - 결정사항 정리
     - 공지사항 식별
     - Action Items 추출
     - 월간 트렌드 분석
     - 가장 활발한 토픽 Top 5
```

#### 출력 형식
수집된 Slack 데이터는 report-writing 스킬의 "💬 Slack 논의 요약" 섹션 양식에 맞게 정리:
- 채널별로 메시지 수, 스레드 수 표시
- 주요 논의를 토픽별로 그룹화
- 결정사항과 Action Items 명확히 분리
- 월간이므로 주별 주요 논의 요약 및 트렌드 분석 포함

## 보고서 작성

**report-writing 스킬의 Report Template 양식을 참조하여 보고서를 작성한다.**

### 양식 적용 방법
1. `report-writing` 스킬의 "Report Structure" > "Report Template" 섹션에 정의된 표준 양식을 기본으로 사용
2. `[보고서 종류]`를 "월간" 또는 "스프린트"로 설정 (인자에 따라)
3. `기간`은 계산된 시작일~종료일로 설정
4. "날짜별 작업 요약" 섹션에 주차별 활동 내역 포함
5. 수집된 Git 데이터와 대화 내용을 양식의 각 섹션에 맞게 채움

### 월간/스프린트 보고서 추가 고려사항
- 기간이 길므로 "주요 작업 상세" 섹션에 더 많은 항목 포함
- "개발 생산성 지표"에 주별 추이 데이터 추가
- "회고" 섹션에 기간 전체에 대한 종합적인 평가 포함

## 파일 저장

1. 인자로 경로가 주어지면 ($2) 해당 경로에 저장
2. 인자가 없으면 설정의 `output_dir`에 저장
3. 설정도 없으면 `./reports/`에 저장

### 파일명 규칙

**combined 모드:**
- 월간: `report-monthly-YYYY-MM.md`
- 스프린트: `report-sprint-YYYY-MM-DD.md`
- 하나의 통합 보고서 파일 생성
- 프로젝트별 섹션으로 구분하여 표시

**separate 모드:**
- 월간: `report-monthly-{project-name}-YYYY-MM.md`
- 스프린트: `report-sprint-{project-name}-YYYY-MM-DD.md`
- 프로젝트 수만큼 개별 파일 생성

저장 전에 디렉토리가 없으면 생성한다.

## 멀티 프로젝트 통합 보고서 추가 섹션

combined 모드에서 여러 프로젝트가 있을 경우, 보고서에 다음 섹션이 추가된다:

```markdown
## 프로젝트별 성과 요약

| 프로젝트 | 커밋 수 | 변경 파일 | +라인 | -라인 | 주요 성과 |
|----------|---------|-----------|-------|-------|-----------|
| code-pilot | 45 | 80 | +2000 | -500 | 플러그인 시스템 완성 |
| my-app | 30 | 50 | +1200 | -300 | 인증 기능 구현 |
| **합계** | **75** | **130** | **+3200** | **-800** | - |

## 프로젝트별 상세 리포트

### 📁 code-pilot
[프로젝트별 주차별 활동, 커밋 리스트, 상세 통계]

### 📁 my-app
[프로젝트별 주차별 활동, 커밋 리스트, 상세 통계]
```

---
description: 주간 업무 보고서 생성
argument-hint: [output-path]
allowed-tools: Read, Write, Bash, Glob, Grep
---

이번 주의 작업 내용을 분석하여 주간 보고서를 생성한다.

## 데이터 수집

### 1. 설정 파일 확인
먼저 `.claude/work-report.local.md` 파일이 있는지 확인하고, 있으면 YAML frontmatter에서 설정을 읽는다:
- `language`: 보고서 언어 (기본: ko)
- `output_dir`: 저장 디렉토리 (기본: ./reports)
- `git_author`: Git author 필터 (기본: 현재 사용자)
- `git_branches`: Git 브랜치 범위 (기본: all)
- `report_mode`: 보고서 모드 (기본: combined)
- `projects`: 추가 프로젝트 목록 (기본: [] - 현재 디렉토리만)

### 2. Git 데이터 수집

#### 단일 프로젝트 (projects가 비어있는 경우)
현재 디렉토리에서 Git 명령어를 실행:

```bash
# 이번 주 월요일부터 커밋 로그 조회 (모든 브랜치, 본인 커밋만)
git log --all --author="$(git config user.email)" --since="last monday" --format="%h|%s|%ad" --date=short

# 변경된 파일 통계
git log --all --author="$(git config user.email)" --since="last monday" --stat --format=""

# 추가/삭제된 라인 수
git log --all --author="$(git config user.email)" --since="last monday" --numstat --format=""

# 일별 커밋 수
git log --all --author="$(git config user.email)" --since="last monday" --format="%ad" --date=short | sort | uniq -c
```

#### 멀티 프로젝트 (projects에 프로젝트가 등록된 경우)
각 프로젝트 디렉토리로 이동하여 Git 명령어를 실행:

```bash
# 각 프로젝트별로 반복 실행
for project in projects:
  cd {project.path}
  AUTHOR={project.git_author || global.git_author}
  BRANCHES={project.git_branches || global.git_branches}

  git log --all --author="$AUTHOR" --since="last monday" --format="%h|%s|%ad" --date=short
  git log --all --author="$AUTHOR" --since="last monday" --stat --format=""
  git log --all --author="$AUTHOR" --since="last monday" --numstat --format=""
  git log --all --author="$AUTHOR" --since="last monday" --format="%ad" --date=short | sort | uniq -c
```

수집된 데이터는 프로젝트별로 구분하여 저장한다.

### 3. Claude 대화 분석
현재 및 최근 세션에서 진행한 대화 내용을 분석하여:
- 완료한 작업 목록
- 해결한 문제들
- 주요 기능 개발 내역
- 논의한 주제들

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
  limit = project.limit || 200  # 주간은 더 많은 메시지

  1. 채널 접근 확인
  2. 이번 주 월요일부터 메시지 수집 (since: last monday, 최근 7일)
  3. 메시지 분석 및 요약:
     - 주요 논의 추출 (일별로 그룹화)
     - 결정사항 정리
     - 공지사항 식별
     - Action Items 추출
     - 주간 트렌드 분석
```

#### 출력 형식
수집된 Slack 데이터는 report-writing 스킬의 "💬 Slack 논의 요약" 섹션 양식에 맞게 정리:
- 채널별로 메시지 수, 스레드 수 표시
- 주요 논의를 토픽별로 그룹화
- 결정사항과 Action Items 명확히 분리
- 주간이므로 일별 주요 논의 요약 포함

## 보고서 작성

**report-writing 스킬의 Report Template 양식을 정확히 따라 보고서를 작성한다.**

### 양식 적용 방법
1. `report-writing` 스킬의 "Report Structure" > "Report Template" 섹션에 정의된 표준 양식을 **정확히** 사용
2. `[보고서 종류]`를 "주간"으로 설정
3. `기간`은 이번 주 월요일부터 오늘까지로 설정
4. 수집된 Git 데이터와 대화 내용을 양식의 각 섹션에 맞게 채움

### 제외 항목 (반드시 준수)
- **커밋 내역 테이블 제외**: 개별 커밋의 해시, 메시지, 날짜를 나열하는 테이블은 포함하지 않음
- **다음 주 계획 제외**: "다음 주 계획" 또는 유사한 미래 계획 섹션은 포함하지 않음

## 파일 저장

1. 인자로 경로가 주어지면 ($1) 해당 경로에 저장
2. 인자가 없으면 설정의 `output_dir`에 저장
3. 설정도 없으면 `./reports/`에 저장

### 파일명 규칙

**combined 모드:**
- 파일명: `report-weekly-YYYY-MM-DD.md` (주의 마지막 날짜 기준)
- 하나의 통합 보고서 파일 생성
- 프로젝트별 섹션으로 구분하여 표시

**separate 모드:**
- 파일명: `report-weekly-{project-name}-YYYY-MM-DD.md`
- 프로젝트 수만큼 개별 파일 생성

저장 전에 디렉토리가 없으면 생성한다.

## 멀티 프로젝트 처리

combined 모드에서 여러 프로젝트가 있을 경우:
- "개발 생산성 지표" 섹션의 테이블에 모든 프로젝트를 포함
- "주요 작업 상세" 섹션에서 프로젝트별로 구분하여 작성
- 개별 커밋 내역 테이블은 포함하지 않음

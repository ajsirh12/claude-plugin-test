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

## 보고서 작성

다음 형식으로 보고서를 작성한다:

```markdown
# 주간 업무 보고서

**기간**: YYYY-MM-DD ~ YYYY-MM-DD
**작성자**: [Git author name]

## 요약
[이번 주 작업 내용을 2-3문장으로 요약]

## 주요 성과
### 완료한 작업
- [완료한 작업 1]
- [완료한 작업 2]
...

### 주요 기능/개선사항
- [기능 1]: 설명
- [기능 2]: 설명
...

## 진행 중인 작업
- [진행 중인 작업 1] - 진행률 N%
- [진행 중인 작업 2] - 진행률 N%
...

## 다음 주 계획
- [예정된 작업 1]
- [예정된 작업 2]
...

## 코드 변경 통계

### 전체 통계
| 항목 | 수치 |
|------|------|
| 총 커밋 수 | N개 |
| 변경된 파일 | N개 |
| 추가된 라인 | +N |
| 삭제된 라인 | -N |

### 일별 활동
| 날짜 | 커밋 수 |
|------|---------|
| 월요일 | N개 |
| 화요일 | N개 |
...

## 커밋 리스트
| 해시 | 메시지 | 날짜 |
|------|--------|------|
| abc1234 | feat: ... | YYYY-MM-DD |
...

## 이슈 및 블로커
- [이슈 1]: 현황 및 대응 방안
- [이슈 2]: 현황 및 대응 방안
...

## 회고
### 이번 주 잘한 점
- [잘한 점 1]

### 개선이 필요한 점
- [개선할 점 1]

### 배운 점
- [배운 점 1]

---
*이 보고서는 work-report 플러그인에 의해 자동 생성되었습니다.*
```

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

## 멀티 프로젝트 통합 보고서 추가 섹션

combined 모드에서 여러 프로젝트가 있을 경우, 보고서에 다음 섹션이 추가된다:

```markdown
## 프로젝트별 활동 요약

| 프로젝트 | 커밋 수 | 변경 파일 | +라인 | -라인 |
|----------|---------|-----------|-------|-------|
| code-pilot | 10 | 15 | +500 | -100 |
| my-app | 5 | 8 | +200 | -50 |
| **합계** | **15** | **23** | **+700** | **-150** |

## 프로젝트별 상세

### 📁 code-pilot
[프로젝트별 커밋 리스트 및 상세 통계]

### 📁 my-app
[프로젝트별 커밋 리스트 및 상세 통계]
```

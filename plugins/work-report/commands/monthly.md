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

## 보고서 작성

다음 형식으로 보고서를 작성한다:

```markdown
# [월간/스프린트] 업무 보고서

**기간**: YYYY-MM-DD ~ YYYY-MM-DD
**작성자**: [Git author name]
**보고서 유형**: [월간 보고서 / 스프린트 보고서]

## Executive Summary
[기간 내 주요 성과와 활동을 3-5문장으로 요약]

## 주요 성과

### 완료한 프로젝트/기능
1. **[프로젝트/기능 1]**
   - 설명: ...
   - 영향: ...

2. **[프로젝트/기능 2]**
   - 설명: ...
   - 영향: ...

### 핵심 지표
| 지표 | 목표 | 달성 |
|------|------|------|
| 커밋 수 | - | N개 |
| 완료 작업 | - | N개 |
| 코드 라인 변경 | - | +N/-N |

## 상세 활동 내역

### 주차별 활동
#### Week 1 (MM/DD - MM/DD)
- 주요 작업 내용
- 커밋 수: N개

#### Week 2 (MM/DD - MM/DD)
- 주요 작업 내용
- 커밋 수: N개

[주차별 반복]

## 코드 변경 통계

### 전체 통계
| 항목 | 수치 |
|------|------|
| 총 커밋 수 | N개 |
| 변경된 파일 | N개 |
| 추가된 라인 | +N |
| 삭제된 라인 | -N |
| 순 변경 라인 | ±N |

### 주별 활동 추이
| 주차 | 커밋 수 | 변경 라인 |
|------|---------|-----------|
| Week 1 | N개 | +N/-N |
| Week 2 | N개 | +N/-N |
...

### 파일 타입별 변경
| 파일 타입 | 파일 수 | 변경 라인 |
|-----------|---------|-----------|
| .ts/.tsx | N개 | +N/-N |
| .js/.jsx | N개 | +N/-N |
...

## 진행 중인 작업
- [진행 중인 작업 1] - 진행률 N%, 예상 완료일
- [진행 중인 작업 2] - 진행률 N%, 예상 완료일

## 이슈 및 리스크
| 이슈 | 영향도 | 현황 | 대응 방안 |
|------|--------|------|-----------|
| [이슈 1] | 높음/중간/낮음 | 진행중/해결 | ... |
...

## 다음 기간 계획

### 우선순위 작업
1. [작업 1] - 예상 기간
2. [작업 2] - 예상 기간

### 목표
- [목표 1]
- [목표 2]

## 회고

### 잘한 점
- [잘한 점 1]
- [잘한 점 2]

### 개선할 점
- [개선할 점 1]
- [개선할 점 2]

### 배운 점
- [배운 점 1]
- [배운 점 2]

---
*이 보고서는 work-report 플러그인에 의해 자동 생성되었습니다.*
```

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

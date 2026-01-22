---
description: 일일 업무 보고서 생성
argument-hint: [output-path]
allowed-tools: Read, Write, Bash, Glob, Grep
---

오늘 하루의 작업 내용을 분석하여 일일 보고서를 생성한다.

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
# 오늘 날짜 기준으로 커밋 로그 조회 (모든 브랜치, 본인 커밋만)
git log --all --author="$(git config user.email)" --since="midnight" --format="%h|%s|%ad" --date=short

# 변경된 파일 통계
git log --all --author="$(git config user.email)" --since="midnight" --stat --format=""

# 추가/삭제된 라인 수
git log --all --author="$(git config user.email)" --since="midnight" --numstat --format=""
```

#### 멀티 프로젝트 (projects에 프로젝트가 등록된 경우)
각 프로젝트 디렉토리로 이동하여 Git 명령어를 실행:

```bash
# 각 프로젝트별로 반복 실행
for project in projects:
  cd {project.path}

  # author는 프로젝트별 오버라이드 또는 글로벌 설정 사용
  AUTHOR={project.git_author || global.git_author}
  BRANCHES={project.git_branches || global.git_branches}

  git log --all --author="$AUTHOR" --since="midnight" --format="%h|%s|%ad" --date=short
  git log --all --author="$AUTHOR" --since="midnight" --stat --format=""
  git log --all --author="$AUTHOR" --since="midnight" --numstat --format=""
```

수집된 데이터는 프로젝트별로 구분하여 저장한다.

### 3. Claude 대화 분석
현재 세션에서 진행한 대화 내용을 분석하여:
- 완료한 작업 목록
- 해결한 문제들
- 작성/수정한 코드
- 논의한 주제들

## 보고서 작성

### report_mode: combined (통합 보고서)

여러 프로젝트의 작업 내용을 하나의 보고서로 통합:

```markdown
# 일일 업무 보고서

**날짜**: YYYY-MM-DD
**작성자**: [Git author name]

## 요약
[오늘 작업 내용을 1-2문장으로 요약]

## 완료한 작업
- [완료한 작업 1]
- [완료한 작업 2]
...

## 진행 중인 작업
- [진행 중인 작업 1]
- [진행 중인 작업 2]
...

## 다음 계획
- [예정된 작업 1]
- [예정된 작업 2]
...

## 프로젝트별 코드 변경

### 📁 code-pilot
| 항목 | 수치 |
|------|------|
| 커밋 수 | N개 |
| 변경된 파일 | N개 |
| 추가된 라인 | +N |
| 삭제된 라인 | -N |

#### 커밋 리스트
| 해시 | 메시지 |
|------|--------|
| abc1234 | feat: ... |

### 📁 my-app
| 항목 | 수치 |
|------|------|
| 커밋 수 | N개 |
| 변경된 파일 | N개 |
| 추가된 라인 | +N |
| 삭제된 라인 | -N |

#### 커밋 리스트
| 해시 | 메시지 |
|------|--------|
| def5678 | fix: ... |

## 전체 통계 요약
| 프로젝트 | 커밋 | 파일 | +라인 | -라인 |
|----------|------|------|-------|-------|
| code-pilot | 3 | 5 | +120 | -30 |
| my-app | 2 | 3 | +50 | -10 |
| **합계** | **5** | **8** | **+170** | **-40** |

## 회고
### 배운 점
- [배운 점 1]

### 개선할 점
- [개선할 점 1]

---
*이 보고서는 work-report 플러그인에 의해 자동 생성되었습니다.*
```

### report_mode: separate (개별 보고서)

각 프로젝트별로 개별 보고서 파일을 생성:
- 파일명: `report-daily-{project-name}-YYYY-MM-DD.md`
- 각 보고서는 해당 프로젝트의 데이터만 포함
- 기존 단일 프로젝트 보고서 형식과 동일

```markdown
# 일일 업무 보고서 - code-pilot

**날짜**: YYYY-MM-DD
**작성자**: [Git author name]
**프로젝트**: code-pilot

## 요약
[이 프로젝트에서 오늘 작업한 내용 요약]

## 완료한 작업
...

## 코드 변경 통계
| 항목 | 수치 |
|------|------|
| 커밋 수 | N개 |
| 변경된 파일 | N개 |
| 추가된 라인 | +N |
| 삭제된 라인 | -N |

## 커밋 리스트
| 해시 | 메시지 | 날짜 |
|------|--------|------|
| abc1234 | feat: ... | YYYY-MM-DD |
...

---
*이 보고서는 work-report 플러그인에 의해 자동 생성되었습니다.*
```

## 파일 저장

1. 인자로 경로가 주어지면 ($1) 해당 경로에 저장
2. 인자가 없으면 설정의 `output_dir`에 저장
3. 설정도 없으면 `./reports/`에 저장

### 파일명 규칙

**combined 모드:**
- 파일명: `report-daily-YYYY-MM-DD.md`
- 하나의 통합 보고서 파일 생성

**separate 모드:**
- 파일명: `report-daily-{project-name}-YYYY-MM-DD.md`
- 프로젝트 수만큼 개별 파일 생성
- 예시:
  - `report-daily-code-pilot-2024-01-15.md`
  - `report-daily-my-app-2024-01-15.md`

저장 전에 디렉토리가 없으면 생성한다.

## 완료 메시지

생성 완료 후 다음 정보를 표시:
- 생성된 파일 경로(들)
- 수집된 프로젝트 수
- 총 커밋 수
- report_mode (combined/separate)

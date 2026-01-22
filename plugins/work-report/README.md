# Work Report Plugin

작업 내용을 자동으로 수집하여 보고서를 생성하는 Claude Code 플러그인입니다.

## 기능

- **일일 보고서** (`/work-report:daily`): 오늘 작업한 내용 요약
- **주간 보고서** (`/work-report:weekly`): 이번 주 작업 내용 정리
- **월간 보고서** (`/work-report:monthly`): 이번 달 작업 내용 정리
- **설정** (`/work-report:configure`): 데이터 소스 및 템플릿 설정
- **멀티 프로젝트 지원**: 여러 프로젝트의 작업을 통합/개별 보고서로 생성

## 데이터 소스

- **Git**: 커밋 로그, 변경 통계 (기본 활성화)
- **Claude**: 현재 세션 대화 내용 분석 (기본 활성화)
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

## 보고서 구성

생성되는 보고서에는 다음 섹션이 포함됩니다:

1. **요약**: 작업 내용 한 줄 요약
2. **완료한 작업**: 완료된 작업 목록
3. **진행 중인 작업**: 현재 진행 중인 작업
4. **다음 계획**: 예정된 작업
5. **코드 변경 통계**: 추가/삭제된 라인 수, 변경된 파일 수
6. **커밋 리스트**: 기간 내 커밋 목록
7. **회고**: 배운 점, 개선할 점

## 라이선스

MIT

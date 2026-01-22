# My Claude Plugin Marketplace

Claude Code 플러그인들을 모아둔 개인 마켓플레이스/실습 저장소입니다.
다양한 생산성 도구와 유틸리티 에이전트들을 포함하고 있습니다.

## 📦 플러그인 목록

현재 포함된 플러그인은 다음과 같습니다:

### 1. 📊 Work Report (`work-report`)
작업 내용을 자동으로 수집하여 일일/주간/월간 보고서를 생성해주는 플러그인입니다.
- **주요 기능**: Git 커밋 로그 및 대화 내용 분석, 자동 보고서 생성
- **명령어**: `/work-report:daily`, `/work-report:weekly`, `/work-report:configure`
- **상세 정보**: [work-report/README.md](./work-report/README.md)

### 2. 👋 Greeter (`greeter-plugin`)
사용자에게 인사를 건네는 기본 예제 플러그인입니다.
- **주요 기능**: 플러그인 구조 이해 및 테스트용
- **명령어**: `/greet`
- **상세 정보**: [greeter-plugin/README.md](./greeter-plugin/README.md)

## 🚀 설치 및 사용 방법

이 저장소의 플러그인을 Claude Code에서 사용하려면 다음 두 가지 방법 중 하나를 선택하세요.

### 방법 1: 전역 설치 (추천)
플러그인 폴더를 Claude의 전역 플러그인 디렉토리로 복사합니다.

```bash
# work-report 플러그인 설치 예시
cp -r work-report ~/.claude/plugins/
```

### 방법 2: 프로젝트별 설치
특정 프로젝트에서만 사용하려면 해당 프로젝트의 `.claude-plugin/` 폴더에 복사합니다.

```bash
mkdir -p my-project/.claude-plugin
cp -r work-report my-project/.claude-plugin/
```

## 🛠️ 플러그인 개발

새로운 플러그인을 추가하려면 다음 구조를 따르세요:

```text
new-plugin/
├── .claude-plugin/
│   └── plugin.json    # 플러그인 메타데이터
├── commands/          # 명령어 정의 (.md)
├── agents/            # 에이전트 프롬프트 (.md)
├── tools/             # (선택) 실행 스크립트 등
└── README.md          # 문서
```

## 📥 마켓플레이스에 플러그인 등록하기

플러그인 개발이 완료되면 `.claude-plugin/marketplace.json` 파일에 등록하여 관리할 수 있습니다.

### 1. 로컬 플러그인 등록
루트 디렉토리에 있는 플러그인을 등록할 때는 상대 경로를 사용합니다.

```json
{
  "name": "new-plugin-name",
  "description": "플러그인 설명",
  "version": "1.0.0",
  "source": "./new-plugin-directory"
}
```

### 2. GitHub 리포지토리 등록
외부 GitHub 리포지토리에 있는 플러그인을 등록할 때는 Git URL을 사용합니다.

```json
{
  "name": "remote-plugin",
  "description": "GitHub 호스팅 플러그인",
  "version": "1.0.0",
  "source": "https://github.com/username/repository-name.git"
}
```

3. **변경사항 저장**: `marketplace.json`을 저장하고 커밋합니다.

---
*Created for Claude Plugin Practice*

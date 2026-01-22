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

## 📥 마켓플레이스에 플러그인 등록하기

외부 GitHub 리포지토리에 있는 플러그인을 등록할 때는 Git URL을 사용합니다.

```bash
/plugin marketplace add https://github.com/ajsirh12/claude-plugin-test
```

3. **변경사항 저장**: `marketplace.json`을 저장하고 커밋합니다.

---
*Created for Claude Plugin Practice*

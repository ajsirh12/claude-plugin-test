---
name: Report Writing Best Practices
description: |
  This skill should be used when the user asks about "writing reports", "report format",
  "work report template", "보고서 작성", "업무 보고서 양식", "보고서 템플릿",
  or needs guidance on creating effective work reports, structuring reports,
  or improving report quality.
version: 1.0.0
---

# Report Writing Best Practices

Effective work report writing guidelines for creating clear, professional, and actionable reports.

## Report Structure

### Daily Report Template

```markdown
# 일일 업무 보고서

**날짜**: YYYY-MM-DD
**작성자**: [이름]

## 요약
[오늘 작업의 핵심을 1-2문장으로]

## 완료한 작업
- [작업 1]: [간단한 설명]
- [작업 2]: [간단한 설명]

## 진행 중인 작업
- [작업]: 진행률 N%

## 다음 계획
- [예정 작업]

## 블로커/이슈
- [있다면 기재]

## 회고
- 배운 점: ...
- 개선할 점: ...
```

### Weekly Report Template

```markdown
# 주간 업무 보고서

**기간**: MM/DD - MM/DD
**작성자**: [이름]

## Executive Summary
[주간 성과 요약]

## 주요 성과
1. [성과 1]
2. [성과 2]

## 상세 활동
### 월요일
- [활동]
### 화요일
...

## 다음 주 계획
- [계획]

## 이슈 및 리스크
- [이슈]: [대응 방안]
```

## Writing Principles

### 1. Be Specific
- Bad: "작업 진행함"
- Good: "사용자 인증 API 구현 완료 (JWT 기반)"

### 2. Use Metrics
Include quantifiable data:
- 커밋 수, 변경된 라인 수
- 완료율, 진행률
- 소요 시간

### 3. Action-Oriented
Focus on outcomes, not activities:
- Bad: "회의 참석"
- Good: "기술 검토 회의에서 Redis 캐싱 도입 결정"

### 4. Include Context
Provide enough context for readers:
- Why was this task needed?
- What problem does it solve?
- What impact does it have?

### 5. Highlight Blockers
Always surface issues early:
- What is blocking progress?
- What help is needed?
- What risks exist?

## Git Data Integration

### Extracting Useful Information

```bash
# Today's commits with details
git log --since="midnight" --format="%h %s" --author="$(git config user.email)"

# Changed files
git diff --stat HEAD~1

# Lines added/removed
git log --numstat --since="midnight" --format="" | awk '{add+=$1; del+=$2} END {print "+"add"/-"del}'
```

### Commit Message Quality
Good commits make better reports:
- `feat: Add user authentication with JWT`
- `fix: Resolve memory leak in cache service`
- `refactor: Simplify database connection handling`

## Language Guidelines

### Korean Reports
- 경어체 사용 (습니다/합니다)
- 기술 용어는 영어 그대로 사용 가능
- 간결한 문장 지향

### English Reports
- Use active voice
- Be concise
- Use bullet points for lists

## Report Review Checklist

Before finalizing:
- [ ] All sections complete
- [ ] Statistics are accurate
- [ ] Tasks are clearly described
- [ ] Next steps are defined
- [ ] Blockers are highlighted
- [ ] Typos checked
- [ ] Formatting consistent

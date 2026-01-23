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

### Report Template

```markdown
# [보고서 종류] 업무 보고서 (YYYY-MM-DD)

**기간**: YYYY-MM-DD ~ YYYY-MM-DD  
**작성자**: [이름/이메일]  
**작성일**: YYYY-MM-DD  

---

## 📝 1. 핵심 요약 (Summary)
*프로젝트 또는 주요 업무 영역별로 이번 기간의 핵심 성과를 요약합니다.*

| 프로젝트/영역 | 주요 성과 및 하이라이트 | 비고 |
| :--- | :--- | :--- |
| **[프로젝트 A]** | 해당 프로젝트의 핵심 성과 요약 | |
| **[프로젝트 B]** | 해당 프로젝트의 핵심 성과 요약 | |
| **[공통/기타]** | 인프라, 환경 설정, 공통 모듈 등 기타 성과 | |

---

## 📅 2. 날짜별 작업 요약 (Daily Summary)
*개발 기간 내 일자별 핵심 작업 내역입니다.*

* **MM/DD (요일)**: 작업 내용 1, 작업 내용 2
* **MM/DD (요일)**: 작업 내용 1, 작업 내용 2

---

## 🚀 3. 주요 작업 상세 (Detailed Achievements)
*요약된 내용 중 정성적으로 가치가 높은 항목을 상세히 기술합니다.*

### 3.1 [프로젝트/영역 명칭]
* **핵심 작업 1**: 구현 내용 및 비즈니스 가치/해결된 문제
* **핵심 작업 2**: 구체적인 기술적 성과

### 3.2 [프로젝트/영역 명칭]
* **핵심 작업 1**: 구현 내용 및 비즈니스 가치/해결된 문제
* **핵심 작업 2**: 구체적인 기술적 성과

---

## 📊 4. 개발 생산성 지표 (Development Stats)
*수치화된 데이터를 통해 프로젝트의 활동성을 확인합니다.*

| 프로젝트 | 커밋 수 | 파일 변경 | 추가 라인 | 삭제 라인 |
| :--- | :---: | :---: | :---: | :---: |
| **Project A** | 00개 | 00개 | +0,000 | -000 |
| **Project B** | 00개 | 00개 | +0,000 | -000 |
| **합계** | **000개** | **000개** | **+00,000** | **-0,000** |

---

## 🧠 5. 회고 및 특이사항 (Retrospective)

* **👍 Good**: 프로젝트 진행 중 긍정적인 부분 및 성과
* **🧐 Bad/Action**: 개선이 필요한 지점 및 구체적인 액션 아이템
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

## Additional Resources

### Related Skills
- **`data-source-patterns/SKILL.md`** - Detailed guide on extracting data from Git, Jira, Slack, etc.
- **`automation-setup/SKILL.md`** - Guide on automating report generation.

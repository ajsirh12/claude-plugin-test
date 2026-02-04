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

**중요**: 이 템플릿을 정확히 따를 것. 커밋 내역 테이블, 다음 주 계획 섹션은 포함하지 않음.

```markdown
# [보고서 종류] 업무 보고서 (YYYY-MM-DD)

**기간**: YYYY-MM-DD ~ YYYY-MM-DD
**작성자**: [이름/이메일]
**작성일**: YYYY-MM-DD

---

## 📊 1. 개발 생산성 지표 (Development Stats)
*수치화된 데이터를 통해 프로젝트의 활동성을 확인합니다.*

| 프로젝트 | 커밋 수 | 파일 변경 | 추가 라인 | 삭제 라인 |
| :--- | :---: | :---: | :---: | :---: |
| **Project A** | 00개 | 00개 | +0,000 | -000 |
| **Project B** | 00개 | 00개 | +0,000 | -000 |
| **합계** | **000개** | **000개** | **+00,000** | **-0,000** |

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

## 💬 4. Slack 논의 요약 (Slack이 설정된 경우만)
*팀 커뮤니케이션에서 핵심 논의와 결정사항을 정리합니다.*

### #채널명 (메시지 수, 스레드 수)

**📌 주요 논의:**
1. **주제명**
   - 세부 내용
   - 참여자: 이름들

**✅ 결정사항:**
- 합의된 내용

**📢 공지사항:**
- 중요 안내

**📝 Action Items:**
- [ ] 담당자: 할 일

---

## 🧠 5. 회고 및 특이사항 (Retrospective)

* **👍 Good**: 프로젝트 진행 중 긍정적인 부분 및 성과
* **🧐 Bad/Action**: 개선이 필요한 지점 및 구체적인 액션 아이템

---

## 📝 6. 핵심 요약 (Summary)
*프로젝트 또는 주요 업무 영역별로 이번 기간의 핵심 성과를 요약합니다.*

| 프로젝트/영역 | 주요 성과 및 하이라이트 | 비고 |
| :--- | :--- | :--- |
| **[프로젝트 A]** | 해당 프로젝트의 핵심 성과 요약 | |
| **[프로젝트 B]** | 해당 프로젝트의 핵심 성과 요약 | |
| **[공통/기타]** | 인프라, 환경 설정, 공통 모듈 등 기타 성과 | |
```

### 제외 항목

다음 섹션은 보고서에 **포함하지 않음**:
- 개별 커밋 내역 테이블 (해시, 메시지, 날짜)
- 다음 주/월 계획 섹션

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

## Enhanced Report Format (v2.0)

### New Features

The enhanced report format includes:

1. **📊 Dashboard Section**
   - KPI cards with week-over-week comparison
   - Activity trend sparklines (▁▂▃▅▆▇█)
   - Time-based activity heatmap (🟥🟧🟨🟩⬜)

2. **📈 Visual Elements**
   - Progress bars using Unicode blocks (████████░░)
   - Trend indicators (📈 📉 ➡️)
   - Distribution charts
   - Status indicators (🟢 🟡 🔴)

3. **🔍 Code Insights**
   - Top 10 hotspot files analysis
   - File type distribution
   - Commit quality scoring
   - Work pattern analysis

4. **📊 Comparative Analysis**
   - Period-over-period comparison tables
   - Goal tracking with achievement rates
   - Trend visualization

5. **🧠 Intelligent Analysis**
   - Automatic pattern detection
   - Productivity metrics
   - Risk identification
   - Actionable recommendations

### Templates

Two report templates are available:

#### Standard Template (Original)
- Traditional text-based format
- Tables and bullet points
- Suitable for simple reports
- Located in main SKILL.md

#### Enhanced Template (v2.0)
- Visual-rich format with charts
- Insights and analytics
- Comparison features
- Located at `templates/enhanced-report-template.md`

### Helper Scripts

Use these scripts to generate report components:

#### Period Comparison
```bash
# Bash
./scripts/compare-periods.sh "1 week ago" "now" "2 weeks ago" "1 week ago"

# PowerShell
.\scripts\compare-periods.ps1 -CurrentSince "1 week ago" -CurrentUntil "now"
```

**Output**: Week-over-week comparison table with trends

#### Hotspot Analysis
```bash
# Bash
./scripts/analyze-hotspots.sh "1 week ago"

# PowerShell
.\scripts\analyze-hotspots.ps1 -Since "1 week ago"
```

**Output**: Top 10 frequently changed files with risk levels

#### Pattern Analysis
```bash
# Bash
./scripts/analyze-patterns.sh "1 week ago"

# PowerShell
.\scripts\analyze-patterns.ps1 -Since "1 week ago"
```

**Output**: Time-of-day and day-of-week activity patterns

### Configuration

Enable enhanced reporting in `.claude/work-report.local.md`:

```yaml
# Report format selection
report_format: enhanced  # or "standard"

# Visual elements
enable_visualizations: true
enable_insights: true
enable_comparisons: true

# Goal tracking (optional)
weekly_goals:
  commits: 40
  test_coverage: 75
  bugs_fixed: 5
  docs_pages: 10
```

### Visual Element Examples

#### Progress Bars
```
████████░░ 80%  # High completion
█████░░░░░ 50%  # Half complete
███░░░░░░░ 30%  # Low completion
```

#### Sparklines
```
커밋 활동:  ▂▃▅▆▇█▇▅  # Weekly trend
코드 변경:  ▁▃▄▆▇▇▅▃  # Code churn
```

#### Heatmaps
```
      00-06  06-12  12-18  18-24
월    ⬜⬜⬜  ⬜⬜⬜  🟨🟨🟨  🟩🟩🟩
화    ⬜⬜⬜  ⬜⬜⬜  🟧🟧🟧  🟨🟨🟨
```

#### Status Indicators
- 🟢 정상 - Normal, healthy state
- 🟡 주의 - Warning, needs attention
- 🔴 핫스팟 - Critical, requires action
- ✅ 완료 - Completed
- ⚠️ 진행중 - In progress
- 🔴 블로커 - Blocked

### Insights Generation

The enhanced format automatically generates insights:

**File Hotspots**:
- Files changed ≥8 times: 🔴 High risk, consider refactoring
- Files changed 5-7 times: 🟡 Moderate risk, monitor
- Files changed <5 times: 🟢 Normal activity

**Commit Quality**:
- Average 20-50 lines: ✅ Optimal size
- Average <20 lines: ⚠️ Too small, consider consolidation
- Average >50 lines: ⚠️ Too large, consider splitting

**Work Patterns**:
- Identifies peak productivity hours
- Highlights most productive days
- Detects unusual activity patterns

**Trends**:
- 📈 Positive trend (>5% increase)
- 📉 Negative trend (>5% decrease)
- ➡️ Stable trend (±5% change)

### Best Practices for Enhanced Reports

1. **Use Visualizations Wisely**
   - Progress bars for percentages and completion rates
   - Sparklines for multi-day trends
   - Heatmaps for time-based patterns
   - Tables for detailed comparisons

2. **Highlight Key Insights**
   - Place important findings in dashboard
   - Use status indicators for quick scanning
   - Include actionable recommendations

3. **Provide Context**
   - Always compare to previous periods
   - Show trends, not just snapshots
   - Explain why metrics matter

4. **Keep It Readable**
   - Don't overuse emojis
   - Maintain clear section hierarchy
   - Balance visuals with text

5. **Focus on Action**
   - Identify blockers and risks
   - Suggest next steps
   - Track goal progress

### Migration from Standard to Enhanced

To upgrade existing reports:

1. Update configuration:
   ```yaml
   report_format: enhanced
   ```

2. Enable new features:
   ```yaml
   enable_visualizations: true
   enable_insights: true
   enable_comparisons: true
   ```

3. Set baseline goals (optional):
   ```yaml
   weekly_goals:
     commits: <your_target>
     test_coverage: <your_target>
   ```

4. Run report generation - enhanced template will be used automatically

### Customization

Customize the enhanced template:

1. Copy `templates/enhanced-report-template.md`
2. Modify sections as needed
3. Update configuration to point to custom template:
   ```yaml
   custom_template: path/to/your-template.md
   ```

## Additional Resources

### Templates
- **`templates/enhanced-report-template.md`** - Visual-rich report template with insights

### Helper Scripts
- **`scripts/compare-periods.sh|.ps1`** - Period-over-period comparison
- **`scripts/analyze-hotspots.sh|.ps1`** - File hotspot detection
- **`scripts/analyze-patterns.sh|.ps1`** - Work pattern analysis

### Related Skills
- **`data-source-patterns/SKILL.md`** - Detailed guide on extracting data from Git, Jira, Slack, etc.
- **`automation-setup/SKILL.md`** - Guide on automating report generation.

---
name: Data Source Patterns
description: |
  This skill should be used when the user asks about "git data collection", "jira integration",
  "slack data", "claude session data", "데이터 수집", "Git 커밋 가져오기", "Jira 연동",
  "데이터 소스 설정", or needs guidance on collecting data from various sources for work reports.
version: 1.0.0
---

# Data Source Patterns

Guide for collecting work data from various sources: Git, Claude sessions, Jira, and Slack.

## Supported Data Sources

| Source | Type | Requirements | Data Collected |
|--------|------|--------------|----------------|
| Git | Built-in | Git repository | Commits, diffs, stats |
| Claude | Built-in | Session logging enabled | Work summaries, decisions |
| Notion | MCP | Notion MCP server | Pages, databases, tasks, notes |
| Jira | MCP | Jira MCP server | Issues, worklogs, sprints |
| Slack | MCP | Slack MCP server | Messages, threads |

## Git Data Collection

### Basic Configuration

```yaml
# .claude/work-report.local.md
git_author: user@example.com
git_branches: all  # or "main" or "current"
```

### Useful Git Commands

```bash
# Today's commits
git log --since="midnight" --format="%h %s" --author="$(git config user.email)"

# This week's commits
git log --since="1 week ago" --format="%h %s (%ad)" --date=short

# Commit statistics
git log --numstat --since="midnight" --format="" | \
  awk '{add+=$1; del+=$2} END {print "+"add"/-"del}'

# Changed files count
git diff --stat HEAD~10 | tail -1
```

### Multi-Repository Collection

```yaml
projects:
  - name: "frontend"
    type: "git"
    path: "C:/workspace/frontend-app"

  - name: "backend"
    type: "git"
    path: "C:/workspace/backend-api"
    git_author: "backend@team.com"  # Override
    git_branches: "main,develop"
```

## Claude Session Data

### Option 1: Session Logging (Recommended)

Enable automatic session logging:

```yaml
enable_session_logging: true
session_log_dir: .claude/sessions
```

Configure as a project source:

```yaml
projects:
  - name: "AI-Work"
    type: "claude"
    path: ".claude/sessions"
    session_limit: 10
    file_pattern: "session-*.md"
```

### Option 2: Scope-Based Collection

```yaml
projects:
  - name: "Current-Session"
    type: "claude"
    scope: "current"  # Only current session

  - name: "Recent-Sessions"
    type: "claude"
    scope: "recent"
    session_limit: 5

  - name: "Project-Filtered"
    type: "claude"
    scope: "project"
    keywords: ["plugin", "work-report"]
```

### Session Log Format

Session logs are saved in this format:

```markdown
# Session Summary - 2024-01-15 14:30

## Work Type
Feature Development

## Changed Files
- src/components/Button.tsx (modified)
- src/utils/helpers.ts (created)

## Key Decisions
- Chose React Query over SWR for data fetching
- Implemented optimistic updates for better UX

## Commands Executed
- npm install react-query
- npm run test
```

## Notion Integration

### Prerequisites

1. Notion MCP server configured in `.mcp.json` (자동 포함됨)
2. Notion API Integration Token

### Authentication Setup

1. **Notion Integration 생성**:
   - Notion 설정 → [Integrations](https://www.notion.so/my-integrations)
   - "New Integration" 클릭
   - Integration 이름 입력 (예: "Work Report")
   - Internal Integration Token 복사

2. **환경변수 설정**:
   ```bash
   # Windows (PowerShell)
   $env:NOTION_API_TOKEN = "secret_xxx..."

   # Windows (CMD)
   setx NOTION_API_TOKEN "secret_xxx..."

   # Linux/macOS
   export NOTION_API_TOKEN="secret_xxx..."
   ```

3. **데이터베이스 연결**:
   - 사용할 Notion 페이지/데이터베이스 열기
   - 우측 상단 "..." → "Add connections"
   - 생성한 Integration 선택

### Configuration

```yaml
data_sources:
  - notion

projects:
  - name: "Tasks"
    type: "notion"
    database_id: "abc123def456"  # Tasks 데이터베이스 ID
    filters:
      assignee: "me"
      status: ["In Progress", "Done"]
      date_property: "Updated"
      date_range: "this_week"
```

### Database ID 찾기

Notion URL에서 Database ID 확인:
```
https://notion.so/workspace/[DATABASE_ID]?v=...
                            ^^^^^^^^^^^^^^^^
```

또는 데이터베이스 공유 링크에서:
```
https://notion.so/[DATABASE_ID]
```

### Available Filters

```yaml
# 상태 기반 필터
filters:
  status: ["Done", "In Progress"]

# 담당자 필터
filters:
  assignee: "me"  # 또는 특정 이메일

# 날짜 범위
filters:
  date_property: "Updated"
  date_range: "this_week"  # today, this_week, this_month

# 우선순위
filters:
  priority: ["High", "Medium"]

# 태그/카테고리
filters:
  tags: ["frontend", "backend"]
```

### Data Collected from Notion

**Tasks Database**:
- Task title and description
- Status (Not Started, In Progress, Done)
- Assignee
- Due date
- Priority
- Tags/Categories
- Created/Updated time

**Projects Database**:
- Project name
- Status and progress
- Team members
- Start/End dates
- Milestones

**Pages (Daily Notes, Meeting Notes)**:
- Page title and content
- Creation/Update time
- Comments
- Sub-pages

For detailed Notion patterns, see `references/notion-patterns.md`.

## Jira Integration

### Prerequisites

1. Jira MCP server configured in `.mcp.json`
2. Valid Jira API credentials

### Configuration

```yaml
data_sources:
  - jira

projects:
  - name: "Sprint-Work"
    type: "jira"
    project_key: "DEV"
    jql_filter: "assignee = currentUser() AND sprint in openSprints()"
    include_subtasks: true
```

### Available JQL Filters

```
# My issues updated today
assignee = currentUser() AND updated >= startOfDay()

# My completed issues this week
assignee = currentUser() AND status = Done AND resolved >= startOfWeek()

# Current sprint issues
sprint in openSprints() AND assignee = currentUser()
```

### Data Collected from Jira

- Issue key, summary, status
- Time logged (worklog)
- Status transitions
- Comments added

For detailed Jira patterns, see `references/jira-patterns.md`.

## Slack Integration

### Prerequisites

1. Slack MCP server configured
2. Appropriate channel access

### Configuration

```yaml
data_sources:
  - slack

projects:
  - name: "Team-Discussions"
    type: "slack"
    channel: "dev-team"
    include_threads: true
```

### Data Collected from Slack

- Messages in specified channels
- Thread replies
- Mentions and reactions

For detailed Slack patterns, see `references/slack-patterns.md`.

## Combining Multiple Sources

### Combined Report Mode

All sources merged into single report:

```yaml
report_mode: combined
data_sources:
  - git
  - claude
  - jira
projects:
  - name: "frontend"
    type: "git"
    path: "/workspace/frontend"
  - name: "sprint"
    type: "jira"
    project_key: "FE"
```

### Separate Report Mode

Individual report per source:

```yaml
report_mode: separate
# Creates: report-daily-frontend-2024-01-15.md
#          report-daily-sprint-2024-01-15.md
```

## Validation Scripts

### Check Git Repository

```bash
# scripts/validate-git.sh
#!/bin/bash
path="$1"
if [ -d "$path/.git" ]; then
  echo "✓ Valid Git repository"
  cd "$path" && git log --oneline -1
else
  echo "✗ Not a Git repository"
  exit 1
fi
```

### Check MCP Connection

```bash
# Check if Jira MCP is available
claude mcp list | grep -i jira
```

## Troubleshooting

### No Git Data

1. Check `git_author` matches your commits
2. Verify date range includes commits
3. Check branch filter settings

### No Claude Session Data

1. Enable `enable_session_logging: true`
2. Check `session_log_dir` path exists
3. Verify session files are being created

### MCP Source Not Working

1. Verify MCP server is configured in `.mcp.json`
2. Check authentication credentials
3. Test MCP connection manually

## Additional Resources

### Reference Files

- **`references/jira-patterns.md`** - Advanced Jira JQL patterns
- **`references/slack-patterns.md`** - Slack channel filtering

### Scripts

- **`scripts/validate-git.sh`** - Validate Git repository
- **`scripts/check-sources.sh`** - Check all configured sources

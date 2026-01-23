# Jira Data Collection Patterns

Advanced JQL queries and data extraction patterns for Jira integration.

## JQL Query Examples

### Time-Based Filters

```jql
# Issues updated today
assignee = currentUser() AND updated >= startOfDay()

# Issues updated this week
assignee = currentUser() AND updated >= startOfWeek()

# Issues resolved this month
assignee = currentUser() AND resolved >= startOfMonth()

# Issues updated in last 7 days
assignee = currentUser() AND updated >= -7d
```

### Status-Based Filters

```jql
# Completed issues
assignee = currentUser() AND status = Done AND resolved >= startOfWeek()

# In progress issues
assignee = currentUser() AND status = "In Progress"

# Issues with status change today
assignee = currentUser() AND status changed DURING (startOfDay(), now())
```

### Sprint Filters

```jql
# Current sprint issues
sprint in openSprints() AND assignee = currentUser()

# Issues completed in current sprint
sprint in openSprints() AND assignee = currentUser() AND status = Done

# Issues carried over from previous sprint
sprint in openSprints() AND sprint in closedSprints() AND assignee = currentUser()
```

### Project-Specific Filters

```jql
# Specific project, my issues
project = "PROJ" AND assignee = currentUser()

# Multiple projects
project in ("PROJ-A", "PROJ-B") AND assignee = currentUser()

# Exclude certain issue types
assignee = currentUser() AND issuetype not in (Epic, "Sub-task")
```

### Worklog Filters

```jql
# Issues with worklog entries today
worklogDate = startOfDay() AND worklogAuthor = currentUser()

# Issues with worklog this week
worklogDate >= startOfWeek() AND worklogAuthor = currentUser()
```

## Configuration Examples

### Basic Jira Project

```yaml
projects:
  - name: "sprint-work"
    type: "jira"
    project_key: "DEV"
```

### Filtered Jira Data

```yaml
projects:
  - name: "completed-work"
    type: "jira"
    project_key: "DEV"
    jql_filter: "status = Done AND resolved >= startOfWeek()"
    include_subtasks: false
```

### Multiple Jira Projects

```yaml
projects:
  - name: "frontend-sprint"
    type: "jira"
    project_key: "FE"
    jql_filter: "sprint in openSprints()"

  - name: "backend-sprint"
    type: "jira"
    project_key: "BE"
    jql_filter: "sprint in openSprints()"
```

## Data Fields Collected

| Field | Description | Example |
|-------|-------------|---------|
| key | Issue identifier | DEV-1234 |
| summary | Issue title | "Add login feature" |
| status | Current status | "In Progress" |
| issuetype | Type of issue | "Story", "Bug" |
| created | Creation date | 2024-01-15 |
| updated | Last update | 2024-01-20 |
| resolved | Resolution date | 2024-01-20 |
| timeSpent | Time logged | "2h 30m" |

## Report Output Format

Jira data appears in reports as:

```markdown
## Jira Issues

### Completed (3)
- **DEV-1234**: Add user authentication [2h logged]
- **DEV-1235**: Fix login redirect bug [1h logged]
- **DEV-1236**: Update password validation [30m logged]

### In Progress (2)
- **DEV-1240**: Implement OAuth integration
- **DEV-1241**: Add password reset flow

### Total Time Logged: 3h 30m
```

## Troubleshooting

### "No issues found"

1. Check JQL syntax
2. Verify project key exists
3. Confirm assignee filter matches your user

### "MCP connection failed"

1. Check Jira MCP server configuration
2. Verify API credentials
3. Test connection: `claude mcp list`

### "Permission denied"

1. Check Jira project access
2. Verify API token permissions
3. Contact Jira administrator

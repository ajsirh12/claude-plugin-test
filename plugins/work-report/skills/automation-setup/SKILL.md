---
name: Report Automation Setup
description: |
  This skill should be used when the user asks about "automated reports", "schedule reports",
  "cron setup", "task scheduler", "자동 보고서", "스케줄러 설정", "자동화",
  "CI/CD integration", or needs guidance on automating work report generation.
version: 1.0.0
---

# Report Automation Setup

Guide for automating work report generation using system schedulers and CI/CD pipelines.

## Automation Overview

| Method | Platform | Use Case |
|--------|----------|----------|
| cron | Linux/macOS | Daily/weekly scheduled reports |
| Task Scheduler | Windows | Same as cron for Windows |
| CI/CD | Any | Repository-triggered reports |
| GitHub Actions | GitHub | PR/merge triggered reports |

## Security Considerations

Automation scripts use `--dangerously-skip-permissions` flag to enable unattended execution. This bypasses Claude Code's permission prompts.

**Safety measures:**
- Scripts only perform read operations (Git log) and file writes
- Run in isolated, trusted environments
- Avoid running with elevated privileges
- Review scripts before deployment

## Linux/macOS (cron)

### Basic Setup

```bash
# Open crontab editor
crontab -e

# Add scheduled tasks
# Format: minute hour day month weekday command
```

### Common Schedules

```bash
# Daily report at 6 PM
0 18 * * * /path/to/work-report/scripts/auto-report.sh daily /path/to/project

# Weekly report every Friday at 6 PM
0 18 * * 5 /path/to/work-report/scripts/auto-report.sh weekly /path/to/project

# Monthly report on 1st of each month at 9 AM
0 9 1 * * /path/to/work-report/scripts/auto-report.sh monthly /path/to/project
```

### Auto-Report Script (Linux/macOS)

```bash
#!/bin/bash
# scripts/auto-report.sh

REPORT_TYPE="${1:-daily}"
PROJECT_PATH="${2:-$(pwd)}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/tmp/work-report-${TIMESTAMP}.log"

cd "$PROJECT_PATH" || exit 1

echo "Generating $REPORT_TYPE report at $(date)" >> "$LOG_FILE"

claude --dangerously-skip-permissions \
  -p "Generate a $REPORT_TYPE work report and save it" \
  >> "$LOG_FILE" 2>&1

echo "Report generation completed at $(date)" >> "$LOG_FILE"
```

### Make Script Executable

```bash
chmod +x /path/to/work-report/scripts/auto-report.sh
```

## Windows (Task Scheduler)

### PowerShell Script

```powershell
# scripts/auto-report.ps1

param(
    [string]$ReportType = "daily",
    [string]$ProjectPath = (Get-Location)
)

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = "$env:TEMP\work-report-$Timestamp.log"

Set-Location $ProjectPath

"Generating $ReportType report at $(Get-Date)" | Out-File $LogFile -Append

claude --dangerously-skip-permissions `
  -p "Generate a $ReportType work report and save it" `
  2>&1 | Out-File $LogFile -Append

"Report generation completed at $(Get-Date)" | Out-File $LogFile -Append
```

### Create Scheduled Task

```powershell
# Daily report at 6 PM
$action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument "-File C:\path\to\auto-report.ps1 daily C:\path\to\project"

$trigger = New-ScheduledTaskTrigger -Daily -At 6PM

Register-ScheduledTask `
  -TaskName "DailyWorkReport" `
  -Action $action `
  -Trigger $trigger `
  -Description "Generate daily work report"
```

### Using schtasks

```cmd
:: Daily report
schtasks /create /tn "DailyWorkReport" ^
  /tr "powershell -File C:\path\to\auto-report.ps1 daily C:\path\to\project" ^
  /sc daily /st 18:00

:: Weekly report (Fridays)
schtasks /create /tn "WeeklyWorkReport" ^
  /tr "powershell -File C:\path\to\auto-report.ps1 weekly C:\path\to\project" ^
  /sc weekly /d FRI /st 18:00
```

## GitHub Actions

### Daily Report Workflow

```yaml
# .github/workflows/daily-report.yml
name: Daily Work Report

on:
  schedule:
    - cron: '0 9 * * 1-5'  # 9 AM UTC, Mon-Fri
  workflow_dispatch:  # Manual trigger

jobs:
  generate-report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for git log

      - name: Setup Claude Code
        run: |
          npm install -g @anthropic/claude-code

      - name: Generate Report
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude --dangerously-skip-permissions \
            -p "Generate a daily work report for commits since yesterday"

      - name: Commit Report
        run: |
          git config user.name "github-actions"
          git config user.email "actions@github.com"
          git add reports/
          git commit -m "chore: add daily report $(date +%Y-%m-%d)" || true
          git push
```

### Weekly Report on PR Merge

```yaml
# .github/workflows/weekly-report.yml
name: Weekly Report

on:
  schedule:
    - cron: '0 17 * * 5'  # Friday 5 PM UTC

jobs:
  weekly-report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate Weekly Report
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          npx @anthropic/claude-code --dangerously-skip-permissions \
            -p "Generate a weekly work report"

      - name: Create PR with Report
        uses: peter-evans/create-pull-request@v5
        with:
          title: "Weekly Report - Week $(date +%V)"
          body: "Automated weekly work report"
          branch: weekly-report-$(date +%Y%W)
```

## GitLab CI/CD

```yaml
# .gitlab-ci.yml
daily-report:
  stage: report
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  script:
    - npm install -g @anthropic/claude-code
    - claude --dangerously-skip-permissions -p "Generate daily report"
  artifacts:
    paths:
      - reports/
```

## Multi-Project Automation

### Batch Script for Multiple Projects

```bash
#!/bin/bash
# scripts/multi-project-report.sh

PROJECTS=(
  "/workspace/project-a"
  "/workspace/project-b"
  "/workspace/project-c"
)

REPORT_TYPE="${1:-daily}"

for project in "${PROJECTS[@]}"; do
  echo "Processing: $project"
  cd "$project"
  claude --dangerously-skip-permissions \
    -p "Generate a $REPORT_TYPE report"
done

echo "All reports generated"
```

## Notification Integration

### Slack Notification After Report

```bash
#!/bin/bash
# After report generation
WEBHOOK_URL="https://hooks.slack.com/services/xxx"
REPORT_FILE=$(ls -t reports/*.md | head -1)

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "{\"text\": \"Daily report generated: $REPORT_FILE\"}"
```

### Email Notification

```bash
# Using mail command
REPORT_FILE=$(ls -t reports/*.md | head -1)
mail -s "Daily Work Report" team@example.com < "$REPORT_FILE"
```

## Troubleshooting

### Cron Job Not Running

1. Check cron service: `systemctl status cron`
2. View cron logs: `grep CRON /var/log/syslog`
3. Verify script permissions: `ls -la scripts/`

### Task Scheduler Issues

1. Check task history in Task Scheduler
2. Verify PowerShell execution policy
3. Test script manually first

### Claude Code Errors

1. Check API key is set in environment
2. Verify `--dangerously-skip-permissions` flag
3. Review log files for errors

## Additional Resources

### Reference Files

- **`references/cron-examples.md`** - More cron schedule examples
- **`references/ci-templates.md`** - CI/CD template collection

### Scripts

- **`scripts/auto-report.sh`** - Linux/macOS automation
- **`scripts/auto-report.ps1`** - Windows automation
- **`scripts/multi-project-report.sh`** - Multi-project batch

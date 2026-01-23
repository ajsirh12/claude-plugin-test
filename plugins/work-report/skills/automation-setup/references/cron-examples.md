# Cron Schedule Examples

Comprehensive cron expression examples for report automation.

## Cron Format

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, 0=Sunday)
│ │ │ │ │
* * * * * command
```

## Daily Reports

```bash
# Every day at 6 PM
0 18 * * * /path/to/auto-report.sh daily

# Every day at 9 AM
0 9 * * * /path/to/auto-report.sh daily

# Every day at midnight
0 0 * * * /path/to/auto-report.sh daily

# Every weekday at 6 PM (Mon-Fri)
0 18 * * 1-5 /path/to/auto-report.sh daily

# Twice daily (9 AM and 6 PM)
0 9,18 * * * /path/to/auto-report.sh daily
```

## Weekly Reports

```bash
# Every Friday at 6 PM
0 18 * * 5 /path/to/auto-report.sh weekly

# Every Sunday at midnight
0 0 * * 0 /path/to/auto-report.sh weekly

# Every Monday at 9 AM
0 9 * * 1 /path/to/auto-report.sh weekly

# Last day of week (Saturday) at 6 PM
0 18 * * 6 /path/to/auto-report.sh weekly
```

## Monthly Reports

```bash
# First day of month at 9 AM
0 9 1 * * /path/to/auto-report.sh monthly

# Last day of month at 6 PM (using run-parts)
0 18 28-31 * * [ "$(date +\%d -d tomorrow)" = "01" ] && /path/to/auto-report.sh monthly

# 15th of each month at noon
0 12 15 * * /path/to/auto-report.sh monthly
```

## Sprint Reports (Bi-weekly)

```bash
# Every other Friday at 5 PM
0 17 * * 5 [ $(expr $(date +\%W) \% 2) -eq 0 ] && /path/to/auto-report.sh weekly
```

## Environment Setup

```bash
# Set environment variables in crontab
ANTHROPIC_API_KEY=sk-xxx
PATH=/usr/local/bin:/usr/bin:/bin

0 18 * * * /path/to/auto-report.sh daily
```

## Logging

```bash
# With logging
0 18 * * * /path/to/auto-report.sh daily >> /var/log/work-report.log 2>&1

# With timestamped log
0 18 * * * /path/to/auto-report.sh daily >> /var/log/work-report-$(date +\%Y\%m\%d).log 2>&1
```

## Email Output

```bash
# Email on error
MAILTO=user@example.com
0 18 * * * /path/to/auto-report.sh daily

# Suppress output, email manually
0 18 * * * /path/to/auto-report.sh daily > /dev/null 2>&1
```

## Common Issues

### Script Not Running

```bash
# Check cron service
systemctl status cron

# Check cron logs
grep CRON /var/log/syslog

# Edit crontab with full paths
which claude  # Find full path
```

### Permission Issues

```bash
# Make script executable
chmod +x /path/to/auto-report.sh

# Check script ownership
ls -la /path/to/auto-report.sh
```

### Environment Variables

```bash
# Cron has limited environment
# Set variables in script or crontab header
#!/bin/bash
export PATH=/usr/local/bin:$PATH
export ANTHROPIC_API_KEY="sk-xxx"
```

## Timezone Considerations

```bash
# Cron uses system timezone
# Check current timezone
timedatectl

# Set timezone in crontab (if supported)
CRON_TZ=Asia/Seoul
0 18 * * * /path/to/auto-report.sh daily
```

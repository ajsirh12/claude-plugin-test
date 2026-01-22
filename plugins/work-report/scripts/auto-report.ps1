# Work Report Auto-generation Script for Windows
# Usage: .\auto-report.ps1 [-ReportType daily|weekly|monthly] [-ProjectPath <path>]
#
# This script is designed to be run by Windows Task Scheduler
# to automatically generate work reports.
#
# Task Scheduler Setup:
#   1. Open Task Scheduler (taskschd.msc)
#   2. Create Basic Task
#   3. Set trigger (daily at 6 PM, weekly on Friday, etc.)
#   4. Action: Start a program
#   5. Program: powershell.exe
#   6. Arguments: -ExecutionPolicy Bypass -File "C:\path\to\auto-report.ps1" -ReportType daily -ProjectPath "C:\path\to\project"
#
# Or via command line:
#   schtasks /create /tn "DailyWorkReport" /tr "powershell.exe -ExecutionPolicy Bypass -File 'C:\path\to\auto-report.ps1' -ReportType daily -ProjectPath 'C:\path\to\project'" /sc daily /st 18:00

param(
    [ValidateSet("daily", "weekly", "monthly")]
    [string]$ReportType = "daily",

    [string]$ProjectPath = (Get-Location).Path
)

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Validate project path
if (-not (Test-Path $ProjectPath)) {
    Write-ColorOutput "Error: Project path '$ProjectPath' does not exist" "Red"
    exit 1
}

# Check if it's a git repository
if (-not (Test-Path (Join-Path $ProjectPath ".git"))) {
    Write-ColorOutput "Error: '$ProjectPath' is not a git repository" "Red"
    exit 1
}

Write-ColorOutput "Starting $ReportType report generation..." "Green"
Write-ColorOutput "Project: $ProjectPath" "White"

# Change to project directory
Set-Location $ProjectPath

# Check if Claude Code is installed
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-ColorOutput "Error: Claude Code CLI is not installed" "Red"
    Write-ColorOutput "Please install Claude Code: https://claude.ai/code" "Yellow"
    exit 1
}

# Generate the report using Claude Code
Write-ColorOutput "Invoking Claude Code..." "Yellow"

try {
    # Run Claude Code with the appropriate command
    & claude --dangerously-skip-permissions -p "/work-report:$ReportType"

    Write-ColorOutput "Report generation complete!" "Green"

    # Optional: Show the generated report location
    $reportDir = Join-Path $ProjectPath "reports"
    if (Test-Path $reportDir) {
        $latestReport = Get-ChildItem -Path $reportDir -Filter "report-$ReportType-*.md" |
                        Sort-Object LastWriteTime -Descending |
                        Select-Object -First 1

        if ($latestReport) {
            Write-ColorOutput "Report saved to: $($latestReport.FullName)" "Green"
        }
    }
}
catch {
    Write-ColorOutput "Error running Claude Code: $_" "Red"
    exit 1
}

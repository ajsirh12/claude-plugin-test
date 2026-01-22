#!/bin/bash

# Work Report Auto-generation Script
# Usage: ./auto-report.sh [daily|weekly|monthly] [project-path]
#
# This script is designed to be run by cron or other schedulers
# to automatically generate work reports.
#
# Cron Examples:
#   # Daily report at 6 PM every day
#   0 18 * * * /path/to/auto-report.sh daily /path/to/project
#
#   # Weekly report at 6 PM every Friday
#   0 18 * * 5 /path/to/auto-report.sh weekly /path/to/project
#
#   # Monthly report at 6 PM on the last day of month
#   0 18 28-31 * * [ "$(date -d tomorrow +\%d)" = "01" ] && /path/to/auto-report.sh monthly /path/to/project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
REPORT_TYPE="${1:-daily}"
PROJECT_PATH="${2:-$(pwd)}"

# Validate report type
if [[ ! "$REPORT_TYPE" =~ ^(daily|weekly|monthly)$ ]]; then
    echo -e "${RED}Error: Invalid report type '$REPORT_TYPE'${NC}"
    echo "Usage: $0 [daily|weekly|monthly] [project-path]"
    exit 1
fi

# Validate project path
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}Error: Project path '$PROJECT_PATH' does not exist${NC}"
    exit 1
fi

# Check if it's a git repository
if [[ ! -d "$PROJECT_PATH/.git" ]]; then
    echo -e "${RED}Error: '$PROJECT_PATH' is not a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}Starting $REPORT_TYPE report generation...${NC}"
echo "Project: $PROJECT_PATH"

# Change to project directory
cd "$PROJECT_PATH"

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code CLI is not installed${NC}"
    echo "Please install Claude Code: https://claude.ai/code"
    exit 1
fi

# Generate the report using Claude Code
echo -e "${YELLOW}Invoking Claude Code...${NC}"

# Run Claude Code with the appropriate command
claude --dangerously-skip-permissions -p "/work-report:$REPORT_TYPE"

echo -e "${GREEN}Report generation complete!${NC}"

# Optional: Show the generated report location
REPORT_DIR="${PROJECT_PATH}/reports"
if [[ -d "$REPORT_DIR" ]]; then
    LATEST_REPORT=$(ls -t "$REPORT_DIR"/report-${REPORT_TYPE}-*.md 2>/dev/null | head -1)
    if [[ -n "$LATEST_REPORT" ]]; then
        echo -e "Report saved to: ${GREEN}$LATEST_REPORT${NC}"
    fi
fi

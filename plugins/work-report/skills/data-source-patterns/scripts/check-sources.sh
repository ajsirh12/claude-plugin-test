#!/bin/bash
# Check all configured data sources for work-report

set -e

CONFIG_FILE="${1:-.claude/work-report.local.md}"

echo "Work Report Data Source Checker"
echo "================================"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠ No config file found at: $CONFIG_FILE"
    echo "  Using default settings (current directory only)"
    echo ""

    # Check current directory as Git
    if [ -d ".git" ]; then
        echo "✓ Current directory is a Git repository"
        echo "  Author: $(git config user.email)"
        echo "  Branch: $(git branch --show-current)"
    else
        echo "✗ Current directory is not a Git repository"
    fi
    exit 0
fi

echo "Config file: $CONFIG_FILE"
echo ""

# Check Git repositories
echo "Git Repositories:"
echo "-----------------"

# Parse projects from config (simplified - real implementation would use proper YAML parser)
if grep -q "type: \"git\"" "$CONFIG_FILE" 2>/dev/null || grep -q "type: git" "$CONFIG_FILE" 2>/dev/null; then
    echo "Found Git project configurations"

    # Extract paths (simplified)
    grep -A1 "type:.*git" "$CONFIG_FILE" | grep "path:" | while read -r line; do
        path=$(echo "$line" | sed 's/.*path:[ ]*//' | tr -d '"')
        if [ -d "$path/.git" ]; then
            echo "  ✓ $path"
        else
            echo "  ✗ $path (invalid or not found)"
        fi
    done
else
    echo "  No Git projects configured"
fi

echo ""

# Check Claude session logging
echo "Claude Session Logging:"
echo "-----------------------"
if grep -q "enable_session_logging: true" "$CONFIG_FILE" 2>/dev/null; then
    session_dir=$(grep "session_log_dir:" "$CONFIG_FILE" | sed 's/.*session_log_dir:[ ]*//' | tr -d '"' || echo ".claude/sessions")
    session_dir="${session_dir:-.claude/sessions}"

    if [ -d "$session_dir" ]; then
        count=$(find "$session_dir" -name "session-*.md" 2>/dev/null | wc -l)
        echo "  ✓ Enabled (directory: $session_dir)"
        echo "    Session files: $count"
    else
        echo "  ⚠ Enabled but directory not found: $session_dir"
    fi
else
    echo "  ○ Disabled (set enable_session_logging: true to enable)"
fi

echo ""

# Check MCP sources
echo "MCP Data Sources:"
echo "-----------------"

# Check Jira
if grep -q "type:.*jira" "$CONFIG_FILE" 2>/dev/null; then
    if command -v claude &>/dev/null && claude mcp list 2>/dev/null | grep -qi jira; then
        echo "  ✓ Jira MCP configured"
    else
        echo "  ⚠ Jira project configured but MCP not found"
    fi
else
    echo "  ○ Jira not configured"
fi

# Check Slack
if grep -q "type:.*slack" "$CONFIG_FILE" 2>/dev/null; then
    if command -v claude &>/dev/null && claude mcp list 2>/dev/null | grep -qi slack; then
        echo "  ✓ Slack MCP configured"
    else
        echo "  ⚠ Slack project configured but MCP not found"
    fi
else
    echo "  ○ Slack not configured"
fi

echo ""
echo "Check complete!"

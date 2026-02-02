# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace repository containing productivity tools. The primary plugin is **work-report** (v1.6.0), which generates automated daily/weekly/monthly reports from multiple data sources.

## Plugin Architecture

```
plugins/
└── work-report/
    ├── .claude-plugin/
    │   └── plugin.json          # Plugin manifest
    ├── .mcp.json                 # MCP server config (Notion, Slack)
    ├── agents/                   # Autonomous task runners
    ├── commands/                 # Slash commands (/work-report:*)
    ├── hooks/                    # Lifecycle hooks (Stop event)
    ├── scripts/                  # Automation (bash + PowerShell)
    └── skills/                   # Modular knowledge packages
        ├── automation-setup/
        ├── data-source-patterns/
        └── report-writing/
```

### Key Components

- **Commands** (`commands/*.md`): Slash commands with YAML frontmatter defining `description`, `argument-hint`, and `allowed-tools`
- **Agents** (`agents/*.md`): Autonomous processors with system prompts and tool access
- **Skills** (`skills/*/SKILL.md`): Domain knowledge with progressive disclosure
- **Hooks** (`hooks/hooks.json`): Event-driven automation (currently: session logging on Stop)

## Data Flow

1. Configuration loaded from `.claude/work-report.local.md` (YAML frontmatter)
2. Data collected from sources: Git (required), Claude sessions, Notion/Jira/Slack (optional via MCP)
3. Reports generated in `output_dir` (default: `./reports`)

## MCP Integration

The plugin embeds MCP server configs in `.mcp.json` (plugin root). Supported servers:

- **Notion**: Requires `NOTION_API_TOKEN` environment variable
- **Slack**: Requires `SLACK_BOT_TOKEN` environment variable

No global MCP setup required.

## Cross-Platform Support

All scripts have both Bash (`.sh`) and PowerShell (`.ps1`) versions. Platform detection is automatic in hooks.

## Configuration Reference

User settings in `.claude/work-report.local.md`:

```yaml
language: ko|en
output_dir: ./reports
data_sources: [git, claude, notion, jira, slack]
git_author: email@example.com
git_branches: all|current|[specific]
report_mode: combined|separate
report_format: enhanced|standard
enable_session_logging: false  # Opt-in for privacy
projects:
  - name: "project-name"
    type: git|claude|notion|jira|slack
    path|database_id|channel: "..."
```

## Development Notes

- Plugin uses markdown-based metadata (no build step)
- Scripts use `--dangerously-skip-permissions` for unattended automation
- Session logging is opt-in (default: `false`) for privacy

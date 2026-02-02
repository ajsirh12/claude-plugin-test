# Changelog

All notable changes to the work-report plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2025-01-29

### Added
- **Slack Integration** (⭐ Major Feature)
  - Plugin-level MCP configuration for automatic Slack server inclusion
  - No global MCP setup required - plug & play (same as Notion)
  - Support for public and private channel message retrieval
  - **Message summarization** for report-friendly output
    - Key discussions extraction
    - Decision tracking
    - Announcements identification
    - Action items collection
  - Thread support with `include_threads` option
  - Channel access documentation (Public vs Private)
  - Comprehensive setup guide with troubleshooting
- **Enhanced MCP Validation** (`/work-report:check-mcp`)
  - Now supports both Notion and Slack validation
  - Interactive setup guidance when MCP not connected
  - Service-specific argument support (`slack`, `notion`)
  - Detailed permission and scope guidance
- **Slack Patterns Reference**
  - Updated `skills/data-source-patterns/references/slack-patterns.md`
  - Bot permission requirements
  - Rate limiting guidance
  - Best practices for channel selection

### Changed
- Updated `.mcp.json` to include both Notion and Slack MCP servers
- Enhanced `report-generator` agent with Slack data collection logic
- Updated data integration to merge Slack discussions with Git/Notion data
- Added "Team Discussions" section in reports for Slack summaries
- Updated README with Slack integration documentation

### Technical
- New environment variable: `SLACK_BOT_TOKEN`
- Slack MCP URL: `https://mcp.slack.com/sse`
- Report sections now include Slack-sourced action items and decisions

## [1.5.0] - 2024-01-27

### Added
- **Notion Integration** (⭐ Major Feature)
  - Plugin-level MCP configuration (`.mcp.json`) for automatic Notion server inclusion
  - No global MCP setup required - plug & play
  - Support for Notion databases, pages, and tasks
  - Advanced filtering and sorting options
  - Git + Notion data integration in reports
  - Comprehensive setup documentation with troubleshooting guide
  - Cross-reference patterns in `skills/data-source-patterns/references/notion-patterns.md`
- **MCP Validation Command** (`/work-report:check-mcp`)
  - Environment variable verification
  - MCP server connection test
  - Database access validation
  - Comprehensive troubleshooting guide
- **Cross-platform Support**
  - Added bash version of session logging hook (`save-session-summary.sh`)
  - Updated `hooks.json` to support both Windows and Unix systems
  - Automatic platform detection and script execution
- **LICENSE file** (MIT)
- **CHANGELOG.md** for version tracking

### Changed
- Updated README version reference from v1.4.0 to v1.5.0
- Enhanced `.mcp.json` with environment variable documentation
- Improved hooks to work seamlessly on Linux, macOS, and Windows

### Fixed
- Platform compatibility issues with session logging hooks
- Documentation inconsistencies between plugin.json and README

## [1.4.0] - 2024-01-20

### Added
- **Enhanced Report Format (v2.0)** - Rich visualization and insights
  - Visual elements: progress bars, sparklines, heatmaps
  - Automated insights: hotspot files, work patterns, productivity metrics
  - Comparison analysis: weekly trends, goal tracking
  - Dashboard view with KPI summary
- Helper scripts for enhanced reports
  - `compare-periods.sh/ps1`: Period comparison analysis
  - `analyze-hotspots.sh/ps1`: File hotspot detection
  - `analyze-patterns.sh/ps1`: Work pattern analysis
- Report format configuration option
  - `report_format`: `enhanced` (default) or `standard`
  - Toggleable visualization, insights, and comparison features
- Enhanced report template in `skills/report-writing/templates/`

### Changed
- Default report format set to "enhanced" with rich visualizations
- Updated report-writing skill with enhanced format guidance
- Improved data analysis capabilities

## [1.3.0] - 2024-01-15

### Added
- **Granular Skills Organization**
  - Split monolithic skill into three focused domains:
    - `automation-setup`: CI/CD and scheduler configuration
    - `data-source-patterns`: Git, Claude, Notion, Jira, Slack patterns
    - `report-writing`: Templates and formatting guides
  - Progressive disclosure pattern for better usability
  - Reference materials in skill subdirectories
- Comprehensive automation guides
  - Linux/macOS cron setup
  - Windows Task Scheduler setup
  - CI/CD templates (GitHub Actions, GitLab CI)

### Changed
- Reorganized skill structure from single to multi-skill architecture
- Updated plugin version to 1.3.0
- Improved skill discoverability with focused descriptions

## [1.2.0] - 2024-01-10

### Added
- **Session Logging Feature** (Opt-in)
  - Automatic work summary capture on session end
  - Stop hook integration
  - Privacy-conscious design (excludes sensitive data)
  - Configurable via `enable_session_logging` setting
  - Session log directory configuration (`session_log_dir`)
  - Default disabled to respect user privacy
- Session logging hook scripts
  - `hooks/save-session-summary.ps1` for Windows
  - `hooks/hooks.json` for hook configuration
- Session logs as Claude-type projects in reports
  - Support for `type: claude` in project configuration
  - Session file pattern filtering
  - Session limit configuration

### Changed
- Enhanced project configuration with Claude session support
- Updated README with session logging documentation

## [1.1.0] - 2024-01-05

### Added
- **Multi-Project Support**
  - Combined report mode: single report with all projects
  - Separate report mode: individual reports per project
  - Project-specific configuration overrides
  - Project management commands:
    - `/work-report:configure add-project`
    - `/work-report:configure remove-project`
    - `/work-report:configure list-projects`
- Path-based project configuration
- Multi-project examples in documentation

### Changed
- Enhanced `report-generator` agent with multi-project logic
- Updated report formatting to handle multiple projects
- Improved configuration schema with projects array

## [1.0.0] - 2024-01-01

### Added
- **Core Reporting Commands**
  - `/work-report:daily`: Daily work summary
  - `/work-report:weekly`: Weekly work summary
  - `/work-report:monthly`: Monthly work summary
  - `/work-report:configure`: Configuration management
- **Data Source Integration**
  - Git: commit logs, change statistics
  - Claude: conversation analysis
- **Configuration System**
  - YAML frontmatter in `.claude/work-report.local.md`
  - Customizable output directory and filename patterns
  - Language selection (Korean/English)
  - Git author and branch filtering
- **Report Structure**
  - Summary section
  - Completed tasks
  - In-progress tasks
  - Next plans
  - Code change statistics
  - Commit list
  - Retrospective
- **Automation Support**
  - Auto-report scripts for scheduled execution
  - Cron and Task Scheduler examples
  - `--dangerously-skip-permissions` flag for unattended runs
- **Documentation**
  - Comprehensive README with setup guide
  - Usage examples and troubleshooting
  - Security considerations
- **Plugin Infrastructure**
  - Agent: `report-generator`
  - Commands: daily, weekly, monthly, configure
  - Skills: Initial reporting skill
  - Examples directory with sample configurations

### Technical
- Plugin.json configuration
- .gitignore for local files
- Example configuration files
- Helper scripts (bash and PowerShell)

## [Unreleased]

### Planned
- Jira integration via MCP
- Custom report templates
- Report scheduling within Claude Code
- Export formats (PDF, HTML)
- Team collaboration features

---

## Version History Summary

- **1.6.0**: Slack integration, message summarization, enhanced MCP validation
- **1.5.0**: Notion integration, cross-platform hooks, MCP validation
- **1.4.0**: Enhanced reports v2.0 with visualizations and insights
- **1.3.0**: Granular skills organization
- **1.2.0**: Session logging feature
- **1.1.0**: Multi-project support
- **1.0.0**: Initial release with core reporting features

## Contributing

When adding new features, please update this CHANGELOG with:
- Version number (following semantic versioning)
- Date of release
- Changes categorized as Added/Changed/Deprecated/Removed/Fixed/Security

## Links

- [README](README.md)
- [Plugin Homepage](https://github.com/LimDK/work-report)
- [Issue Tracker](https://github.com/LimDK/work-report/issues)

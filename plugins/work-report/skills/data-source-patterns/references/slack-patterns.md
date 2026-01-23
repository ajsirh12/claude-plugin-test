# Slack Data Collection Patterns

Patterns for collecting and filtering Slack messages for work reports.

## Configuration Examples

### Basic Channel

```yaml
projects:
  - name: "team-chat"
    type: "slack"
    channel: "dev-team"
```

### With Thread Inclusion

```yaml
projects:
  - name: "discussions"
    type: "slack"
    channel: "engineering"
    include_threads: true
```

### Multiple Channels

```yaml
projects:
  - name: "frontend-chat"
    type: "slack"
    channel: "frontend"

  - name: "backend-chat"
    type: "slack"
    channel: "backend"

  - name: "standup"
    type: "slack"
    channel: "daily-standup"
```

## Channel Types

| Type | Format | Example |
|------|--------|---------|
| Public | channel-name | dev-team |
| Private | channel-name | private-dev |
| DM | N/A | Not supported |

**Note:** Direct messages are not collected for privacy reasons.

## Data Fields Collected

| Field | Description |
|-------|-------------|
| timestamp | Message time |
| user | Author name |
| text | Message content |
| thread_ts | Thread identifier |
| reactions | Emoji reactions |

## Filtering Options

### Time-Based

Messages are filtered based on report type:
- **Daily**: Last 24 hours
- **Weekly**: Last 7 days
- **Monthly**: Last 30 days

### Content-Based

Currently, all messages in the channel are collected. Future versions may support:
- Keyword filtering
- Mention filtering
- Reaction filtering

## Report Output Format

Slack data appears in reports as:

```markdown
## Team Discussions

### #dev-team (12 messages)

**Key Discussions:**
- Discussed API rate limiting approach
- Decided on Redis for caching layer
- Reviewed PR #123 feedback

**Notable Threads:**
- "Database migration strategy" (8 replies)
- "Performance optimization ideas" (5 replies)

### #daily-standup (5 messages)

**Updates:**
- Monday: Completed auth feature
- Tuesday: Started caching implementation
- Wednesday: Fixed production bug
```

## Privacy Considerations

- Only collect from work-related channels
- Avoid personal/social channels
- Respect channel privacy settings
- Summarize rather than quote directly

## MCP Server Setup

### Prerequisites

1. Slack MCP server installed
2. Slack app with appropriate permissions:
   - `channels:history`
   - `channels:read`
   - `users:read`

### Configuration

```json
// .mcp.json
{
  "slack": {
    "type": "stdio",
    "command": "mcp-slack",
    "env": {
      "SLACK_TOKEN": "${SLACK_BOT_TOKEN}"
    }
  }
}
```

## Troubleshooting

### "Channel not found"

1. Check channel name (without #)
2. Verify bot is added to channel
3. Check channel visibility

### "No messages collected"

1. Verify date range
2. Check if channel has activity
3. Confirm permissions

### "Rate limited"

1. Reduce collection frequency
2. Collect fewer channels
3. Use larger time intervals

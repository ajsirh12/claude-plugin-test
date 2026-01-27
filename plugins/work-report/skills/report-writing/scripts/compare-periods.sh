#!/bin/bash
# Compare git statistics between two time periods

# Usage: compare-periods.sh <current_since> <current_until> <previous_since> <previous_until> <author>
# Example: compare-periods.sh "1 week ago" "now" "2 weeks ago" "1 week ago" "user@example.com"

CURRENT_SINCE="${1:-1 week ago}"
CURRENT_UNTIL="${2:-now}"
PREVIOUS_SINCE="${3:-2 weeks ago}"
PREVIOUS_UNTIL="${4:-1 week ago}"
AUTHOR="${5:-$(git config user.email)}"

# Function to get stats for a period
get_period_stats() {
  local since="$1"
  local until="$2"

  # Commits
  local commits=$(git log --since="$since" --until="$until" --author="$AUTHOR" --oneline 2>/dev/null | wc -l)

  # Files changed
  local files=$(git log --since="$since" --until="$until" --author="$AUTHOR" --name-only --format="" 2>/dev/null | grep -v '^$' | sort -u | wc -l)

  # Lines added/deleted
  local stats=$(git log --since="$since" --until="$until" --author="$AUTHOR" --numstat --format="" 2>/dev/null | \
    awk '{add+=$1; del+=$2} END {print add, del}')
  local additions=$(echo "$stats" | awk '{print $1}')
  local deletions=$(echo "$stats" | awk '{print $2}')

  # Handle empty results
  commits=${commits:-0}
  files=${files:-0}
  additions=${additions:-0}
  deletions=${deletions:-0}

  echo "$commits,$files,$additions,$deletions"
}

# Get current period stats
CURRENT_STATS=$(get_period_stats "$CURRENT_SINCE" "$CURRENT_UNTIL")
CURRENT_COMMITS=$(echo "$CURRENT_STATS" | cut -d',' -f1)
CURRENT_FILES=$(echo "$CURRENT_STATS" | cut -d',' -f2)
CURRENT_ADDITIONS=$(echo "$CURRENT_STATS" | cut -d',' -f3)
CURRENT_DELETIONS=$(echo "$CURRENT_STATS" | cut -d',' -f4)

# Get previous period stats
PREVIOUS_STATS=$(get_period_stats "$PREVIOUS_SINCE" "$PREVIOUS_UNTIL")
PREVIOUS_COMMITS=$(echo "$PREVIOUS_STATS" | cut -d',' -f1)
PREVIOUS_FILES=$(echo "$PREVIOUS_STATS" | cut -d',' -f2)
PREVIOUS_ADDITIONS=$(echo "$PREVIOUS_STATS" | cut -d',' -f3)
PREVIOUS_DELETIONS=$(echo "$PREVIOUS_STATS" | cut -d',' -f4)

# Function to calculate percentage change
calc_change() {
  local current=$1
  local previous=$2

  if [ "$previous" -eq 0 ]; then
    if [ "$current" -eq 0 ]; then
      echo "0"
    else
      echo "100"  # New activity
    fi
  else
    echo "scale=1; ($current - $previous) * 100 / $previous" | bc
  fi
}

# Calculate changes
COMMITS_CHANGE=$(calc_change "$CURRENT_COMMITS" "$PREVIOUS_COMMITS")
FILES_CHANGE=$(calc_change "$CURRENT_FILES" "$PREVIOUS_FILES")
ADDITIONS_CHANGE=$(calc_change "$CURRENT_ADDITIONS" "$PREVIOUS_ADDITIONS")
DELETIONS_CHANGE=$(calc_change "$CURRENT_DELETIONS" "$PREVIOUS_DELETIONS")

# Function to get trend indicator
get_trend() {
  local change=$1
  local is_higher_better=${2:-true}

  # Handle bc output (may have - sign)
  local abs_change=$(echo "$change" | sed 's/-//')

  if (( $(echo "$change > 5" | bc -l) )); then
    if [ "$is_higher_better" = "true" ]; then
      echo "📈"
    else
      echo "📉"
    fi
  elif (( $(echo "$change < -5" | bc -l) )); then
    if [ "$is_higher_better" = "true" ]; then
      echo "📉"
    else
      echo "📈"
    fi
  else
    echo "➡️"
  fi
}

# Output comparison table
cat <<EOF
| 지표 | 현재 기간 | 이전 기간 | 변화 | 추세 |
|-----|---------|---------|------|------|
| 커밋 수 | $CURRENT_COMMITS | $PREVIOUS_COMMITS | ${COMMITS_CHANGE:+}${COMMITS_CHANGE}% | $(get_trend "$COMMITS_CHANGE" true) |
| 변경 파일 | $CURRENT_FILES | $PREVIOUS_FILES | ${FILES_CHANGE:+}${FILES_CHANGE}% | $(get_trend "$FILES_CHANGE" true) |
| 추가 라인 | +$CURRENT_ADDITIONS | +$PREVIOUS_ADDITIONS | ${ADDITIONS_CHANGE:+}${ADDITIONS_CHANGE}% | $(get_trend "$ADDITIONS_CHANGE" true) |
| 삭제 라인 | -$CURRENT_DELETIONS | -$PREVIOUS_DELETIONS | ${DELETIONS_CHANGE:+}${DELETIONS_CHANGE}% | $(get_trend "$DELETIONS_CHANGE" false) |
EOF

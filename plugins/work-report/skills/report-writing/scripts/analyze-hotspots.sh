#!/bin/bash
# Analyze file hotspots - frequently changed files that may need refactoring

# Usage: analyze-hotspots.sh <since> <author>
# Example: analyze-hotspots.sh "1 week ago" "user@example.com"

SINCE="${1:-1 week ago}"
AUTHOR="${2:-$(git config user.email)}"

echo "| 순위 | 파일 | 변경 횟수 | 총 변경량 | 분류 |"
echo "|-----|------|---------|----------|------|"

# Get file change frequency and total changes
git log --since="$SINCE" --author="$AUTHOR" --name-only --format="" 2>/dev/null | \
  grep -v '^$' | \
  sort | uniq -c | sort -rn | head -10 | \
  while read count file; do
    # Get total line changes for this file
    changes=$(git log --since="$SINCE" --author="$AUTHOR" --numstat --format="" -- "$file" 2>/dev/null | \
              awk '{add+=$1; del+=$2} END {printf "+%d/-%d", add, del}')

    # Determine status based on change frequency
    if [ "$count" -ge 8 ]; then
      status="🔴 핫스팟"
    elif [ "$count" -ge 5 ]; then
      status="🟡 주의"
    else
      status="🟢 정상"
    fi

    # Get ranking
    rank=$((rank + 1))

    # Truncate long filenames
    short_file=$(echo "$file" | awk '{
      if (length($0) > 40)
        print substr($0, 1, 37) "...";
      else
        print $0;
    }')

    echo "| $rank | \`$short_file\` | ${count}회 | $changes | $status |"
  done

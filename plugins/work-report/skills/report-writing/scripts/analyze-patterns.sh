#!/bin/bash
# Analyze work patterns - time and day distribution

# Usage: analyze-patterns.sh <since> <author>
# Example: analyze-patterns.sh "1 week ago" "user@example.com"

SINCE="${1:-1 week ago}"
AUTHOR="${2:-$(git config user.email)}"

echo "## 작업 패턴 분석"
echo ""

# Time-based analysis
echo "### 시간대별 커밋 분포"
echo '```'

# Get hourly distribution
hourly=$(git log --since="$SINCE" --author="$AUTHOR" --format="%ad" --date=format:"%H" 2>/dev/null | \
         sort | uniq -c)

# Calculate totals for each period
morning=0
afternoon=0
evening=0
total=0

while read count hour; do
  total=$((total + count))
  if [ "$hour" -ge 6 ] && [ "$hour" -lt 12 ]; then
    morning=$((morning + count))
  elif [ "$hour" -ge 12 ] && [ "$hour" -lt 18 ]; then
    afternoon=$((afternoon + count))
  else
    evening=$((evening + count))
  fi
done <<< "$hourly"

# Calculate percentages and generate bars
if [ "$total" -gt 0 ]; then
  morning_pct=$((morning * 100 / total))
  afternoon_pct=$((afternoon * 100 / total))
  evening_pct=$((evening * 100 / total))

  # Generate progress bars (10 chars wide)
  morning_bar=$(printf '█%.0s' $(seq 1 $((morning_pct / 10))))$(printf '░%.0s' $(seq 1 $((10 - morning_pct / 10))))
  afternoon_bar=$(printf '█%.0s' $(seq 1 $((afternoon_pct / 10))))$(printf '░%.0s' $(seq 1 $((10 - afternoon_pct / 10))))
  evening_bar=$(printf '█%.0s' $(seq 1 $((evening_pct / 10))))$(printf '░%.0s' $(seq 1 $((10 - evening_pct / 10))))

  echo "오전 (06-12):  $morning_bar ${morning_pct}%  (${morning}개)"
  echo "오후 (12-18):  $afternoon_bar ${afternoon_pct}%  (${afternoon}개)"
  echo "저녁 (18-24):  $evening_bar ${evening_pct}%  (${evening}개)"
else
  echo "데이터 없음"
fi
echo '```'
echo ""

# Day-based analysis
echo "### 요일별 활동"
echo '```'

# Get daily distribution
daily=$(git log --since="$SINCE" --author="$AUTHOR" --format="%ad" --date=format:"%u" 2>/dev/null | \
        sort | uniq -c)

# Day names in Korean
declare -A day_names=(
  [1]="월요일"
  [2]="화요일"
  [3]="수요일"
  [4]="목요일"
  [5]="금요일"
  [6]="토요일"
  [7]="일요일"
)

# Find max for normalization
max_count=0
while read count day; do
  if [ "$count" -gt "$max_count" ]; then
    max_count=$count
  fi
done <<< "$daily"

# Display daily distribution
if [ "$max_count" -gt 0 ]; then
  for day_num in {1..7}; do
    count=$(echo "$daily" | grep "^ *[0-9]* $day_num$" | awk '{print $1}')
    count=${count:-0}

    # Calculate percentage
    pct=$((count * 100 / total))

    # Generate bar
    bar_length=$((pct / 10))
    bar=$(printf '█%.0s' $(seq 1 $bar_length))$(printf '░%.0s' $(seq 1 $((10 - bar_length))))

    # Mark highest productivity day
    mark=""
    if [ "$count" -eq "$max_count" ]; then
      mark=" ⭐ 최고 생산성"
    fi

    echo "${day_names[$day_num]}: $bar ${pct}%${mark}"
  done
else
  echo "데이터 없음"
fi
echo '```'

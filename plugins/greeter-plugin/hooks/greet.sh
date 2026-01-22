#!/bin/bash
set -euo pipefail

# 사용자 이름 가져오기 (Windows: USERNAME, Unix: USER)
username="${USERNAME:-${USER:-사용자}}"

# 현재 시간(시) 가져오기
hour=$(date +%H)

# 시간대별 인사말 선택
if [ "$hour" -ge 6 ] && [ "$hour" -lt 12 ]; then
    greeting="좋은 아침입니다"
    message="오늘 하루도 활기차게 시작하세요."
elif [ "$hour" -ge 12 ] && [ "$hour" -lt 18 ]; then
    greeting="좋은 오후입니다"
    message="무엇을 도와드릴까요?"
elif [ "$hour" -ge 18 ] && [ "$hour" -lt 22 ]; then
    greeting="좋은 저녁입니다"
    message="오늘 하루 수고 많으셨습니다."
else
    greeting="안녕하세요"
    message="늦은 시간까지 열심히 하시네요."
fi

# 인사 메시지 출력 (systemMessage로 Claude에게 전달)
cat <<EOF
{
  "continue": true,
  "systemMessage": "${greeting}, ${username}님! ${message}"
}
EOF

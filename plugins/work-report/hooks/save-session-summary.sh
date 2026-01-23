#!/bin/bash
# work-report 세션 요약 저장 Hook
# Stop 이벤트에서 호출되어 작업 요약을 저장하도록 Claude에게 요청합니다.
#
# 동작:
# 1. .claude/work-report.local.md에서 enable_session_logging 설정 확인
# 2. 비활성화(false)면 바로 종료
# 3. 활성화(true)면 systemMessage로 요약 저장 지시

set -euo pipefail

# 프로젝트 디렉토리 결정 (CLAUDE_PROJECT_DIR > PWD)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# 설정 파일 경로
CONFIG_FILE="${PROJECT_DIR}/.claude/work-report.local.md"

# 설정 파일이 없으면 기본값(false)으로 처리
if [ ! -f "$CONFIG_FILE" ]; then
  # 설정 파일 없음 - 세션 로깅 비활성화 상태
  echo '{"decision": "approve"}'
  exit 0
fi

# YAML frontmatter에서 enable_session_logging 값 추출
# --- 와 --- 사이의 YAML에서 enable_session_logging 찾기
ENABLED=$(sed -n '/^---$/,/^---$/p' "$CONFIG_FILE" | grep -E "^enable_session_logging:" | head -1 | awk '{print $2}' || echo "false")

# 값 정규화 (true/false)
ENABLED=$(echo "$ENABLED" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

# 비활성화 상태면 바로 승인
if [ "$ENABLED" != "true" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# 활성화 상태 - 저장 디렉토리 확인
SESSION_LOG_DIR=$(sed -n '/^---$/,/^---$/p' "$CONFIG_FILE" | grep -E "^session_log_dir:" | head -1 | sed 's/session_log_dir:[[:space:]]*//' || echo "")
OUTPUT_DIR=$(sed -n '/^---$/,/^---$/p' "$CONFIG_FILE" | grep -E "^output_dir:" | head -1 | sed 's/output_dir:[[:space:]]*//' || echo "./reports")

# session_log_dir가 없으면 .claude/sessions 사용 (일관성 유지)
if [ -z "$SESSION_LOG_DIR" ]; then
  SESSION_LOG_DIR=".claude/sessions"
fi

# 경로에서 따옴표 제거
SESSION_LOG_DIR=$(echo "$SESSION_LOG_DIR" | tr -d '"' | tr -d "'")

# 날짜 생성 (같은 날짜는 같은 파일 사용)
DATE=$(date +%Y-%m-%d)
FILENAME="session-${DATE}.md"
FILEPATH="${SESSION_LOG_DIR}/${FILENAME}"
TIMESTAMP=$(date +%H:%M:%S)

# systemMessage로 Claude에게 요약 저장 지시
# 파일이 있으면 append, 없으면 새로 생성
cat << EOF
{
  "decision": "approve",
  "systemMessage": "[세션로깅] ${FILEPATH}에 작업기록 추가. 시간: ${TIMESTAMP}. 파일이 있으면 '---' 구분선 후 append, 없으면 새로 생성. 형식: ## ${TIMESTAMP} / 작업내용 1-2줄 요약. 민감정보 제외."
}
EOF

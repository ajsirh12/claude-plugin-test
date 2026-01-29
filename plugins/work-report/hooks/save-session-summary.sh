#!/bin/bash
# work-report 세션 요약 저장 Hook (Linux/macOS)
# Stop 이벤트에서 호출되어 작업 요약을 저장하도록 Claude에게 요청합니다.

set -e

# 설정 파일 경로
CONFIG_FILE="${CLAUDE_PROJECT_DIR}/.claude/work-report.local.md"

# 설정 파일이 없으면 기본값(false)으로 처리
if [ ! -f "$CONFIG_FILE" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# 파일 내용 읽기
CONTENT=$(cat "$CONFIG_FILE")

# YAML frontmatter에서 enable_session_logging 추출
ENABLED="false"
if echo "$CONTENT" | grep -qE "enable_session_logging:[[:space:]]*(true|false)"; then
  ENABLED=$(echo "$CONTENT" | grep -E "enable_session_logging:" | head -1 | sed 's/.*enable_session_logging:[[:space:]]*//' | tr -d '[:space:]')
fi

# 비활성화 상태면 바로 승인
if [ "$ENABLED" != "true" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# 저장 디렉토리 추출
SESSION_LOG_DIR=""
OUTPUT_DIR="./reports"

if echo "$CONTENT" | grep -qE "session_log_dir:"; then
  SESSION_LOG_DIR=$(echo "$CONTENT" | grep -E "session_log_dir:" | head -1 | sed 's/.*session_log_dir:[[:space:]]*//' | tr -d '"' | tr -d "'")
fi
if echo "$CONTENT" | grep -qE "output_dir:"; then
  OUTPUT_DIR=$(echo "$CONTENT" | grep -E "output_dir:" | head -1 | sed 's/.*output_dir:[[:space:]]*//' | tr -d '"' | tr -d "'")
fi

# session_log_dir가 없으면 .claude/sessions 사용 (일관성 유지)
if [ -z "$SESSION_LOG_DIR" ]; then
  SESSION_LOG_DIR=".claude/sessions"
fi

# 날짜/시간 생성
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H%M%S)
FILENAME="session-$DATE-$TIME.md"

# systemMessage 출력 (간소화)
SYSTEM_MESSAGE="[Session Logging] Save work summary to $SESSION_LOG_DIR/$FILENAME. Format: task-type/changed-files/summary/next-steps. Exclude sensitive info (API keys, passwords, usernames)."

# JSON 출력
cat << EOF
{"decision": "approve", "systemMessage": "$SYSTEM_MESSAGE"}
EOF

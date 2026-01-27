# work-report 세션 요약 저장 Hook (Windows PowerShell)
# Stop 이벤트에서 호출되어 작업 요약을 저장하도록 Claude에게 요청합니다.

$ErrorActionPreference = "Stop"

# 설정 파일 경로
$configFile = Join-Path $env:CLAUDE_PROJECT_DIR ".claude\work-report.local.md"

# 설정 파일이 없으면 기본값(false)으로 처리
if (-not (Test-Path $configFile)) {
    Write-Output '{"decision": "approve"}'
    exit 0
}

# 파일 내용 읽기
$content = Get-Content $configFile -Raw

# YAML frontmatter에서 enable_session_logging 추출
$enabled = "false"
if ($content -match "enable_session_logging:\s*(true|false)") {
    $enabled = $matches[1].ToLower()
}

# 비활성화 상태면 바로 승인
if ($enabled -ne "true") {
    Write-Output '{"decision": "approve"}'
    exit 0
}

# 저장 디렉토리 추출
$sessionLogDir = ""
$outputDir = "./reports"

if ($content -match "session_log_dir:\s*([^\r\n]+)") {
    $sessionLogDir = $matches[1].Trim().Trim('"').Trim("'")
}
if ($content -match "output_dir:\s*([^\r\n]+)") {
    $outputDir = $matches[1].Trim().Trim('"').Trim("'")
}

# session_log_dir가 없으면 .claude/sessions 사용 (일관성 유지)
if ([string]::IsNullOrEmpty($sessionLogDir)) {
    $sessionLogDir = ".claude/sessions"
}

# 날짜/시간 생성
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HHmmss"
$filename = "session-$date-$time.md"

# systemMessage 출력 (간소화)
$systemMessage = "[Session Logging] Save work summary to $sessionLogDir/$filename. Format: task-type/changed-files/summary/next-steps. Exclude sensitive info (API keys, passwords, usernames)."

$output = @{
    decision = "approve"
    systemMessage = $systemMessage
} | ConvertTo-Json -Compress

Write-Output $output

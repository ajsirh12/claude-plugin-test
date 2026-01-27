# Analyze file hotspots - frequently changed files that may need refactoring (PowerShell)

param(
    [string]$Since = "1 week ago",
    [string]$Author = ""
)

# Get author if not provided
if ([string]::IsNullOrEmpty($Author)) {
    $Author = git config user.email
}

# Get file changes
$fileChanges = git log --since="$Since" --author="$Author" --name-only --format="" 2>$null |
               Where-Object { $_ -ne "" } |
               Group-Object |
               Sort-Object Count -Descending |
               Select-Object -First 10

# Output table header
Write-Output "| 순위 | 파일 | 변경 횟수 | 총 변경량 | 분류 |"
Write-Output "|-----|------|---------|----------|------|"

$rank = 0
foreach ($item in $fileChanges) {
    $rank++
    $file = $item.Name
    $count = $item.Count

    # Get total line changes for this file
    $numstat = git log --since="$Since" --author="$Author" --numstat --format="" -- $file 2>$null
    $additions = 0
    $deletions = 0

    if ($numstat) {
        $numstat | ForEach-Object {
            $parts = $_ -split '\s+'
            if ($parts.Length -ge 2) {
                $add = $parts[0]
                $del = $parts[1]
                if ($add -match '^\d+$') { $additions += [int]$add }
                if ($del -match '^\d+$') { $deletions += [int]$del }
            }
        }
    }

    $changes = "+$additions/-$deletions"

    # Determine status based on change frequency
    if ($count -ge 8) {
        $status = "🔴 핫스팟"
    } elseif ($count -ge 5) {
        $status = "🟡 주의"
    } else {
        $status = "🟢 정상"
    }

    # Truncate long filenames
    $shortFile = if ($file.Length -gt 40) {
        $file.Substring(0, 37) + "..."
    } else {
        $file
    }

    Write-Output "| $rank | ``$shortFile`` | ${count}회 | $changes | $status |"
}

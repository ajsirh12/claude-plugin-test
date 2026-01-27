# Compare git statistics between two time periods (PowerShell version)

param(
    [string]$CurrentSince = "1 week ago",
    [string]$CurrentUntil = "now",
    [string]$PreviousSince = "2 weeks ago",
    [string]$PreviousUntil = "1 week ago",
    [string]$Author = ""
)

# Get author if not provided
if ([string]::IsNullOrEmpty($Author)) {
    $Author = git config user.email
}

# Function to get stats for a period
function Get-PeriodStats {
    param(
        [string]$Since,
        [string]$Until
    )

    # Commits
    $commits = (git log --since="$Since" --until="$Until" --author="$Author" --oneline 2>$null | Measure-Object).Count
    if ($null -eq $commits) { $commits = 0 }

    # Files changed
    $files = (git log --since="$Since" --until="$Until" --author="$Author" --name-only --format="" 2>$null |
              Where-Object { $_ -ne "" } |
              Sort-Object -Unique |
              Measure-Object).Count
    if ($null -eq $files) { $files = 0 }

    # Lines added/deleted
    $numstat = git log --since="$Since" --until="$Until" --author="$Author" --numstat --format="" 2>$null
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

    return @{
        Commits = $commits
        Files = $files
        Additions = $additions
        Deletions = $deletions
    }
}

# Get current period stats
$currentStats = Get-PeriodStats -Since $CurrentSince -Until $CurrentUntil

# Get previous period stats
$previousStats = Get-PeriodStats -Since $PreviousSince -Until $PreviousUntil

# Function to calculate percentage change
function Get-PercentageChange {
    param(
        [int]$Current,
        [int]$Previous
    )

    if ($Previous -eq 0) {
        if ($Current -eq 0) {
            return 0
        } else {
            return 100  # New activity
        }
    } else {
        return [math]::Round((($Current - $Previous) / $Previous) * 100, 1)
    }
}

# Calculate changes
$commitsChange = Get-PercentageChange -Current $currentStats.Commits -Previous $previousStats.Commits
$filesChange = Get-PercentageChange -Current $currentStats.Files -Previous $previousStats.Files
$additionsChange = Get-PercentageChange -Current $currentStats.Additions -Previous $previousStats.Additions
$deletionsChange = Get-PercentageChange -Current $currentStats.Deletions -Previous $previousStats.Deletions

# Function to get trend indicator
function Get-TrendIndicator {
    param(
        [double]$Change,
        [bool]$IsHigherBetter = $true
    )

    if ($Change -gt 5) {
        return if ($IsHigherBetter) { "📈" } else { "📉" }
    } elseif ($Change -lt -5) {
        return if ($IsHigherBetter) { "📉" } else { "📈" }
    } else {
        return "➡️"
    }
}

# Format change with sign
function Format-Change {
    param([double]$Value)
    if ($Value -gt 0) {
        return "+$Value%"
    } else {
        return "$Value%"
    }
}

# Output comparison table
@"
| 지표 | 현재 기간 | 이전 기간 | 변화 | 추세 |
|-----|---------|---------|------|------|
| 커밋 수 | $($currentStats.Commits) | $($previousStats.Commits) | $(Format-Change $commitsChange) | $(Get-TrendIndicator -Change $commitsChange -IsHigherBetter $true) |
| 변경 파일 | $($currentStats.Files) | $($previousStats.Files) | $(Format-Change $filesChange) | $(Get-TrendIndicator -Change $filesChange -IsHigherBetter $true) |
| 추가 라인 | +$($currentStats.Additions) | +$($previousStats.Additions) | $(Format-Change $additionsChange) | $(Get-TrendIndicator -Change $additionsChange -IsHigherBetter $true) |
| 삭제 라인 | -$($currentStats.Deletions) | -$($previousStats.Deletions) | $(Format-Change $deletionsChange) | $(Get-TrendIndicator -Change $deletionsChange -IsHigherBetter $false) |
"@

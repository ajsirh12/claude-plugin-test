# Analyze work patterns - time and day distribution (PowerShell)

param(
    [string]$Since = "1 week ago",
    [string]$Author = ""
)

# Get author if not provided
if ([string]::IsNullOrEmpty($Author)) {
    $Author = git config user.email
}

Write-Output "## 작업 패턴 분석"
Write-Output ""

# Time-based analysis
Write-Output "### 시간대별 커밋 분포"
Write-Output '```'

# Get hourly distribution
$hourly = git log --since="$Since" --author="$Author" --format="%ad" --date=format:"%H" 2>$null |
          Group-Object

$morning = 0
$afternoon = 0
$evening = 0
$total = 0

foreach ($item in $hourly) {
    $hour = [int]$item.Name
    $count = $item.Count
    $total += $count

    if ($hour -ge 6 -and $hour -lt 12) {
        $morning += $count
    } elseif ($hour -ge 12 -and $hour -lt 18) {
        $afternoon += $count
    } else {
        $evening += $count
    }
}

# Function to generate progress bar
function Get-ProgressBar {
    param([int]$Percentage)
    $filled = [math]::Floor($Percentage / 10)
    $empty = 10 - $filled
    return ('█' * $filled) + ('░' * $empty)
}

if ($total -gt 0) {
    $morningPct = [math]::Round(($morning / $total) * 100)
    $afternoonPct = [math]::Round(($afternoon / $total) * 100)
    $eveningPct = [math]::Round(($evening / $total) * 100)

    $morningBar = Get-ProgressBar -Percentage $morningPct
    $afternoonBar = Get-ProgressBar -Percentage $afternoonPct
    $eveningBar = Get-ProgressBar -Percentage $eveningPct

    Write-Output "오전 (06-12):  $morningBar ${morningPct}%  (${morning}개)"
    Write-Output "오후 (12-18):  $afternoonBar ${afternoonPct}%  (${afternoon}개)"
    Write-Output "저녁 (18-24):  $eveningBar ${eveningPct}%  (${evening}개)"
} else {
    Write-Output "데이터 없음"
}

Write-Output '```'
Write-Output ""

# Day-based analysis
Write-Output "### 요일별 활동"
Write-Output '```'

# Get daily distribution (1=Monday, 7=Sunday)
$daily = git log --since="$Since" --author="$Author" --format="%ad" --date=format:"%u" 2>$null |
         Group-Object |
         Sort-Object Name

# Day names in Korean
$dayNames = @{
    1 = "월요일"
    2 = "화요일"
    3 = "수요일"
    4 = "목요일"
    5 = "금요일"
    6 = "토요일"
    7 = "일요일"
}

# Find max count
$maxCount = 0
$dailyStats = @{}
foreach ($item in $daily) {
    $dayNum = [int]$item.Name
    $count = $item.Count
    $dailyStats[$dayNum] = $count
    if ($count -gt $maxCount) {
        $maxCount = $count
    }
}

if ($total -gt 0) {
    for ($dayNum = 1; $dayNum -le 7; $dayNum++) {
        $count = if ($dailyStats.ContainsKey($dayNum)) { $dailyStats[$dayNum] } else { 0 }
        $pct = [math]::Round(($count / $total) * 100)
        $bar = Get-ProgressBar -Percentage $pct

        $mark = if ($count -eq $maxCount -and $count -gt 0) { " ⭐ 최고 생산성" } else { "" }

        Write-Output "$($dayNames[$dayNum]): $bar ${pct}%${mark}"
    }
} else {
    Write-Output "데이터 없음"
}

Write-Output '```'

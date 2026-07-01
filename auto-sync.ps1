# auto-sync.ps1
# 구독관리(book_control) 프로젝트 자동 GitHub 업로드 감시 스크립트
# 30초마다 변경을 감지해 자동으로 커밋 & 푸시합니다.

$ErrorActionPreference = "Stop"
$repo = "C:\Users\sdw19\Desktop\260701_구독관리"
$logFile = Join-Path $repo "auto-sync.log"
$intervalSec = 30

function Write-Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts  $msg" | Out-File -FilePath $logFile -Append -Encoding utf8
}

Set-Location $repo
Write-Log "=== auto-sync 시작 (감시 간격 ${intervalSec}초) ==="

while ($true) {
    try {
        # 원격 변경 먼저 반영 (충돌 없이 rebase)
        git -c user.name="sdw1621" -c user.email="sdw1621@gmail.com" pull --rebase --autostash origin main 2>&1 | Out-Null

        # 로컬 변경 확인
        $status = git status --porcelain
        if ($status) {
            git add -A 2>&1 | Out-Null
            $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
            $msg = "자동 저장: $ts (직접 수정 반영)"
            git -c user.name="sdw1621" -c user.email="sdw1621@gmail.com" commit -m $msg 2>&1 | Out-Null
            git push origin main 2>&1 | Out-Null
            $files = ($status | Measure-Object).Count
            Write-Log "커밋 & 푸시 완료 ($files개 파일 변경)"
        }
    }
    catch {
        Write-Log "오류: $($_.Exception.Message)"
    }
    Start-Sleep -Seconds $intervalSec
}

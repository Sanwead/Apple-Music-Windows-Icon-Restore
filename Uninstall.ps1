$ErrorActionPreference = 'Stop'
$state = Join-Path $PSScriptRoot 'state'
New-Item -ItemType Directory -Path $state -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $state 'stop') -Force | Out-Null
$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$taskName = "AppleMusic-RedIcon-$sid"
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
$link = Join-Path ([Environment]::GetFolderPath('Startup')) 'AppleMusic Red Icon OSS.lnk'
if (Test-Path -LiteralPath $link) { Remove-Item -LiteralPath $link }
Start-Sleep -Seconds 4
Add-Type -Path (Join-Path $PSScriptRoot 'Taskbar.cs')
foreach ($music in @(Get-Process AppleMusic -ErrorAction SilentlyContinue)) {
    $hwnd = $music.MainWindowHandle.ToInt64()
    if ($hwnd -eq 0) { continue }
    if ([MusicTaskbar]::Read($hwnd, 5) -eq 'Local.AppleMusic.RedIcon') {
        foreach ($key in @(2,3,4,5)) { [MusicTaskbar]::Write($hwnd, $key, [NullString]::Value) }
    }
}
Write-Host 'Disabled and removed the launch task. Close and reopen Apple Music to restore the original window icon.'

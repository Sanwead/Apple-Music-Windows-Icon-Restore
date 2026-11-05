param([switch]$Once)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$state = Join-Path $root 'state'
$config = Get-Content -LiteralPath (Join-Path $state 'config.json') -Raw | ConvertFrom-Json
$icon = $config.IconPath
if (-not (Test-Path -LiteralPath $icon -PathType Leaf)) { throw "Icon not found: $icon" }
$mutex = New-Object System.Threading.Mutex($false, 'Local\AppleMusicRedIconOpenSource')
if (-not $mutex.WaitOne(0)) { exit }
try {
    Add-Type -Path (Join-Path $root 'Taskbar.cs')
    do {
        foreach ($music in @(Get-Process AppleMusic -ErrorAction SilentlyContinue)) {
            $hwnd = $music.MainWindowHandle.ToInt64()
            if ($hwnd -eq 0) { continue }
            try {
                [MusicTaskbar]::SetWindowIcons($hwnd, $icon)
                if ([MusicTaskbar]::Read($hwnd, 5) -ne 'Local.AppleMusic.RedIcon') {
                    [MusicTaskbar]::Write($hwnd, 2, "$env:SystemRoot\explorer.exe shell:AppsFolder\$($config.AppId)")
                    [MusicTaskbar]::Write($hwnd, 3, "$icon,0")
                    [MusicTaskbar]::Write($hwnd, 4, 'Apple Music')
                    [MusicTaskbar]::Write($hwnd, 5, 'Local.AppleMusic.RedIcon')
                }
            } catch {
                $_.Exception.Message | Set-Content -LiteralPath (Join-Path $state 'last-error.log')
            }
        }
        if (-not $Once) { Start-Sleep -Seconds 3 }
    } while (-not $Once -and -not (Test-Path -LiteralPath (Join-Path $state 'stop')))
} finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}

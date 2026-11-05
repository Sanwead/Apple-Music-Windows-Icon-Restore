param([switch]$Once)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$state = Join-Path $root 'state'
$config = Get-Content -LiteralPath (Join-Path $state 'config.json') -Raw | ConvertFrom-Json
$icon = $config.IconPath
if (-not (Test-Path -LiteralPath $icon -PathType Leaf)) { throw "Icon not found: $icon" }
$mutex = New-Object System.Threading.Mutex($false, 'Local\AppleMusicRedIconOpenSource')
$locked = $false
$hostProcess = $null
try {
    try { $locked = $mutex.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $locked = $true }
    if (-not $locked) { return }
    Add-Type -Path (Join-Path $root 'Taskbar.cs')
    # Resolve every launch again; Store version directories are not hardcoded.
    $package = Get-AppxPackage -Name AppleInc.AppleMusicWin | Select-Object -First 1
    if (-not $package) { throw 'Apple Music is not installed.' }
    $expectedPath = Join-Path $package.InstallLocation 'AppleMusic.exe'
    $appId = "$($package.PackageFamilyName)!App"
    $sessionId = (Get-Process -Id $PID).SessionId
    $deadline = [DateTime]::UtcNow.AddSeconds(20)
    do {
        $hostProcess = Get-Process AppleMusic -ErrorAction SilentlyContinue |
            Where-Object { $_.SessionId -eq $sessionId -and $_.Path -eq $expectedPath } |
            Sort-Object StartTime -Descending | Select-Object -First 1
        if ($hostProcess -or $Once) { break }
        Start-Sleep -Milliseconds 200
    } while ([DateTime]::UtcNow -lt $deadline -and -not (Test-Path -LiteralPath (Join-Path $state 'stop')))
    if (-not $hostProcess) { return }
    $null = $hostProcess.Handle
    $appliedWindow = 0
    @{HelperPid=$PID;HostPid=$hostProcess.Id;State='running'} | ConvertTo-Json |
        Set-Content -LiteralPath (Join-Path $state 'runtime.json') -Encoding UTF8
    do {
        $hostProcess.Refresh()
        if ($hostProcess.HasExited) { break }
        $hwnd = $hostProcess.MainWindowHandle.ToInt64()
        if ($hwnd -ne 0) {
            try {
                [MusicTaskbar]::SetWindowIcons($hwnd, $icon)
                if ([MusicTaskbar]::Read($hwnd, 5) -ne 'Local.AppleMusic.RedIcon') {
                    [MusicTaskbar]::Write($hwnd, 2, "$env:SystemRoot\explorer.exe shell:AppsFolder\$appId")
                    [MusicTaskbar]::Write($hwnd, 3, "$icon,0")
                    [MusicTaskbar]::Write($hwnd, 4, 'Apple Music')
                    [MusicTaskbar]::Write($hwnd, 5, 'Local.AppleMusic.RedIcon')
                }
                if ($appliedWindow -ne $hwnd) {
                    @{HelperPid=$PID;HostPid=$hostProcess.Id;State='applied';Window=$hwnd} |
                        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $state 'runtime.json') -Encoding UTF8
                    $appliedWindow = $hwnd
                }
            } catch {
                $_.Exception.Message | Set-Content -LiteralPath (Join-Path $state 'last-error.log')
            }
        }
        if ($Once -or $hostProcess.WaitForExit(750)) { break }
    } while (-not (Test-Path -LiteralPath (Join-Path $state 'stop')))
} catch {
    $_.Exception.Message | Set-Content -LiteralPath (Join-Path $state 'last-error.log')
    throw
} finally {
    if ($hostProcess) { $hostProcess.Dispose() }
    if ($locked) {
        @{HelperPid=$PID;State='exited'} | ConvertTo-Json |
            Set-Content -LiteralPath (Join-Path $state 'runtime.json') -Encoding UTF8
        $mutex.ReleaseMutex()
    }
    $mutex.Dispose()
}

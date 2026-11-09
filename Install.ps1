param([string]$IconPath = (Join-Path $PSScriptRoot 'assets\red.ico'))
$ErrorActionPreference = 'Stop'
if (-not [Environment]::Is64BitProcess) { throw 'Use 64-bit Windows PowerShell.' }
$icon = (Resolve-Path -LiteralPath $IconPath).Path
if ([IO.Path]::GetExtension($icon) -ne '.ico') { throw 'Choose an .ico file.' }
Add-Type -AssemblyName System.Drawing
$check = New-Object System.Drawing.Icon($icon)
$check.Dispose()
$package = Get-AppxPackage -Name AppleInc.AppleMusicWin | Select-Object -First 1
if (-not $package) { throw 'Install Apple Music from Microsoft Store first.' }
$state = Join-Path $PSScriptRoot 'state'
New-Item -ItemType Directory -Path $state -Force | Out-Null
$stop = Join-Path $state 'stop'
# A previous source/EXE installation can be running from another folder.
$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$oldTask = Get-ScheduledTask -TaskName "AppleMusic-RedIcon-$sid" -ErrorAction SilentlyContinue
if ($oldTask -and $oldTask.Actions.Count -eq 1) {
    $oldRoot = $oldTask.Actions[0].WorkingDirectory
    if ($oldRoot -and $oldRoot -ne $PSScriptRoot) {
        $oldScript = Join-Path $oldRoot 'Watch-Icon.ps1'
        $expectedArguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $oldScript + '"'
        $wrapperArguments = '"' + (Join-Path $oldRoot 'RunHidden.vbs') + '"'
        $arguments = $oldTask.Actions[0].Arguments
        if (($arguments -eq $expectedArguments -or $arguments -eq $wrapperArguments) -and
            (Test-Path -LiteralPath $oldScript) -and
            (Test-Path -LiteralPath (Join-Path $oldRoot 'state') -PathType Container)) {
            New-Item -ItemType File -Path (Join-Path $oldRoot 'state\stop') -Force | Out-Null
        }
    }
}
# Stop a v0.1 login watcher or an existing companion before updating its config.
New-Item -ItemType File -Path $stop -Force | Out-Null
$existing = New-Object System.Threading.Mutex($false, 'Local\AppleMusicRedIconOpenSource')
$held = $false
try {
    try { $held = $existing.WaitOne(10000) } catch [System.Threading.AbandonedMutexException] { $held = $true }
    if (-not $held) { throw 'Existing icon helper did not stop. Close Apple Music and retry.' }
    Remove-Item -LiteralPath $stop
} finally {
    if ($held) { $existing.ReleaseMutex() }
    $existing.Dispose()
}
@{IconPath=$icon;AppId="$($package.PackageFamilyName)!App"} | ConvertTo-Json |
    Set-Content -LiteralPath (Join-Path $state 'config.json') -Encoding UTF8
$taskName = & (Join-Path $PSScriptRoot 'Register-Companion.ps1')
$oldLink = Join-Path ([Environment]::GetFolderPath('Startup')) 'AppleMusic Red Icon OSS.lnk'
if (Test-Path -LiteralPath $oldLink) {
    $shell = New-Object -ComObject WScript.Shell
    if ($shell.CreateShortcut($oldLink).Arguments -like ('*' + (Join-Path $PSScriptRoot 'Watch-Icon.ps1') + '*')) {
        Remove-Item -LiteralPath $oldLink
    }
}
if (Get-Process AppleMusic -ErrorAction SilentlyContinue) { Start-ScheduledTask -TaskName $taskName }
Write-Host 'Installed: starts on Apple Music launch and exits when its process exits.'
Write-Host 'No login startup or always-running watcher. Keep this folder in place.'

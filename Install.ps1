param(
    [string]$IconPath = (Join-Path $PSScriptRoot 'assets\red.ico'),
    [switch]$StartWithWindows
)
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
if (Test-Path -LiteralPath $stop) { Remove-Item -LiteralPath $stop }
@{IconPath=$icon; AppId="$($package.PackageFamilyName)!App"} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $state 'config.json') -Encoding UTF8
$hostPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + (Join-Path $PSScriptRoot 'Watch-Icon.ps1') + '"'
if ($StartWithWindows) {
    $shell = New-Object -ComObject WScript.Shell
    $link = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Startup')) 'AppleMusic Red Icon OSS.lnk'))
    $link.TargetPath = $hostPath
    $link.Arguments = $arguments
    $link.WorkingDirectory = $PSScriptRoot
    $link.WindowStyle = 7
    $link.Save()
}
Start-Process -FilePath $hostPath -WindowStyle Hidden -ArgumentList $arguments
Write-Host 'Enabled. Open Apple Music; the icon should change within three seconds.'
Write-Host 'Keep this folder in place. Run Uninstall.ps1 to disable.'

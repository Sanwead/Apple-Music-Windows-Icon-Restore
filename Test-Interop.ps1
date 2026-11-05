$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'Taskbar.cs')
$form = New-Object System.Windows.Forms.Form
try {
    $hwnd = $form.Handle.ToInt64()
    $iconPath = Join-Path $PSScriptRoot 'assets\red.ico'
    $icon = New-Object System.Drawing.Icon($iconPath)
    $icon.Dispose()
    [MusicTaskbar]::SetWindowIcons($hwnd, $iconPath)
    $values = @{2='test-command';3="$iconPath,0";4='Test Music';5='Local.AppleMusic.RedIcon.Test'}
    foreach ($key in @(2,3,4,5)) {
        [MusicTaskbar]::Write($hwnd, $key, $values[$key])
        if ([MusicTaskbar]::Read($hwnd, $key) -ne $values[$key]) { throw "Property $key did not round-trip." }
    }
    foreach ($key in @(2,3,4,5)) {
        [MusicTaskbar]::Write($hwnd, $key, [NullString]::Value)
        if ([MusicTaskbar]::Read($hwnd, $key) -ne '[vt=0]') { throw "Property $key was not cleared." }
    }
    Write-Host 'PASS: icon loading, C# compilation, window property writes and clearing.'
} finally { $form.Dispose() }

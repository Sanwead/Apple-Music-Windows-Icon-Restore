param([string]$OutputDirectory = (Join-Path $PSScriptRoot '..\dist'))
$ErrorActionPreference='Stop'
$root = Split-Path $PSScriptRoot -Parent
$out = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $out -Force | Out-Null
$compiler = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path -LiteralPath $compiler)) { throw '.NET Framework 4.x C# compiler is required.' }
$references = @('/r:System.Windows.Forms.dll','/r:System.Drawing.dll','/r:System.IO.Compression.dll','/r:System.IO.Compression.FileSystem.dll')
& $compiler /nologo /target:winexe /platform:x64 /optimize+ /define:UNINSTALL "/out:$out\uninstall.exe" @references "$PSScriptRoot\Bootstrap.cs"
if ($LASTEXITCODE -ne 0) { throw 'Uninstaller compilation failed.' }
Add-Type -AssemblyName System.IO.Compression
$payload = Join-Path $out 'payload.zip'
if (Test-Path -LiteralPath $payload) { Remove-Item -LiteralPath $payload }
$stream = [IO.File]::Create($payload)
$zip = New-Object IO.Compression.ZipArchive($stream,[IO.Compression.ZipArchiveMode]::Create)
try {
    $files = @('Install.ps1','Uninstall.ps1','Register-Companion.ps1','Watch-Icon.ps1','Taskbar.cs','assets/red.ico','LICENSE','NOTICE.md','THIRD_PARTY_NOTICES.md','README.md','README.zh-CN.md','uninstall.exe')
    foreach ($name in $files) {
        $source = if ($name -eq 'uninstall.exe') { Join-Path $out $name } else { Join-Path $root $name }
        $entry = $zip.CreateEntry($name,[IO.Compression.CompressionLevel]::Optimal)
        $input = [IO.File]::OpenRead($source)
        $output = $entry.Open()
        try { $input.CopyTo($output) } finally { $output.Dispose(); $input.Dispose() }
    }
} finally { $zip.Dispose(); $stream.Dispose() }
& $compiler /nologo /target:winexe /platform:x64 /optimize+ "/out:$out\install.exe" "/resource:$payload,payload.zip" @references "$PSScriptRoot\Bootstrap.cs"
if ($LASTEXITCODE -ne 0) { throw 'Installer compilation failed.' }
Remove-Item -LiteralPath $payload
Get-ChildItem -LiteralPath $out -Filter *.exe | Get-FileHash -Algorithm SHA256 | ForEach-Object { "$($_.Hash.ToLowerInvariant())  $([IO.Path]::GetFileName($_.Path))" } | Set-Content -LiteralPath (Join-Path $out 'SHA256SUMS.txt') -Encoding ASCII
Get-ChildItem -LiteralPath $out | Select-Object Name,Length

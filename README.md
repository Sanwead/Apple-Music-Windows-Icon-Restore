# Apple Music Windows Icon Restore

Bring the familiar red taskbar icon back to Apple Music on Windows.

The companion starts when you open Apple Music and exits with its process.
Apple Music stays installed in its original location as the official Store app.

[简体中文](README.zh-CN.md)

## Install

Download **install.exe** from [Releases](https://github.com/Sanwead/Apple-Music-Windows-Icon-Restore/releases/latest),
run it, and choose a dedicated folder. Then open Apple Music normally.

Requires 64-bit Windows, built-in .NET Framework 4.x and Windows PowerShell 5.1.
Tested on Windows 11 x64 with Apple Music package 1.1792.39682.0.
Release executables are unsigned, so Windows download prompts may show an unknown publisher.

Keep the tool's folder in place. Your account, library and playback stay in Apple Music.

Alternatively, download the source and run **Install.cmd**. For a custom icon:

```powershell
.\Install.ps1 -IconPath "C:\path\custom.ico"
```

## How it runs

A Windows scheduled task receives Apple Music's launch event and starts a hidden
PowerShell companion, which sets the running window's icon. No companion is running
while Apple Music is closed. If Apple Music keeps running after you close its window,
the companion stays until that process exits.

The running taskbar and thumbnail icons change; Start and desktop shortcut artwork stay as provided by Apple.

## Updates

Update Apple Music normally through the Microsoft Store. The companion resolves its
current installation folder at each launch. Reopen Apple Music after an update.
Changes to the startup event or window behavior may require an update to this tool.

To update the companion, run the new **install.exe** and select its existing folder.

## Uninstall

Remove **Apple Music Red Icon** from Windows Installed Apps, or run **uninstall.exe**.
For a source installation, run **Uninstall.cmd**.

Reopen Apple Music to restore the default icon. Settings, logs and a running uninstaller
may remain in the tool folder; you can delete that folder afterward.

## Build

```powershell
.\packaging\Build-Release.ps1
```

The Windows .NET Framework C# compiler builds `dist/install.exe`, `dist/uninstall.exe`
and `dist/SHA256SUMS.txt`. Run `Test-Interop.ps1` to check window-property interop.

## Credits and license

The event-trigger design is adapted from [AMExclusive](https://github.com/AntiOblivionis/AMExclusive).
Project code is [MIT](LICENSE). See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)
for adapted code and [NOTICE.md](NOTICE.md) for the Apple icon artwork.

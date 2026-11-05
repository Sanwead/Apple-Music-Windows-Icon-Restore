# Apple Music Windows Icon Restore

Restore a recognizable red taskbar icon for the Microsoft Store version of
Apple Music while it is running.

[简体中文](README.zh-CN.md) · [MIT](LICENSE) · [Artwork notice](NOTICE.md)

## Requirements

- 64-bit Windows and Windows PowerShell 5.1, included in Windows.
- The official Microsoft Store Apple Music app.
- A permanent, writable folder for this project.

The runtime technique was verified on one Windows installation with Apple
Music 1.1792.39682.0. Other versions and pinned-button behavior are unverified.

## Install

Download and extract this repository, then open Windows PowerShell in its folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -StartWithWindows
```

Open Apple Music. Its icon should turn red within three seconds. Omit
`-StartWithWindows` to enable only for the current login session. You can add
`-IconPath "C:\path\custom.ico"` to use a different icon. Close and reopen
Apple Music after changing icons.

Keep this folder and the icon in place. To move them, uninstall first and
reinstall from the new location. No administrator rights, Python, or additional
downloads are needed.

## Disable

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall.ps1
```

Close and reopen Apple Music afterward to restore its original window icon.
Downloaded files and local configuration are left on disk.

The hidden helper checks for Apple Music every three seconds until disabled or
you sign out. It uses Windows PowerShell, so memory use is higher than a native
executable. Scripts are unsigned; managed devices may block them. The execution
policy argument only applies to the launched process and cannot override
organization policy.

## How it works

Changing `WM_SETICON` alone can change the thumbnail icon while leaving the
taskbar button white. This tool also sets the window's explicit AppUserModelID,
`System.AppUserModel.RelaunchIconResource`, relaunch command and display name.
The custom identity may affect taskbar grouping and jump lists. Existing pinned
shortcuts, Start menu entries and desktop icons are outside its scope.

- [Microsoft: RelaunchIconResource](https://learn.microsoft.com/en-us/windows/win32/properties/props-system-appusermodel-relaunchiconresource)
- [Microsoft: application user model IDs](https://learn.microsoft.com/en-us/windows/win32/shell/appids)

The helper does not edit the app package, change WindowsApps permissions,
patch the executable, inject code, or collect account/listening data. It has
no network operations. Windows or Apple Music updates may require adjustments.

Run `powershell.exe -NoProfile -File .\Test-Interop.ps1` to compile the interop
code and check window property writes on a temporary hidden test window.

## License

Code and documentation: MIT, copyright 2026 Sanwead. Apple artwork and
trademarks are excluded from the MIT grant; see [NOTICE.md](NOTICE.md).
This unofficial project is not endorsed by Apple.

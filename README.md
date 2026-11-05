# Apple Music Windows Icon Restore

Restore the red taskbar icon for the official Microsoft Store Apple Music app.
The companion starts when Apple Music launches and exits when its process exits.
There is no login startup, always-running watcher, DLL injection, or app repackaging.

[简体中文](README.zh-CN.md) · [MIT](LICENSE) · [Artwork](NOTICE.md) · [Third-party notices](THIRD_PARTY_NOTICES.md)

## Install

1. Install the official Apple Music app from the Microsoft Store.
2. Download and extract this repository into a permanent writable folder.
3. Double-click **Install.cmd** under the account that uses Apple Music.
4. Open Apple Music normally from Start or your existing shortcut.

Requires 64-bit Windows and built-in Windows PowerShell 5.1. No Developer Mode,
Python, or administrator privileges are required on the tested configuration.
Managed devices may restrict scripts, task creation, or event-log access.

To use a custom icon, run from Windows PowerShell in the project folder:

```powershell
.\Install.ps1 -IconPath "C:\path\custom.ico"
```

Keep the tool and icon in place. To move them, uninstall first and reinstall
from the new location. On first install, an already-running Apple Music process
is handled immediately. The old `-StartWithWindows` option has been removed;
the installer removes its own legacy startup shortcut from this folder.

## Disable

Double-click **Uninstall.cmd**, then close and reopen Apple Music. This removes
the launch task and stops the companion; it does not uninstall Apple Music.
The downloaded files and local configuration remain on disk.

The companion stays alive only for its bound AppleMusic.exe process. Closing the
window may leave Apple Music running in the background; explicitly quit Apple
Music to end that process and the companion. A launch with no matching process
times out after 20 seconds. There is no separate login trigger or resident
process watching for future launches.

## How startup works

Windows Task Scheduler listens for `Microsoft-Windows-AppModel-Runtime/Admin`
event **201**, filtered to Apple Music's application identity and image name.
When that event arrives, it launches a hidden PowerShell companion for the current
user. The companion resolves the current registered package directory, verifies
the process path and desktop session, then binds to that exact process lifetime.
It sets `WM_SETICON` and the window's AppUserModelID/relaunch icon properties.
This changes the running taskbar and thumbnail icons, not Start or desktop artwork.

The event-trigger approach is adapted from [AMExclusive](https://github.com/AntiOblivionis/AMExclusive).
We do not inject its DLLs or use its audio modifications. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

The helper does not edit Apple's installed files, take WindowsApps ownership,
enable Developer Mode, or re-register Apple Music. It does not collect account
or listening data and has no network operations. Local diagnostics in `state/`
are excluded from Git. Windows PowerShell uses more memory than a native helper.
Scripts are unsigned and may be blocked on managed devices. The launcher's
execution policy setting applies only to its process, not to machine policy.

## Updates and limitations

Apple Music remains the official Store installation, so this tool does not replace
its normal update mechanism. The package path is looked up at each launch, so a
new version's directory is not hardcoded. Close and reopen Apple Music after an
update; if Windows keeps the same startup event and window behavior, the icon
should be applied again without reinstalling this tool.

This is not a promise of compatibility with every future update. Changes to
the event, app identity, window structure, or permissions can require a tool
update. Pinned-button behavior, taskbar grouping and jump lists can differ
because a custom runtime identity is used. Start menu and desktop icons are
outside this tool's scope. Other Windows versions and ARM64 are unverified.

To migrate from a previously repackaged/development install, restore the official
Store app first. This installer deliberately does not remove or reinstall music
apps or modify their data.

## Verification

```powershell
powershell.exe -NoProfile -File .\Test-Interop.ps1
```

This checks icon loading, interop compilation, and property write/clear behavior
on a temporary hidden test window. Task lifecycle and visible taskbar behavior
need Windows integration checks; a passing interop test alone does not prove them.

## License

Project code and documentation: MIT, copyright 2026 Sanwead. Adapted AMExclusive
code retains its MIT notice. Apple artwork and trademarks are excluded from the
MIT grant; see [NOTICE.md](NOTICE.md). This unofficial project is not endorsed by Apple.

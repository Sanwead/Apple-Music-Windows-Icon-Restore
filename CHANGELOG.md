# Changes

## 0.3.1

- Fix the brief PowerShell window flash when Apple Music launches (PR #2).
- Include the hidden launcher in the installer and track its exit with Apple Music.

## 0.3.0

- Add standalone install.exe and uninstall.exe, plus an Installed Apps entry.
- Support upgrades from the script companion to a dedicated EXE installation.
- Add a local Windows build script and release checksums.
- Shorten the English and Chinese setup instructions.

## 0.2.0

- Start the companion from Apple Music's AppModel launch event instead of login.
- Exit with the bound Apple Music process; verify executable path and session.
- Resolve the registered package path on each launch for Store version changes.
- Add CMD installation and removal entry points.
- Keep the official installation untouched; no DLL injection or Developer Mode.
- Credit the AMExclusive event-trigger design under MIT.

Integration checks on Windows 11 x64 / Store package 1.1792.39682.0 verified two
automatic launches, a user-confirmed red taskbar icon, and zero companion
processes after the host exited. Interop property write/clear tests also passed.
Future Windows/Apple Music versions and ARM64 remain unverified.

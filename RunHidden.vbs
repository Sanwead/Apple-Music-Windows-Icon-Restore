Option Explicit
Dim shell, folder, powershell, command
Set shell = CreateObject("WScript.Shell")
folder = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
powershell = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
command = """" & powershell & """ -NoProfile -ExecutionPolicy Bypass -File """ & folder & "\Watch-Icon.ps1"""
WScript.Quit shell.Run(command, 0, True)

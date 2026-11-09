# Event subscription and task policy adapted from AMExclusive (MIT).
# Copyright (c) 2026 AMExclusive contributors. See THIRD_PARTY_NOTICES.md.
$ErrorActionPreference = 'Stop'
$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$taskName = "AppleMusic-RedIcon-$sid"
$service = New-Object -ComObject Schedule.Service
$service.Connect()
$folder = $service.GetFolder('\')
$task = $service.NewTask(0)
$task.RegistrationInfo.Description = 'Apply the red Apple Music icon only while Apple Music is running.'
$task.Principal.UserId = $sid
$task.Principal.LogonType = 3
$task.Principal.RunLevel = 0
$task.Settings.MultipleInstances = 3
$task.Settings.Hidden = $true
$task.Settings.DisallowStartIfOnBatteries = $false
$task.Settings.StopIfGoingOnBatteries = $false
$task.Settings.ExecutionTimeLimit = 'PT0S'
$task.Settings.StartWhenAvailable = $false
$trigger = $task.Triggers.Create(0)
$trigger.Enabled = $true
$trigger.Subscription = @'
<QueryList><Query Id="0" Path="Microsoft-Windows-AppModel-Runtime/Admin"><Select Path="Microsoft-Windows-AppModel-Runtime/Admin">*[System[Provider[@Name='Microsoft-Windows-AppModel-Runtime'] and EventID=201] and EventData[Data[@Name='ImageName']='AppleMusic.exe' and Data[@Name='ApplicationName']='AppleInc.AppleMusicWin_nzyj5cx40ttqa!App']]</Select></Query></QueryList>
'@
$vbsPath = Join-Path $PSScriptRoot 'RunHidden.vbs'
$action = $task.Actions.Create(0)
$action.Path = "$env:SystemRoot\System32\wscript.exe"
$action.Arguments = "`"$vbsPath`""
$action.WorkingDirectory = $PSScriptRoot
$null = $folder.RegisterTaskDefinition($taskName, $task, 6, $sid, $null, 3, $null)
$registered = $folder.GetTask($taskName)
$definition = $registered.Definition
$principalSid = $definition.Principal.UserId
if ($principalSid -notmatch '^S-1-') {
    $principalSid = (New-Object Security.Principal.NTAccount($principalSid)).Translate(
        [Security.Principal.SecurityIdentifier]).Value
}
if (-not $registered.Enabled -or $definition.Triggers.Count -ne 1 -or
    $definition.Triggers.Item(1).Type -ne 0 -or -not $definition.Triggers.Item(1).Enabled -or
    ([xml]$definition.Triggers.Item(1).Subscription).OuterXml -ne ([xml]$trigger.Subscription).OuterXml -or
    $definition.Actions.Count -ne 1 -or $definition.Actions.Item(1).Path -ne $action.Path -or
    $definition.Actions.Item(1).Arguments -ne $action.Arguments -or
    $definition.Actions.Item(1).WorkingDirectory -ne $PSScriptRoot -or
    $principalSid -ne $sid -or $definition.Settings.ExecutionTimeLimit -ne 'PT0S' -or
    $definition.Principal.RunLevel -ne 0 -or $definition.Principal.LogonType -ne 3 -or
    $definition.Settings.MultipleInstances -ne 3) {
    throw 'Companion task registration did not match the requested configuration.'
}
$taskName

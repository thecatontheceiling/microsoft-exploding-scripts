@echo off

>nul fltmc || (
echo Right click on this script and run as admin.
pause
exit
)

mode 120, 1000
if exist "%~dp0results.txt" del /f /q "%~dp0results.txt"
powershell "$f=[io.file]::ReadAllText('%~f0') -split ':xrm\:.*';iex ($f[1])" >>"%~dp0results.txt"
pause
exit /b

:xrm:
$taskNames = @('SvcRestartTask', 'SvcRestartTaskLogon', 'SvcRestartTaskNetwork')
foreach ($name in $taskNames) {
    $task = Get-ScheduledTask | Where-Object { $_.TaskName -eq $name -and $_.TaskPath -eq '\Microsoft\Windows\SoftwareProtectionPlatform\' }
    $Info = $task | Get-ScheduledTaskInfo

    Write-Host "Name: $name"
    Write-Host "State: $($task.State)"
    Write-Host "NextRunTime: $($info.NextRunTime)"
    Write-Host "LastRunTime: $($info.LastRunTime)"
    Write-Host "LastTaskResult: $($info.LastTaskResult)"
    Write-Host "NumberOfMissedRuns: $($info.NumberOfMissedRuns)"
    Write-Host "-----------------------------"
}

# Define the log name
$LogName = "Application"

# Get the events
$Events = Get-WinEvent -FilterHashtable @{LogName=$LogName}

# SPP error and 16384 events
# $FilteredEvents = $Events | Where-Object { ($_.ProviderName -like "*SPP*" -and $_.Level -eq 2) -or $_.Id -eq 16384 -or $_.Id -eq 8230} | Select-Object -First 10

# All SPP events
# $FilteredEvents = $Events | Where-Object { $_.ProviderName -like "*SPP*" } | Select-Object -First 10
$FilteredEvents = $Events | Where-Object { $_.ProviderName -like "*SPP*" }

# Display the filtered events
foreach ($Event in $FilteredEvents) {
    Write-Output "Time Created: $($Event.TimeCreated)"
    Write-Output "Provider Name: $($Event.ProviderName)"
    Write-Output "Id: $($Event.Id)"
    $MessageLines = $Event.Message -split "`n" | Select-Object -First 4
    Write-Output "Message: $($MessageLines -join "`n")"
    Write-Output "----------------------------------------"
}

:xrm:

<#
.SYNOPSIS
    Keeps computer awake
.DESCRIPTION
    Author: Trond Stien
    Version: 1.0
    Creation Date: 01.01.2020

    Script to keep computer awake and prevent going into "away" mode by sending scroll lock every 120 seconds. 
    Useful for keeping test-machines awake.
    
.EXAMPLE
    ./keepalive.ps1

.EXAMPLE
	# if you want to transcript (for whatever reason)
    ./keepalive.ps1 -transcript

.NOTES
    Will also prevent teams from setting user to "away" mode.
#>

[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript
)

#region VARIABLES ########################################################### - VARIABLES
#endregion /VARIABLES ####################################################### - /VARIABLES

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="TEMPNAME"
    $StartTime=get-date -format o
    #Starts transcript of script
    Start-Transcript "$($env:TEMP)\$ScriptName.ps1_log.txt" -Force -Append
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    Write-host "------------------------- Script Start ----------------------------" -ForegroundColor cyan
    Write-host "--- Script started at `'$StartTime`'" -ForegroundColor cyan
}

#region FUNCTIONS ########################################################### - FUNCTIONS
#endregion /FUNCTIONS ####################################################### - /FUNCTIONS

#region SCRIPT ############################################################## - SCRIPT
Clear-Host
Write-output "Aaah, some fresh coffee!"
Write-output "*fills cup*"
$WShell = New-Object -com "Wscript.Shell"

while ($true)
{
	Write-output "*takes a sip*"
	Write-output "Damn good coffee!"
	$Sipcount=0
	while ($sipcount -le 10){
		$WShell.sendkeys("{SCROLLLOCK}")
		Start-Sleep -Milliseconds 100
		$WShell.sendkeys("{SCROLLLOCK}")
		Start-Sleep -Seconds 120
        Write-output "*takes another sip*"
		$sipcount=$sipcount + 1
	}
	Write-output "*refills cup*"
}
#endregion /SCRIPT ########################################################## - /SCRIPT

if ($transcript -eq $true){
    $EndTime=get-date -format o
    Write-Host
    Write-host "--- Script ended at `'$EndTime`'" -ForegroundColor cyan
    Write-host "------------------------- Script Done -----------------------------" -ForegroundColor cyan
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    write-host
    Stop-transcript
}

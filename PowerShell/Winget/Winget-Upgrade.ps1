<#
.SYNOPSIS
    Upgrades using winget
.DESCRIPTION
    Upgrades using winget

.EXAMPLE
    ./winget-upgrade.ps1

.EXAMPLE
    ./winget-upgrades.ps1 -PauseOnEnd

.NOTES
    Literally just calls winget upgrade --all, not a lot more to it than that

#>
#region REQUIREMENTS ######################################################### - REQUIREMENTS
# Contains list of #requires. see "about_requires" within Microsoft documentation
#endregion REQUIREMENTS ###################################################### - /REQUIREMENTS

#region PARAMETERS ########################################################### - PARAMETERS
[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [parameter(Mandatory=$false, HelpMessage="Determines to pause on end or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$PauseOnEnd
)
#endregion /PARAMETERS ####################################################### - /PARAMETERS

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="Winget-Upgrade"
    $StartTime=get-date -format o
    #Starts transcript of script
    Start-Transcript "$($env:TEMP)\$ScriptName.ps1_log.txt" -Force -Append
    Write-output "-------------------------------------------------------------------"
    Write-output "------------------------- Script Start ----------------------------"
    Write-output "--- Script started at `'$StartTime`'"
}

#region VARIABLES ########################################################### - VARIABLES
#endregion /VARIABLES ####################################################### - /VARIABLES

#region FUNCTIONS ########################################################### - FUNCTIONS
#endregion /FUNCTIONS ####################################################### - /FUNCTIONS

#region SCRIPT ############################################################## - SCRIPT
write-host "Performing a winget upgrade of all packages:" -ForegroundColor Yellow
write-host
winget upgrade --all --silent

write-host
write-host "upgrade --include-unknown:" -ForegroundColor Yellow
write-host
winget upgrade --all --include-unknown

if ($PauseOnEnd -eq $true){
    pause
}
#endregion /SCRIPT ########################################################## - /SCRIPT

if ($transcript -eq $true){
    $EndTime=get-date -format o
    Write-output ""
    Write-output "--- Script ended at `'$EndTime`'"
    Write-output "------------------------- Script Done -----------------------------"
    Write-output "-------------------------------------------------------------------"
    Write-output ""
    Stop-transcript
}
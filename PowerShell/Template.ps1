<#
.SYNOPSIS
    [SYNPOSIS]
.DESCRIPTION
    Author: TSLETSGO
    Version: [VERSIONNUMBER]

    [DESCRIPTION]

.EXAMPLE
    [INSERT EXAMPLE OF RUNNING]

.EXAMPLE
    [INSERT ANOTHER EXAMPLE OF RUNNING]

.NOTES
    [INSERT NOTE TEXTS - WHAT ONE NEEDS TO RUN PROPERLY]

#>
#region REQUIREMENTS ######################################################### - REQUIREMENTS
# Contains list of #requires. see "about_requires" within Microsoft documentation
#endregion REQUIREMENTS ###################################################### - /REQUIREMENTS

#region PARAMETERS ########################################################### - PARAMETERS
[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript
)
#endregion /PARAMETERS ####################################################### - /PARAMETERS

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="TEMPNAME"
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

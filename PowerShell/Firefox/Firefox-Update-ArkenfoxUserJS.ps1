<#
.SYNOPSIS
    Updates the user.js arkenfox profile on Windows with the provided updater.bat.

.DESCRIPTION
    Author: Trond Stien
    Version: 1.0
    Creation Date: 06.03.2021

    Updates the user.js arkenfox profile on windows with the provided updater.bat script without prompting user for input.
        for more information about the user.js, see https://github.com/arkenfox/user.js

.EXAMPLE
    ./Firefox-Update-ArkenfoxUserJS.ps1 -ProfileLocation "C:\Users\EXAMPLEUSER\AppData\Roaming\Mozilla\Firefox\Profiles"
    
.EXAMPLE
    # To run with transcript
    ./Firefox-Update-ArkenfoxUserJS.ps1 -ProfileLocation "C:\Users\EXAMPLEUSER\AppData\Roaming\Mozilla\Firefox\Profiles" -transcript

.NOTES
    Recommended to provide desired profile directory as parameter, if not it will default to user that is running script

#>

[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [parameter(Mandatory=$false, HelpMessage="Select your profiles location")]
    [ValidateNotNullOrEmpty()]
    [string]$ProfileLocation="$env:appdata\Mozilla\Firefox\Profiles"
)

#region VARIABLES ########################################################### - VARIABLES
#endregion /VARIABLES ####################################################### - /VARIABLES

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="Firefox-Update-ArkenfoxUserJS"
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
foreach ($folder in (Get-ChildItem $ProfileLocation -Directory)) {
    if ('updater.bat' -in (Get-ChildItem -Path $folder.FullName -File).Name) {
        $UpdaterLocation = $folder.FullName + "/" + "updater.bat"
        set-location $folder.FullName
        Invoke-Expression "cmd /c $UpdaterLocation -unattended -updateBatch -SingleBackup -log"
    }
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

<#
.SYNOPSIS
    Enable/disable oculus & VirtualDesktop services
.DESCRIPTION
    Author: TSLETSGO
    Version: 1.0

    Simple script for stopping/disabling or enabling/starting Oculus & virtual desktop services

.EXAMPLE
    ./Configure-OculusVRServices.ps1 -StartupType Enabled
    ./Configure-OculusVRServices.ps1 -StartupType Disabled

.NOTES
    Used to prevent Oculus services being enabled without any reason to be.
        - Suggest adding the oculus client to playnite, then adding the scripts in the scripts tab to enable the services on launch, disabling on shut-down
        - Then creating a shortcut from playnite (to replace original oculus shortcut) by right-clicking oculus within playnite -> Create desktop shortcut. 
        
        Put following in playnite scripts (change scriptlocation and startuptype as desired):
            $ScriptLocation = "<LOCATION>\Configure-OculusVRServices.ps1"

            # Enable and start VR services
            $StartupType = "Enabled"

            #Running script
            Invoke-Expression "powershell -executionpolicy bypass -command `"$ScriptLocation -StartupType $StartupType`""

#>

[cmdletbinding()]
param( 
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [Parameter(Mandatory=$true,  HelpMessage="Set startuptype to 'Disabled' or 'Enabled'")]
    [ValidateNotNullOrEmpty()]
    [String] $StartupType="Disabled"
)

#region VARIABLES ########################################################### - VARIABLES
#endregion /VARIABLES ####################################################### - /VARIABLES

if ($transcript -eq $true){
    #Defines name of script
    $ScriptName="Configure-OculusVRServices"
    $StartTime=get-date -format o
    #Starts transcript of script
    Start-Transcript "$($env:TEMP)\$ScriptName.ps1_log.txt" -Force -Append
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    Write-host "------------------------- Script Start ----------------------------" -ForegroundColor cyan
    Write-host "--- Script started at `'$StartTime`'" -ForegroundColor cyan
}

#region FUNCTIONS ########################################################### - FUNCTIONS
function CheckforRunningAsAdmin {
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        #Not running as admin
        return $false
    }
    else{
        #Running as admin
        return $true
    }
}
#endregion /FUNCTIONS ####################################################### - /FUNCTIONS

#region SCRIPT ############################################################## - SCRIPT
$checkforadmin = CheckforRunningAsAdmin
if ($checkforadmin -eq $false) {
        $CommandLine = "-ExecutionPolicy Bypass -File `"" + $($MyInvocation.MyCommand.Path) + "`" " + "-StartupType `"$StartupType`" "
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
}
else{
    $VirtualDesktopService = Get-Service | Where-Object {$_.DisplayName -like "Virtual Desktop*"}
    $OculusServices = Get-Service | Where-Object {$_.DisplayName -like "Oculus VR*"}
    $OVRService = Get-Service OVRService

    if ($StartupType -match "Enabled|Enable"){
        Set-Service -StartupType manual -name $OVRService.name
        Set-Service -StartupType manual -name $VirtualDesktopService.name
        # Start Oculus VR service
        Start-Service -Name $OVRService.Name
        # Start Virtual Desktop VR Service
        Start-Service -Name $VirtualDesktopService.Name
    }
    else {
        foreach ($OculusService in $OculusServices){
            Set-Service -StartupType Disabled -name $OculusService.name
            Stop-Service -name $OculusService.name
        }
        Set-Service -StartupType Disabled -name $VirtualDesktopService.name
        Stop-Service -name $VirtualDesktopService.name
    }
}
#endregion /SCRIPT  ######################################################### - SCRIPT


if ($transcript -eq $true){
    $EndTime=get-date -format o
    Write-Host
    Write-host "--- Script ended at `'$EndTime`'" -ForegroundColor cyan
    Write-host "------------------------- Script Done -----------------------------" -ForegroundColor cyan
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    write-host
    Stop-transcript
}

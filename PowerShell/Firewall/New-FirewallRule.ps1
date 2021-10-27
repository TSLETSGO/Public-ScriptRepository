<#
.SYNOPSIS
    Blocks inbound or outbound traffic to a file using firewall.
.DESCRIPTION
    Author: TSLETSGO
    Version: 1.0

    Blocks a file either or a folders DLL+EXE files from inbound or outbound traffic. Requires elevation unless UAC turned off.
.EXAMPLE
    New-Firewallrule.sp1 -Direction outbound -BlockFileLocation "C:\Test\blockme.exe"
    New-Firewallrule.sp1 -Direction outbound -BlockFileLocation "C:\Test"
.EXAMPLE
    New-Firewallrule.sp1 -Direction inbound -BlockFileLocation "C:\Test\blockme.exe"
    New-Firewallrule.sp1 -Direction inbound -BlockFileLocation "C:\Test"
.NOTES
    NAME: New-FirewallRule
#>

[cmdletbinding()]   
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [parameter(Mandatory=$true, HelpMessage="Inbound or Outbound rule")]
    [ValidateNotNullOrEmpty()]
    [string]$Direction,
    [parameter(Mandatory=$true, HelpMessage="Location of EXE file to be blocked")]
    [ValidateNotNullOrEmpty()]
    [string]$BlockFileLocation,
    [parameter(Mandatory=$false, HelpMessage="Parameter to skip confirm prompt")]
    [ValidateNotNullOrEmpty()]
    [string]$ConfirmPrompt
)

#region VARIABLES ########################################################### - VARIABLES
#endregion /VARIABLES ####################################################### - /VARIABLES

if ($transcript -eq $true){
    #Defines name of script
    $ScriptName="New-FirewallRule"
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
#print parameters for log purposes
write-host "$Direction"
write-host "$BlockFileLocation"
write-host "Checking if `'$BlockFileLocation`' is a directory"
if (Test-Path -Path $BlockFileLocation -PathType Container){
    write-host "`'$BlockFileLocation`' is a directory"
    if (!($ConfirmPrompt -match "yes|y")){
        $ConfirmPrompt = read-host = "Are you sure you want to block `'$Direction`' traffic for all DLL and EXE files in `'$BlockFileLocation'`?"
    }
    if ($ConfirmPrompt -match "yes|y"){
        write-host "you chose 'Yes'"
        $checkforadmin = CheckforRunningAsAdmin
        if ($checkforadmin -eq $false) {
            $CommandLine = "-ExecutionPolicy Bypass -File `"" + $($MyInvocation.MyCommand.Path) + "`" " + "-Direction `"$Direction`" " + "-BlockFileLocation `"$BlockFileLocation`" " + "-ConfirmPrompt `"$ConfirmPrompt`" "
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            Exit
        }
        else{
            $AllDLLFiles = Get-ChildItem -path "$BlockFileLocation" -Recurse -Filter "*.dll" | select-object FullName
            $AllEXEFiles = Get-ChildItem -path "$BlockFileLocation" -Recurse -Filter "*.exe" | select-object FullName
            $ExistingInboundFirewallRules = Get-NetFirewallRule -direction Inbound | Select-Object DisplayName,Direction
            $ExistingOutboundFirewallRules = Get-NetFirewallRule -direction Outbound | Select-Object DisplayName,Direction

            #Process DLL files
            foreach ($DLL in $AllDLLFiles){
                write-host "Checking if rule already exists"
                if ($Direction -eq "Inbound"){
                    if ($($ExistingInboundFirewallRules.DisplayName) -contains "Block - $($DLL.FullName)"){
                        write-host "Already exist within outbound firewall rules"
                    }
                    else{
                        write-host "blocking $Direction traffic for `'$($DLL.Fullname)`'"
                        New-NetFirewallRule -Program "$($DLL.Fullname)" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $($DLL.Fullname)" -Description "Block all DLL in $BlockFileLocation" -Direction "$Direction"
                    }
                }
                elseif ($Direction -eq "Outbound"){
                    if ($($ExistingOutboundFirewallRules.DisplayName) -contains "Block - $($DLL.FullName)"){
                        write-host "Already exist within inbound firewall rules"
                    }
                    else{
                        write-host "blocking $Direction traffic for `'$($DLL.Fullname)`'"
                        New-NetFirewallRule -Program "$($DLL.Fullname)" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $($DLL.Fullname)" -Description "Block all DLL in $BlockFileLocation" -Direction "$Direction"
                    }
                }
            }

            #Process EXE files
            foreach ($EXE in $AllEXEFiles){
                write-host "Checking if rule already exists"
                if ($Direction -eq "Inbound"){
                    if ($($ExistingInboundFirewallRules.DisplayName) -contains "Block - $($EXE.FullName)"){
                        write-host "Already exist within outbound firewall rules"
                    }
                    else{
                        write-host "blocking $Direction traffic for `'$($EXE.Fullname)`'"
                        New-NetFirewallRule -Program "$($EXE.Fullname)" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $($EXE.Fullname)" -Description "Block all DLL in $BlockFileLocation" -Direction "$Direction"
                    }
                }
                elseif ($Direction -eq "Outbound"){
                    if ($($ExistingOutboundFirewallRules.DisplayName) -contains "Block - $($EXE.FullName)"){
                        write-host "Already exist within inbound firewall rules"
                    }
                    else{
                        write-host "blocking $Direction traffic for `'$($EXE.Fullname)`'"
                        New-NetFirewallRule -Program "$($EXE.Fullname)" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $($EXE.Fullname)" -Description "Block all DLL in $BlockFileLocation" -Direction "$Direction"
                    }
                }
            }
        }
    }
    else{
       write-host "you chose to 'No'"
    }
}
else{
    $checkforadmin = CheckforRunningAsAdmin 
    # Self-elevate the script if required
    if ($checkforadmin -eq $false) {
        $CommandLine = "-ExecutionPolicy Bypass -File `"" + $($MyInvocation.MyCommand.Path) + "`" " + "-Direction `"$Direction`" " + "-BlockFileLocation `"$BlockFileLocation`" "
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        exit
    }
    else{
        #Retrieve existing firewall rules
        $ExistingInboundFirewallRules = Get-NetFirewallRule -direction Inbound | Select-Object DisplayName,Direction
        $ExistingOutboundFirewallRules = Get-NetFirewallRule -direction Outbound | Select-Object DisplayName,Direction
        write-host "$Direction"

        write-host "Checking if rule already exists"
        if ($Direction -eq "inbound"){
            if ($($ExistingInboundFirewallRules.DisplayName) -contains "Block - $BlockFileLocation"){
                write-host "Already exist within outbound firewall rules"
            }
            else{
                write-host "blocking $Direction traffic for `'$BlockFileLocation`'"
                New-NetFirewallRule -Program "$BlockFileLocation" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $BlockFileLocation" -Description "Block $BlockFileLocation" -Direction "$Direction"
            }
        }
        elseif ($Direction -eq "outbound"){
            if ($($ExistingOutboundFirewallRules.DisplayName) -contains "Block - $BlockFileLocation"){
                write-host "Already exist within inbound firewall rules"
            }
            else{
                write-host "blocking $Direction traffic for `'$BlockFileLocation`'"
                New-NetFirewallRule -Program "$BlockFileLocation" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $BlockFileLocation" -Description "Block $BlockFileLocation" -Direction "$Direction"
            }
        }
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

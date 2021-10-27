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
$ExecutableArray = @("*.0XE","*.73K","*.89K","*.A6P","*.AC","*.ACC","*.ACR","*.ACTION","*.ACTM","*.AHK","*.AIR","*.APK","*.APP","*.APP","*.ARSCRIPT","*.AS","*.ASB","*.AWK","*.AZW2","*.BAT","*.BEAM","*.BIN","*.BTM","*.CEL","*.CELX","*.CHM","*.CMD","*.COF","*.COM","*.COMMAND","*.CPL","*.CRT","*.CSH","*.DEK","*.DLD", "*.DLL","*.DMC","*.DOCM","*.DOTM","*.DXL","*.EAR","*.EBM","*.EBS","*.EBS2","*.ECF","*.EHAM","*.ELF","*.ES","*.EX4","*.EXE","*.EXOPC","*.EZS","*.FAS","*.FKY","*.FPI","*.FRS","*.FXP","*.GADGET","*.GS","*.HAM","*.HMS","*.HPF","*.HTA","*.IIM","*.INF1","*.INS","*.INX","*.IPA","*.IPF","*.ISP","*.ISU","*.JAR","*.JOB","*.JS","*.JSE","*.JSX","*.KIX","*.KSH","*.LNK","*.LO","*.LS","*.MAM","*.MCR","*.MEL","*.MPX","*.MRC","*.MS","*.MS","*.MSC","*.MSI","*.MSP","*.MST","*.MXE","*.NEXE","*.OBS","*.ORE","*.OSX","*.OTM","*.OUT","*.PAF","*.PEX","*.PIF","*.PLX","*.POTM","*.PPAM","*.PPSM","*.PPTM","*.PRC","*.PRG","*.PS1","*.PVD","*.PWC","*.PYC","*.PYO","*.QPX","*.RBX","*.REG","*.RGS","*.ROX","*.RPJ","*.RUN","*.S2A","*.SBS","*.SCA","*.SCAR","*.SCB","*.SCR","*.SCRIPT","*.SCT","*.SHB","*.SHS","*.SMM","*.SPR","*.TCP","*.THM","*.TLB","*.TMS","*.U3P","*.UDF","*.UPX","*.URL","*.VB","*.VBE","*.VBS","*.VBSCRIPT","*.VLX","*.VPM","*.WCM","*.WIDGET","*.WIZ","*.WORKFLOW","*.WPK","*.WPM","*.WS","*.WSF","*.WSH","*.XAP","*.XBAP","*.XLAM","*.XLM","*.XLSM","*.XLTM","*.XQT","*.XYS","*.ZL9")
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
        if ($checkforadmin -eq $false){
            $CommandLine = "-ExecutionPolicy Bypass -File `"" + $($MyInvocation.MyCommand.Path) + "`" " + "-Direction `"$Direction`" " + "-BlockFileLocation `"$BlockFileLocation`" " + "-ConfirmPrompt `"$ConfirmPrompt`" "
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            Exit
        }
        else{
            $AllFiles = Get-ChildItem -path "$BlockFileLocation" -Recurse -include $ExecutableArray | select-object FullName
            $ExistingInboundFirewallRules = Get-NetFirewallRule -direction Inbound | Select-Object DisplayName,Direction
            $ExistingOutboundFirewallRules = Get-NetFirewallRule -direction Outbound | Select-Object DisplayName,Direction

            #Process DLL files
            foreach ($File in $AllFiles){
                write-host "Checking if rule already exists"
                if ($Direction -eq "Inbound"){
                    if ($($ExistingInboundFirewallRules.DisplayName) -contains "Block - $($File.FullName)"){
                        write-host "Already exist within outbound firewall rules"
                    }
                    else{
                        write-host "blocking $Direction traffic for `'$($File.Fullname)`'"
                        New-NetFirewallRule -Program "$($File.Fullname)" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $($File.Fullname)" -Description "Block all executable-files in $BlockFileLocation" -Direction "$Direction"
                    }
                }
                elseif ($Direction -eq "Outbound"){
                    if ($($ExistingOutboundFirewallRules.DisplayName) -contains "Block - $($File.FullName)"){
                        write-host "Already exist within inbound firewall rules"
                    }
                    else{
                        write-host "blocking $Direction traffic for `'$($File.Fullname)`'"
                        New-NetFirewallRule -Program "$($File.Fullname)" -Group "Custom" -Action "Block" -Profile "Domain, Private, Public" -DisplayName "Block - $($File.Fullname)" -Description "Block all executable-files in $BlockFileLocation" -Direction "$Direction"
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

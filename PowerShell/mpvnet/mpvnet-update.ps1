<#
.SYNOPSIS
    Updates mpvnet
.DESCRIPTION
    Author: TSLETSGO
    Version: 1.0

    Updates mpvnet using a modified version of the MPV update script

.EXAMPLE
    ./mpvnet-update.ps1
    
.EXAMPLE
    # if you want to transcript shell output
    ./mpvnet-update.ps1 -transcript

.NOTES
    Remember to provide the parameters to fit your environment.

    Recommended to run in a scheduled task for automation purposes

#>

[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [parameter(Mandatory=$false, HelpMessage="Temp folder for downloading the installation and update files")]
    [ValidateNotNullOrEmpty()]
    [string]$Downloadfolder="$env:userprofile\downloads",
    [parameter(Mandatory=$false, HelpMessage="Folder where mpvnet.exe is located")]
    [ValidateNotNullOrEmpty()]
    [string]$mpvnetloc="C:\Program Files\mpv.net",
    [parameter(Mandatory=$false, HelpMessage="Folder where 7-zip is located")]
    [ValidateNotNullOrEmpty()]
    [string]$7ZipLocation="C:\Program Files\7-Zip"
)

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="mpvnet-update"
    $StartTime=get-date -format o
    #Starts transcript of script
    Start-Transcript "$($env:TEMP)\$ScriptName.ps1_log.txt" -Force -Append
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    Write-host "------------------------- Script Start ----------------------------" -ForegroundColor cyan
    Write-host "--- Script started at `'$StartTime`'" -ForegroundColor cyan
}

#region VARIABLES ########################################################### - VARIABLES
#endregion /VARIABLES ####################################################### - /VARIABLES

#region FUNCTIONS ########################################################### - FUNCTIONS

function Read-PowershellVersion {
    $version = $PSVersionTable.PSVersion.Major
    Write-Host "Reading Windows PowerShell version -- $version" -ForegroundColor Green
    if ($version -le 2)
    {
        Write-Host "Using Windows PowerShell $version is unsupported. Update your Windows PowerShell." -ForegroundColor Red
        throw
    }
}

function find-mpvnet {
    $mpvnet = "$($mpvnetloc)\mpvnet.exe"
    $is_exist = Test-Path $mpvnet
    return $is_exist
    write-host "does mpvnet exist? `'$($mpvnetloc)\mpvnet.exe`'"
}

function Find-7z {
    if (-not (Test-Path ($7ZipLocation + "\7z.exe")))
    {
        write-host "7-zip not installed at $7ZipLocation" -ForegroundColor Red
    }
    else
    {
        Write-Host "7z exist at $7ZipLocation" -ForegroundColor Green
    }
}

function Get-mpvnet ($version) {
    Write-Host "Downloading mpvnet ($version)" -ForegroundColor Green
    $global:progressPreference = 'Continue'
    $versionnumber = $version -replace 'v',''
    $link = "https://github.com/stax76/mpv.net/releases/download/"  + $version + "/mpv.net-" + $versionnumber + ".zip"
    Invoke-WebRequest -Uri $link -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -OutFile "$($Downloadfolder)\mpv.net-$versionnumber.zip"
}

function Get-Latest-mpvnet {
    $link = "https://github.com/stax76/mpv.net/releases/latest"
    Write-Host "Fetching RSS feed for mpvnet" -ForegroundColor Green
    $global:progressPreference = 'silentlyContinue'
    $resp = Invoke-WebRequest $link -MaximumRedirection 0 -ErrorAction Ignore -UseBasicParsing
    $redirect_link = $resp.Headers.Location
    $version = $redirect_link.split("/")[7]
    write-host "Newest version is `'$version`'"
    return $version
}

function Expand-zipfile ($version) {
    $7zipexecutable = $7ZipLocation + "\7z.exe"
    & $7zipexecutable e "$($Downloadfolder)\mpv.net-$($version -replace 'v','').zip" -o"$mpvnetloc" -y
}

function Test-Admin{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Update-mpvnet {
    write-host "Checking if update is necessary"
    $need_download = $false
    $latest_release = Get-Latest-mpvnet
    $local_version_release = Get-ItemProperty "$($mpvnetloc)\mpvnet.exe"
    write-host "local version is $($local_version_release.VersionInfo.FileVersion)"
    if (find-mpvnet) {
        if (($local_version_release.VersionInfo.FileVersion) -match ($latest_release -replace 'v','')) {
            Write-Host "You are already using latest mpvnet -- $latest_release" -ForegroundColor Green
            $need_download = $false
        }
        else {
            Write-Host "Newer mpvnet build available" -ForegroundColor Green
            $need_download = $true
        }
    }
    else {
        Write-Host "mpvnet doesn't exist. " -ForegroundColor Green -NoNewline
        $result = "Y"
        Write-Host ""

        if ($result -eq 'Y') {
            $need_download = $true
        }
        else {
            $need_download = $false
        }
    }

    if ($need_download) {
        Get-mpvnet $latest_release
        Expand-zipfile $latest_release
    }
}

function Read-KeyOrTimeout ($prompt, $key){
    $seconds = 9
    $startTime = Get-Date
    $timeOut = New-TimeSpan -Seconds $seconds

    Write-Host "$prompt " -ForegroundColor Green

    # Basic progress bar
    [Console]::CursorLeft = 0
    [Console]::Write("[")
    [Console]::CursorLeft = $seconds + 2
    [Console]::Write("]")
    [Console]::CursorLeft = 1

    while (-not [System.Console]::KeyAvailable) {
        $currentTime = Get-Date
        Start-Sleep -s 1
        Write-Host "#" -ForegroundColor Green -NoNewline
        if ($currentTime -gt $startTime + $timeOut) {
            Break
        }
    }
    if ([System.Console]::KeyAvailable) {
        $response = [System.Console]::ReadKey($true).Key
    }
    else {
        $response = $key
    }
    return $response.ToString()
}
#endregion /FUNCTIONS ####################################################### - /FUNCTIONS

#region SCRIPT ############################################################## - SCRIPT
if (Test-Admin) {
    Write-Host "Running script with administrator privileges" -ForegroundColor Yellow
}
else {
    Write-Host "Running script without administrator privileges" -ForegroundColor Red
}

try {
    Read-PowershellVersion
    # Sourceforge only support TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Update-mpvnet
    Write-Host "Operation completed" -ForegroundColor Magenta
}
catch [System.Exception] {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
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

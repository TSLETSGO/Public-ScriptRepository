<#
.SYNOPSIS
    Updates youtube-dlp
.DESCRIPTION
    Author: TSLETSGO
    Version: 1.0

    Updates youtube-dlp using a modified version of the MPV update script

.EXAMPLE
    ./Youtube-dlp-update.ps1
    
.EXAMPLE
    # if you want to transcript shell output
    ./youtube-dlp-update.ps1 -transcript

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
    [parameter(Mandatory=$false, HelpMessage="Folder where yt-dlp.exe is located")]
    [ValidateNotNullOrEmpty()]
    [string]$ytdlploc="C:\Program Files\Youtube-dlp",
    [parameter(Mandatory=$false, HelpMessage="Folder where 7-zip is located")]
    [ValidateNotNullOrEmpty()]
    [string]$7ZipLocation="C:\Program Files\7-Zip"
)

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="youtube-DLP-update"
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

function find-ytdlp {
    $youtubedlp = "$($ytdlploc)\yt-dlp.exe"
    $is_exist = Test-Path $youtubedlp
    return $is_exist
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

function Get-Youtubedlp ($version) {
    Write-Host "Downloading youtube-dlp ($version)" -ForegroundColor Green
    $global:progressPreference = 'Continue'
    $link = "https://github.com/yt-dlp/yt-dlp/releases/download/"  + $version + "/yt-dlp.exe"
    Invoke-WebRequest -Uri $link -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -OutFile "$($ytdlploc)\yt-dlp.exe"
}

function Get-Latest-Youtubedlp {
    $link = "https://github.com/yt-dlp/yt-dlp/releases/latest"
    Write-Host "Fetching RSS feed for youtube-dlp" -ForegroundColor Green
    $global:progressPreference = 'silentlyContinue'
    $resp = Invoke-WebRequest $link -MaximumRedirection 0 -ErrorAction Ignore -UseBasicParsing
    $redirect_link = $resp.Headers.Location
    $version = $redirect_link.split("/")[7]
    return $version
}

function Test-Admin{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Update-Youtubedlp {
    $need_download = $false
    $latest_release = Get-Latest-Youtubedlp

    if (find-ytdlp) {
        if ((.$ytdlploc\yt-dlp.exe --version) -match ($latest_release)) {
            Write-Host "You are already using latest youtube-dlp -- $latest_release" -ForegroundColor Green
            $need_download = $false
        }
        else {
            Write-Host "Newer youtube-dlp build available" -ForegroundColor Green
            $need_download = $true
        }
    }
    else {
        Write-Host "youtube-dlp doesn't exist. " -ForegroundColor Green -NoNewline
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
        Get-Youtubedlp $latest_release
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
    Update-Youtubedlp
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

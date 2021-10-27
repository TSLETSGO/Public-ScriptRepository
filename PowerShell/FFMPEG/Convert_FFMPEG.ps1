<#
.SYNOPSIS
    Uses FFMPEG to convert videos in a folder to a specified new format
.DESCRIPTION
    Author: TSLETSGO
    Version: 1.1

    Uses FFMPEG to convert videos in a folder to WEBM

.EXAMPLE
    ./Convert-FFMPEG.ps1 -videoFolder "C:\Videos" -ffmpeg "C:\programfiles\ffmpeg\ffmpeg.exe"
    
.EXAMPLE
    #if you want transcript
    ./Convert-FFMPEG.ps1 -videoFolder "C:\Videos" -ffmpeg "C:\programfiles\ffmpeg\ffmpeg.exe" -transcript

.NOTES
    Remember to provide the parameters to fit your environment.

#>

[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [parameter(Mandatory=$false, HelpMessage="If used, will remove audio from output video")]
    [ValidateNotNullOrEmpty()]
    [switch]$RemoveAudio,
    [parameter(Mandatory=$true, HelpMessage="Folder with video files for converting, example: `"C:\Videos`"")]
    [ValidateNotNullOrEmpty()]
    [string]$Videofolder,
    [parameter(Mandatory=$true, HelpMessage="Folder where FFMPEG.exe is located")]
    [ValidateNotNullOrEmpty()]
    [string]$FFMPEG="C:\Program Files\FFMPEG\ffmpeg.exe"
)

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="Convert_FFMPEG"
    $StartTime=get-date -format o
    #Starts transcript of script
    Start-Transcript "$($env:TEMP)\$ScriptName.ps1_log.txt" -Force -Append
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    Write-host "------------------------- Script Start ----------------------------" -ForegroundColor cyan
    Write-host "--- Script started at `'$StartTime`'" -ForegroundColor cyan
}

#region VARIABLES ########################################################### - VARIABLES
$VideoFileformatArray = ".webm",".mkv",".flv",".vob",".ogv",".ogg",".drc",".gifv",".mng",".avi",".mts",".m2ts",".ts",".mov",".qt",".wmv",".wmv",".yuv",".rm",".rmvb",".viv",".asf",".amv",".mp4",".m4p",".m4v",".mpg",".mpeg",".mp2",".mpe",".mpv",".m2v",".m4v",".svi",".3gp",".3g2",".mxf",".nsv"
#endregion /VARIABLES ####################################################### - /VARIABLES

#region FUNCTIONS ########################################################### - FUNCTIONS
function Convert_Video {
    param (
        [parameter(Mandatory=$true, HelpMessage="Video file for converting, example: `"C:\Videos\test.mp4`"")]
        [ValidateNotNullOrEmpty()]
        [string]$Videofile,
        [parameter(Mandatory=$true, HelpMessage="Folder where FFMPEG.exe is located")]
        [ValidateNotNullOrEmpty()]
        [string]$FFMPEG,
        [string]$OutputName,
        [string]$format,
        [switch]$RemoveAudio
    )
    try {
        if ($RemoveAudio){
            write-host "- Note: `'RemoveAudio`' switch is set. Removing audio from video." -ForegroundColor Yellow
            #& $FFMPEG -i "$VideoFile" -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a -an "$OutputName.webm"
            & $FFMPEG -i $VideoFile -vcodec copy -an $OutputName
        }
        else{
            & $FFMPEG -i "$VideoFile" -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus "$OutputName.$format"        
        }
        write-host "- Output: `'$OutputName`'" -foregroundcolor Green
    }
    catch {
        write-host "Error Converting $VideoFile" -ForegroundColor Red
    }

}
#endregion /FUNCTIONS ####################################################### - /FUNCTIONS

#region SCRIPT ############################################################## - SCRIPT
if ($Videofolder){
    
    #selects formatting if RemoveAudio switch isnt being used
    if ($RemoveAudio){
       write-host "removing audio for files in `'$VideoFolder`'" 
    }
    else {
        $format = Read-Host "Input desired output format, example: webm, mp4, mov, etc."
    }

    #runs a foreach for every file located in the inputted video folder and converts them to desired format, or removes audio
    $VideoFiles = Get-ChildItem $Videofolder
    foreach ($videofile in $VideoFiles) {
        if ($videofile.extension -in $VideoFileformatArray){
            if (($Videofile.extension -eq ".$format") -and !($RemoveAudio)){
                write-host "$videofile is already $format, and RemoveAudio switch non-existing. Skipping." -ForegroundColor Cyan
            }
            else {
                $OutputName = [System.IO.Path]::GetFileNameWithoutExtension($($Videofile.Fullname))
                write-host "Converting `'$($Videofile.FullName)`'" -ForegroundColor Yellow
                if ($RemoveAudio){
                    $OutputName = $OutputName + "-NoAudio"
                    $OutputName = $OutputName + "$(([System.IO.Path]::GetExtension($($Videofile.Fullname))))"
                    Convert_Video -VideoFile "$($videofile.FullName)" -FFMPEG "$FFMPEG" -OutputName "$($Videofile.DirectoryName)\$OutputName" -RemoveAudio
                }
                else{
                    $OutputName = [System.IO.Path]::GetFileNameWithoutExtension($($Videofile.Fullname))
                    Convert_Video -VideoFile "$($videofile.FullName)" -FFMPEG "$FFMPEG" -OutputName "$($Videofile.DirectoryName)\$OutputName" -format $format
                }
            }
        }
    }
}
#Pause at end of script
Pause
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

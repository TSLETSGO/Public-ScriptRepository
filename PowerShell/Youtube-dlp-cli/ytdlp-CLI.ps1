<#
.SYNOPSIS
    Simple front-end CLI for downloading youtube-DLP audio/video stuff
.DESCRIPTION
    Author: TSLETSGO
    Version: 1.0

    Got tired of forgetting commands so created a simplified commandline interface for youtube-dl dumbos to download desired videos and audio.

.EXAMPLE
	- Run script
		- (Recommended is creating a shortcut with following target and running it from that:)
			- C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "<LOCATION OF SCRIPT>\Yt-dlp-CLI.ps1" -ytdlploc "<locationofyoutubedlp>"
	- Input link to desired video
	- choose audio or video
	- Set formatcode
	- Set output folder for files

.NOTES
	Requires 
		Youtube-dlp
			- The main program that this simple CLI sends instructions to
	Recommended:
		+ FFMPEG (add to same folders as youtube-dl)
			- Fixes malformed bitstreams
#>

[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [parameter(Mandatory=$false, HelpMessage="Determines output folder location")]
    [ValidateNotNullOrEmpty()]
    [string]$OutputFolder="$env:USERPROFILE\Downloads",
    [parameter(Mandatory=$true, HelpMessage="location of youtube-dlp")]
    [ValidateNotNullOrEmpty()]
    [string]$ytdlploc="C:\Program Files\Youtube-DLP\yt-dlp.exe",
	[parameter(Mandatory=$true, HelpMessage="The URL to the desired audio/video download, must start with http or https")]
    [ValidateNotNullOrEmpty()]
	[ValidatePattern("^http")]
    [string]$mediaURL
)

#region VARIABLES ########################################################### - VARIABLES
#endregion /VARIABLES ####################################################### - /VARIABLES

if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="Youtube-DLP-CLI"
    $StartTime=get-date -format o
    #Starts transcript of script
    Start-Transcript "$($env:TEMP)\$ScriptName.ps1_log.txt" -Force -Append
    Write-output "-------------------------------------------------------------------"
    Write-output "------------------------- Script Start ----------------------------"
    Write-output "--- Script started at `'$StartTime`'"
}

#region FUNCTIONS ########################################################### - FUNCTIONS
#endregion /FUNCTIONS ####################################################### - /FUNCTIONS

#region SCRIPT ############################################################## - SCRIPT

$OutputFolderFinal = $OutputFolder + "\%(title)s-%(format)s.%(ext)s"

$ChooseFormat=Read-Host "(A)udio or (v)ideo?"
if ($ChooseFormat -match "audio|a"){
    try{
		Write-output ""
		.$ytdlploc --audio-format best -x -o $OutputFolderFinal $mediaURL --audio-format mp3
	}
	catch{
		Write-output "!! Error downloading $mediaURL !!"
		$ErrorMessage = $_.Exception.Message
		Write-output "Error message:"
		Write-output $ErrorMessage
	}
}
elseif($ChooseFormat -match "video|v"){
	try{
	
		Write-output ""
		.$ytdlploc -F $mediaURL
		
		Write-output ""
		$FormatCode = Read-Host "Specify format code for desired video, or just `'best`' " 
		
		Write-output ""
		.$ytdlploc -f $FormatCode -o $OutputFolderFinal $mediaURL 
		
	}
	catch{ 
	
		Write-output "!! Error downloading $mediaURL !!"
		$ErrorMessage = $_.Exception.Message
		Write-output "Error message:"
		Write-output $ErrorMessage 
		
	}
}
else{

	Write-output ""
	Write-output "audio or video not chosen"
	
}

read-host "-- Script ended --"
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

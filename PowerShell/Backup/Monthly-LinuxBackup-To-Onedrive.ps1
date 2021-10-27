<#
.SYNOPSIS
    Monthly backup
.DESCRIPTION
    Author: Trond Stien
    Version: 1.0
    Creation Date: 01.06.2021

    Grabs file from FROM location, put it in onedrive, and mark as cloud-only

    Delete the 6 month old backup file to the TO location

.EXAMPLE
    ./Monthly-LinuxBackup-To-Onedrive.ps1 -FILEPATH \\backup\backupfolder\monthly\backup.7z" -BACKUPTOPATH "C:\backup"  -DELETEMONTHSBACK "6"

.NOTES
    The script will append the current year+month if the file doesn't have it already:
    - <FILENAME>-<YEAR><MONTH>

#>
[cmdletbinding()]
param(
    [parameter(Mandatory=$false, HelpMessage="Determines to transcript shell output to `$env:TEMP or not")]
    [ValidateNotNullOrEmpty()]
    [switch]$transcript,
    [parameter(Mandatory=$false, HelpMessage="Will delete files older than specified months, example `'6`'")]
    [ValidateNotNullOrEmpty()]
    $DELETEMONTHSBACK,
    [parameter(Mandatory=$true, HelpMessage="Full to path folder where file will be backed up to, example `'C:\backup`'")]
    [ValidateNotNullOrEmpty()]
    [string]$BACKUPTOPATH,
    [parameter(Mandatory=$true, HelpMessage="Full from path, example `'\\backup\backupfolder\monthly\backup.7z`'")]
    [ValidateNotNullOrEmpty()]
    [string]$FILEPATH
)

#region FUNCTIONS ########################################################### - FUNCTIONS
if ($transcript -eq $true){
    #Defines name of script for logging purposes
    $ScriptName="Monthly-LinuxBackup-To-Onedrive"
    $StartTime=get-date -format o
    #Starts transcript of script
    Start-Transcript "$($env:TEMP)\$ScriptName.ps1_log.txt" -Force -Append
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    Write-host "------------------------- Script Start ----------------------------" -ForegroundColor cyan
    Write-host "--- Script started at `'$StartTime`'" -ForegroundColor cyan
}

#region VARIABLES ########################################################### - VARIABLES
$FILE = (Get-Item $FILEPATH)
$DATE = $(get-date -Format yyyyMM)
#endregion /VARIABLES ####################################################### - /VARIABLES

#region FUNCTIONS ########################################################### - FUNCTIONS
#endregion /FUNCTIONS ####################################################### - /FUNCTIONS

if (!(test-path $FILEPATH)){
    write-host "couldn't find filepath `'$FILEPATH`', please double check" -ForegroundColor Red
}
else{
    # Adding year and month to filename
    if ($FILE.Basename.endswith($DATE)){
        write-host "`'$($FILE.BaseName)`' filename aleady ends with date" -ForegroundColor Yellow
        $FILENAME = $FILE.BaseName + $FILE.Extension
    }
    else{
        write-host "`'$($FILE.BaseName)`' is missing date, adding date"
        $FILENAME = $FILE.BaseName + "-" + $DATE + $FILE.Extension
        write-host "`'$($FILE.Name)`' transformed to `'$($FILENAME)`'" -ForegroundColor Green
    }

    # Setting FULLTOPATH
    $FULLBACKUPPATH = "$($BACKUPTOPATH)\$($FILENAME)"

    write-host ""
    write-host "Checking if `'$FULLBACKUPPATH`' already exists" 
    if (!(test-path $FULLBACKUPPATH)){
        
        write-host "`'$FULLBACKUPPATH`' does not exist - starting copy"
        write-host "copying `'$FILEPATH`' to `'$FULLBACKUPPATH`'" -ForegroundColor Yellow
        Copy-Item -LiteralPath $FILEPATH -Destination $FULLBACKUPPATH
        
        if (test-path $FULLBACKUPPATH){
            write-host "File successfully copied" -ForegroundColor Green

            # If saving to OneDrive - mark backup as cloud-only
            if ($BACKUPTOPATH.StartsWith($env:OneDrive)){
                write-host "-`'$BACKUPTOPATH`' seems to be a OneDrive location" -ForegroundColor Blue
                write-host "--Marking `'$($FILE.BaseName)`' cloud-only" -ForegroundColor Blue
                attrib +U -P $FULLBACKUPPATH
            }

        }

    }
    else{
        if (!(test-path $BACKUPTOPATH)){
            write-host "Backup path `'$BACKUPTOPATH'` doesn't exist" -ForegroundColor Red
        }
        else{
            write-host "`'$($FILENAME)`' Already exists within `'$BACKUPTOPATH'` folder" -ForegroundColor Red
            write-host "Skipping `'$($FILENAME)`'" -ForegroundColor Red
        }
    }

    if ($DELETEMONTHSBACK){
        write-host ""
        write-host "DELETEMONTHSBACK variable is set"
        $CurrentDate = Get-Date
        $DatetoDelete = $CurrentDate.AddMonths(-$DELETEMONTHSBACK)
        write-host "Delete files older than `'$DELETEMONTHSBACK`' months from `'$BACKUPTOPATH`'" -ForegroundColor Yellow
        $FILESTODELETE = Get-ChildItem $BACKUPTOPATH | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
        if (($NULL -eq $FILESTODELETE) -or ($FILESTODELETE -eq "")){
            write-host "no files older than `'$DELETEMONTHSBACK`' months were found in `'$BACKUPTOPATH`'"
        }
        else{
            Remove-Item $FILESTODELETE
        }
    }
}

if ($transcript -eq $true){
    $EndTime=get-date -format o
    Write-Host
    Write-host "--- Script ended at `'$EndTime`'" -ForegroundColor cyan
    Write-host "------------------------- Script Done -----------------------------" -ForegroundColor cyan
    Write-host "-------------------------------------------------------------------" -ForegroundColor cyan
    write-host
    Stop-transcript
}

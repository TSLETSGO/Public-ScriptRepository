write-host "Performing a winget upgrade of all packages:" -ForegroundColor Yellow
write-host
winget upgrade --all --silent --include-unknown
write-host
pause
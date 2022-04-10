write-host "Performing a winget upgrade of all packages:" -ForegroundColor Yellow
write-host
winget upgrade --all --silent
write-host
write-host "upgrade --include-unknown:" -ForegroundColor Yellow
write-host
winget upgrade --all --include-unknown
pause
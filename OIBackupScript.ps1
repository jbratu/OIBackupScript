$ClientName = "SomeOIFolder"
$Source = "C:\Temp\" + $ClientName + "-backup.7z"
$BackupStorage = "C:\" + $ClientName + "-backups"

c:
cd \Revsoft\OIBackupScript
.\Shadowspawn.exe C:\ x: robocopy "x:\$ClientName" "C:\Temp\$ClientName-backup" * /MIR | Out-Null

.\7z.exe a -t7z $Source "C:\Temp\$ClientName-backup\*" | Out-Null


if(-not [System.IO.File]::Exists($Source)) {
Write-Host "$Source does not exist"
return
}

New-Item -ItemType Directory -Force -Path $BackupStorage | Out-null

$BackupStorageDaily = $BackupStorage + "\Daily\"
New-Item -ItemType Directory -Force -Path $BackupStorageDaily | Out-null
$BackupStorageWeekly = $BackupStorage + "\Weekly\"
New-Item -ItemType Directory -Force -Path $BackupStorageWeekly | out-null
$BackupStorageMonthly = $BackupStorage + "\Monthly\"
New-Item -ItemType Directory -Force -Path $BackupStorageMonthly | Out-null

$DailyTimeStamp = (get-date -Format "yyyy-MM-dd_hhmm-ss")
$DestName = $BackupStorageDaily + $ClientName + " backup " + $DailyTimeStamp  + ".7z"
Write-Host "Daily: $DailyTimeStamp from $Source to $DestName"
Copy-Item $Source -Destination $DestName

$limit = (Get-Date).AddDays(-10)
Get-ChildItem -Path $BackupStorageDaily -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

$WeekTimeStamp = (get-date -UFormat "%V")
$DestName = $BackupStorageWeekly + $ClientName + " backup week " + $WeekTimeStamp + ".7z"
Write-Host "Weekly: $WeeklyTimeStamp from $Source to $DestName"
Copy-Item $Source -Destination $DestName

$MonthTimeStamp = (get-date -Format "yyyy-MM")
$DestName = $BackupStorageMonthly + $ClientName + " backup month " + $MonthTimeStamp + ".7z"
Write-Host "Month: $MonthTimeStamp from $Source to $DestName"
Copy-Item $Source -Destination $DestName

Remove-Item -Force $Source
Remove-Item -Force -Path "C:\Temp\$ClientName-backup" -Recurse
# InstallSchoolPCDrivers.ps1
# Scripting my school PC's drivers install so I can be lazy and not have to do them all one by one manually. God I wish Gigabyte had a tool to do a driver install or their factory image tool (Gigabyte Smart USB Backup) worked.
# Joseph Wahba

Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    Description = "Select SchoolPCDrivers Folder"
}
$null = $FolderBrowser.ShowDialog()
$PathLoc = $FolderBrowser.SelectedPath

Write-Output "Begin Installing Drivers!"
Write-Host "Drivers: Audio"

$DriverDir = "$PathLoc\Audio\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Bluetooth"

$DriverDir = "$PathLoc\Bluetooth\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Card Reader"

$DriverDir = "$PathLoc\Card Reader\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Chipset"

$DriverDir = "$PathLoc\Chipset\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: LAN"

$DriverDir = "$PathLoc\LAN\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Utility"

$DriverDir = "$PathLoc\Utility\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: VGA"

$DriverDir = "$PathLoc\VGA\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: WLAN"

$DriverDir = "$PathLoc\WLAN\"

foreach ($File in $DriverDir) {
    Start-Process -FilePath "$DriverDir\$File" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Output "Installing Drivers Complete!"

# InstallSchoolPCDrivers.ps1
# Scripting my school PC's drivers install so I can be lazy and not have to do them all one by one manually. God I wish Gigabyte had a tool to do a driver install or their factory image tool (Gigabyte Smart USB Backup) worked.
# Joseph Wahba
#Requires -RunAsAdministrator

$InstallerTypes = @("*Setup*.exe", "Dolby*.exe")

Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    Description = "Select SchoolPCDrivers Folder"
}
$null = $FolderBrowser.ShowDialog()
$PathLoc = $FolderBrowser.SelectedPath

Write-Output "Begin Installing Drivers!"
Write-Host "Drivers: Bluetooth"

$DriverFolders = Get-ChildItem -Path "$PathLoc\Bluetooth\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Card Reader"

$DriverFolders = Get-ChildItem -Path "$PathLoc\Card Reader\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Chipset"

$DriverFolders = Get-ChildItem -Path "$PathLoc\Chipset\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: LAN"

$DriverFolders = Get-ChildItem -Path "$PathLoc\LAN\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Utility"

$DriverFolders = Get-ChildItem -Path "$PathLoc\Utility\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: VGA"

$DriverFolders = Get-ChildItem -Path "$PathLoc\VGA\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: WLAN"

$DriverFolders = Get-ChildItem -Path "$PathLoc\WLAN\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}

Write-Host "Drivers: Audio"

$DriverFolders = Get-ChildItem -Path "$PathLoc\Audio\" -Directory | Select-Object -ExpandProperty FullName
foreach ($Folder in $DriverFolders) {
    $SetupFile = Get-ChildItem -Path "$Folder/*" -File -Include $InstallerTypes
    Write-Output "Installing $($SetupFile.FullName)"
    Start-Process -FilePath "$($SetupFile.FullName)" -ArgumentList "/s", "/S", "/silent", "/SILENT", "-silent", "-SILENT", "/q", "/Q", "/qn", "/QN", "/quiet", "/QUIET", "-unattended", "-UNATTENDED", "/passive", "/PASSIVE", "/norestart", "/NORESTART" -Wait -NoNewWindow
}


Write-Output "Installing Drivers Complete!"

# Create VMs
# Creates Hyper-V VM's with specific settings for College Class Labs.
# Joseph Wahba
#Requires -RunAsAdministrator
param (
    $VMPath = "$($HOME)\Documents\HyperVM\",
    $VMVHD = "$($HOME)\Documents\HyperVM\",
    $VMISO,
    $VNet = "Default Switch",
    $VNetType
)

$VMname = Read-Host "Enter VM Name, Type end to end"
if ($VNet -ne "Default Switch") {
    if (!(Get-VMSwitch -name $VNet -ErrorAction SilentlyContinue)) {
        New-VMSwitch -Name $VNet -SwitchType $VNetType
    }
}
while ($VMname -ne "End") {
    New-VM -Name "$VMname" -MemoryStartupBytes 1GB -Generation 2 -SwitchName $VNet -Path "$($VMPath)\$($VMname)" -NewVHDPath "$($VMVHD)\$($VMName)\base.vhdx" -NewVHDSizeBytes 40GB -GuestStateIsolationType TrustedLaunch
    Set-VMProcessor -VMName "$Vmname" -Count 2
    Set-VMMemory -VMName "$Vmname" `
        -DynamicMemoryEnabled $true `
        -MinimumBytes 512MB `
        -StartupBytes 1GB `
        -MaximumBytes 2GB
    if ($VMISO) {
        Add-VMDvdDrive -VMName "$VMname" -Path $VMISO
    }
    Set-VMFirmware -VMName $VMname -EnableSecureBoot off
    Disable-VMTPM -VMName $VMname
    Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface"
    $VMname = Read-Host Enter VM Name
}
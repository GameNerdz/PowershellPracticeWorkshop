# RunMe.ps1
# For Passing arguments to the cleanup script and running the cleanup
# Written by Joseph Wahba with help from Google Gemini for how to do thing and troubleshooting
# Im going to kill myself if I see another "$script:" being the fix for my issues, or if gemini commments on my button positioning. IT WORKS FUCK OFF.

$ArgumentsList = [ordered]@{
    "NoInstall"         = "Skip install Programs via Winget"
    "NoMB"              = "Skip Malwarebytes Install from Winget and Execution"
    "NoADW"             = "Skip Adwcleaner Execution"
    "NoBC"              = "Skip BCUninstaller install from Winget and Execution"
    "NoSFC"             = "Skip SFC Scan"
    "NoDISM"            = "Skip DISM Scan"
    "NoDC"              = "Skip Disk Cleanup"
    "ForceDCRegRemoval" = "Force removal of Disk Cleanup Registry Keys"
    "NoUpdate"          = "Skip Updates"
    "NoUninstall"       = "Do not Uninstall Programs Installed from Package Manager"
    "NoRestart"         = "Do not Reboot PC after Script is done"
    "ForceUninstall"    = "Force Uninstall Package Manager Installed Programs"
    "KeepChoco"         = "Keeps Chocolatey Installed (Only on Choco Ver.)"
}

$ypos = 20

$script:Manager = ""
$script:Arguments = ""

#Create Form
Add-Type -AssemblyName System.Windows.Forms
$CleanupForm = New-Object System.Windows.Forms.Form
$CleanupForm.Text = "Cleanup Script - Select What to Run."
$CleanupForm.AutoSize = $true
#$CleanupForm.Size = New-Object System.Drawing.Size(300,400)
$CleanupForm.StartPosition = "CenterScreen"

#Package Manager Groupbox
$PackageManagers = New-Object System.Windows.Forms.GroupBox
$PackageManagers.Text = "Package Managers - Choose One"
$PackageManagers.Size = New-Object System.Drawing.Size(350, 80)
$PackageManagers.AutoSize = $false

#Winget
$Winget = New-Object System.Windows.Forms.CheckBox
$Winget.Text = "Winget - Use Winget as Package Manager"
$Winget.Tag = "Winget"
$Winget.Location = New-Object System.Drawing.Point(10, $ypos)
$Winget.AutoSize = $true
$PackageManagers.Controls.Add($Winget)

#Chocolatey
$Chocolatey = New-Object System.Windows.Forms.CheckBox
$Chocolatey.Text = "Chocolatey - Use Chocolatey as Package Manager"
$Chocolatey.Tag = "Choco"
$Chocolatey.Location = New-Object System.Drawing.Point(10, ($ypos + 20))
$Chocolatey.AutoSize = $true
$PackageManagers.Controls.Add($Chocolatey)

# Add Package Managers to form
$CleanupForm.Controls.Add($PackageManagers)

#Everything Else Groupbox
$ArgumentBox = New-Object System.Windows.Forms.GroupBox
$ArgumentBox.Text = "Arguments"
$ArgumentBox.Location = New-Object System.Drawing.Point(0, 80)
#$PackageManagers.Size = New-Object System.Drawing.Size(310, 80)
$ArgumentBox.AutoSize = $true

#Everything Else
foreach ($arg in $ArgumentsList.GetEnumerator()) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = "$($arg.Key) - $($arg.Value)"
    $cb.Tag = "$($arg.Key)"
    $cb.Location = New-Object System.Drawing.Point(10, $ypos)
    $cb.AutoSize = $true
    $ArgumentBox.Controls.Add($cb)
    $ypos += 20
}

# Add Everything Else to for
$CleanupForm.Controls.Add($ArgumentBox)

# Button to Submit
$ButtonSubmit = New-Object System.Windows.Forms.Button
$ButtonSubmit.Text = "Run Script"
$ButtonSubmit.Location = New-Object System.Drawing.Point($ArgumentBox.Bottom, $ArgumentBox.Bottom)

$ButtonSubmit.Add_Click({
        $script:Manager =""
        $script:Arguments = ""

        $AllCheckedPkg = $PackageManagers.Controls | Where-Object {
            $_ -is [System.Windows.Forms.CheckBox] -and $_.Checked
        }
        foreach ($Checked in $AllCheckedpkg) {
            $script:Manager += " -$($Checked.Tag)"
        }

        $AllCheckedArg = $ArgumentBox.Controls | Where-Object {
            $_ -is [System.Windows.Forms.CheckBox] -and $_.Checked
        }
        foreach ($Checked in $AllCheckedArg) {
            $script:Arguments += " -$($Checked.Tag)"
        }
        $CleanupForm.Close()
    })

$CleanupForm.Controls.Add($ButtonSubmit)

# Show The Form
$null = $CleanupForm.ShowDialog()

#Powershell Exec
$Command = "& '$PSScriptRoot\SpringClean.ps1' $script:Manager $script:Arguments"
Start-Process Powershell.exe -Verb RunAs -WorkingDirectory $PSScriptRoot -ArgumentList "-NoExit", " -ExecutionPolicy Bypass", "-Command $Command"
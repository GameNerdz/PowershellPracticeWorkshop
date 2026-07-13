# Spring-Clean.ps1
# Version 3
# Runs Maintanance Tasks.

# Info:
# Installs Malwarebytes and BulkCrapUninstaller if not installed (and Runs them for manual scan and program removal)
# Runs Adwcleaner, Disk Cleanup, DISM, and SFC automatically
# Installs Latest Windows Updates
# Uninstalls Programs Installed via the script and deletes folder ADWCleaner creates at very end (Script does Pause for Techicinan to complete manual tasks, review ADWCLeaner removal logs and more.)

# How to Run:
# Open Powershell/Terminal as Admin and cd to the SpringClean folder
# Run: powershell -ExecutionPolicy Bypass .\Spring-CleanV2.ps1
# Add Arguments you want to the end of run line
 
# Argument List:
#    -NoInstall         - Skip install Programs via Winget
#    -NoMB              - Skip Malwarebytes Install from Winget and Execution
#    -NoADW             - Skip Adwcleaner Execution
#    -NoBC              - Skip BCUninstaller install from Winget and Execution
#    -NoSFC             - Skip SFC Scan
#    -NoDISM            - Skip DISM Scan
#    -NoDC              - Skip Disk Cleanup
#    -ForceDCRegRemoval - Force removal of Disk Cleanup Registry Keys
#    -NoUpdate          - Skip Updates
#    -NoUninstall       - Do not Uninstall Programs Installed from Winget
#    -NoRestart         - Do not Reboot PC after Script is done
#    -ForceUninstall    - Force Uninstall Winget Installed Programs
#    -KeepChoco         - Keep Chocolatey Installed (If not already installed by Synchro).
#    -Choco             - Use Choco to install programs
#    -Winget            - Use Winget to install programs

# Joseph Wahba
#requires -RunAsAdministrator

param (
    [Switch]$NoInstall,
    [Switch]$KeepChoco,
    [Switch]$NoMB,
    [Switch]$NoADW,
    [Switch]$NoBC,
    [Switch]$NoSFC,
    [Switch]$NoDISM,
    [Switch]$NoDC,
    [Switch]$ForceDCRegRemoval,
    [Switch]$NoUpdate,
    [Switch]$NoUninstall,
    [Switch]$NoRestart,
    [Switch]$ForceUninstall,
    [Switch]$Choco,
    [Switch]$Winget
)

if ($Choco -xor $Winget) {
    # Export Event Viewer logs - Requested and coded by Jon
    function write-diagnostic ($messages) {
        write-host  '<-Start Diagnostic->'
        foreach ($Message in $Messages) { $Message }
        write-host '<-End  Diagnostic->'
    } 

    function write-result ($message) {
        write-host '<-Start Result->'
        write-host "Alert=$message"
        write-host '<-End Result->'
    }

    $version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion

    if ($Version -lt "6.2") {
        write-host "Unsupported OS. Only Windows 10 and up are supported."
        exit 1
    }

    $RightNow = Get-Date -Format FileDateTime

    $Logs = get-ciminstance -ClassName Win32_NTEventlogFile | Where-Object { $_.LogfileName -eq "Application" -or $_.LogfileName -eq "System" -or $_.LogfileName -eq "Security" }

    foreach ($log in $logs) {
        $BackupPath = Join-Path "$PSScriptRoot\EventLogs\$env:COMPUTERNAME\$RightNow" "$($log.FileName).evtx"
        New-Item -ItemType File -Path $BackupPath -Force
        Copy-Item -path $($Log.Name) -Destination $BackupPath -Force
        If ($env:ClearLogs -eq "Clear") { Clear-EventLog $log. Filename }
    }

    $ScriptLogfileLoc = "$PSScriptRoot\EventLogs\$env:COMPUTERNAME\$RightNow\log.txt"

    if ($Choco) {
        # List of programs to be installed via Chocolatey - Add or remove here
        $ProgramListIDs = [PSCustomObject]@{
            Malwarebytes        = "Malwarebytes" 
            BulkCrapUninstaller = "bulk-crap-uninstaller"
        }
        # Install Chocolatey
        Write-Output "==========`nPackage Manager Status`n==========" >> $ScriptLogfileLoc
        if (-not $NoInstall) {
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            if ($LASTEXITCODE -eq 0) {
                Write-Output "Chocolatey Installed!" >> $ScriptLogfileLoc
            }
            else {
                Write-Output "Failed to install! (Pre-Installed or Synchro)" >> $ScriptLogfileLoc
            }
        }
        else {
            Write-Output "Skipped!" >> $ScriptLogfileLoc
        }
    }

    if ($Winget) {
        # List of programs to be installed via Winget - Add or remove here
        $ProgramListIDs = [PSCustomObject]@{
            Malwarebytes        = "Malwarebytes.Malwarebytes" 
            BulkCrapUninstaller = "Klocman.BulkCrapUninstaller"
        }
        # Make sure Winget is installed
        Write-Output "`n=========`nPackage Manager Status`n==========" >> $ScriptLogfileLoc
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        if ($?) {
            Write-Output "Winget Installed!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to install!" >> $ScriptLogfileLoc
        }
    }

    # Install and load the Windows update Powershell Module
    Write-Output "`n==========`nPowershell Module Status`n==========" >> $ScriptLogfileLoc
    if (-not $NoUpdate) {
        Install-PackageProvider -Name NuGet -Force
        if ($?) {
            Write-Output "Nuget Provider Success!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Nuget Provider Fail!" >> $ScriptLogfileLoc
        }
        Install-Module PSWindowsUpdate -Force
        if ($?) {
            Write-Output "PSWindowsUpdate Installed!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "PSWindowsUpdate Failed!" >> $ScriptLogfileLoc
        }
        Import-Module PSWindowsUpdate
        if ($?) {
            Write-Output "PSWindowsUpdate Imported!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "PSWindowsUpdate Failed to Import!" >> $ScriptLogfileLoc
        }
    }

    # Check if programs are already installed
    # If so, assume customer installed them and do not uninstall.

    $checkinstalledpaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    # MalwareBytes Check
    $MBPreInstalledCheck = Get-ItemProperty $checkinstalledpaths | Select-Object -Property Displayname | Where-Object -Property DisplayName -match "Malwarebytes" -ErrorAction SilentlyContinue

    # BCUninstaller Check
    $BCPreInstallCheck = Get-ItemProperty $checkinstalledpaths | Select-Object -Property Displayname | Where-Object -Property DisplayName -match "BCUninstaller" -ErrorAction SilentlyContinue

    if ($Choco) {
        # Install missing programs for cleanup
        if (-not $NoInstall) {
            Write-Output "`n==========`nProgram Install Status`n==========" >> $ScriptLogfileLoc
            # Malwarebyts
            if (-not $MBPreInstalledCheck -and -not $NoMB) {
                choco install $ProgramListIDs.Malwarebytes -y
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "Malwarebytes Installed!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Malwarebytes Failed to install!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "Malwarebytes Skipped!" >> $ScriptLogfileLoc
            }

            # BCUninstaller
            if (-not $BCPreInstallCheck -and -not $NoBC) {
                choco install $ProgramListIDs.BulkCrapUninstaller -y
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "BulkCrapUninstaller Installed!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "BulkCrapUninstaller Failed to install!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "BulkCrapUninstaller Skipped!" >> $ScriptLogfileLoc
            }
        }
        else {
            Write-Output "Installation Phase Skipped!" >> $ScriptLogfileLoc
        }

    }

    if ($Winget) {
        # Install missing programs for cleanup
        if (-not $NoInstall) {
            # Malwarebyts
            if (-not $MBPreInstalledCheck -and -not $NoMB) {
                Winget Install $ProgramListIDs.Malwarebytes --accept-source-agreements
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "Malwarebytes Installed!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Malwarebytes Failed to install!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "Malwarebytes Skipped!" >> $ScriptLogfileLoc
            }

            # BCUninstaller
            if (-not $BCPreInstallCheck -and -not $NoBC) {
                Winget Install $ProgramListIDs.BulkCrapUninstaller --accept-source-agreements
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "BulkCrapUninstaller Installed!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "BulkCrapUninstaller Failed to install!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "BulkCrapUninstaller Skipped!" >> $ScriptLogfileLoc
            }
        }
        else {
            Write-Output "Installation Phase Skipped!" >> $ScriptLogfileLoc
        }
    }

    # Begin cleanup
    Write-Output "`n==========`nCleanup Status`n==========" >> $ScriptLogfileLoc
    # Start Malwarebytes - No CLI so technician must start scan manually!
    if (-not $NoMB) {
        Start-Process "$Env:ProgramFiles\Malwarebytes\Anti-Malware\Malwarebytes.exe"
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Malwarebytes Started!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to Launch Malwarebytes!" >> $ScriptLogfileLoc
        }
    }
    else {
        Write-Output "Malwarebytes Skipped!" >> $ScriptLogfileLoc
    }

    # Start BCUninstaller - Manual use: Technician has to select what to remove. Impossible to automate.
    if (-not $NoBC) {
        Start-Process "$Env:ProgramFiles\BCUninstaller\BCUninstaller.exe"
        if ($LASTEXITCODE -eq 0) {
            Write-Output "BulkCrapUninstaller Started!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to Launch BulkCrapUninstaller!" >> $ScriptLogfileLoc
        }
    }
    else {
        Write-Output "BulkCrapUninstaller Skipped!" >> $ScriptLogfileLoc
    }

    # Automate ADWcleaner scan - Note: Not using Start-Process so after ADW is done it opens the logs rather then running ADW in a new powershell window.
    if (-not $NoADW) {
        Start-Process "$PSScriptRoot\misc\adwcleaner.exe" -ArgumentList "/clean /eula /noreboot" -Wait
        if ($LASTEXITCODE -eq 0) {
            Write-Output "AdwCleaner Scan Success!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to Launch AdwCleaner Scan!" >> $ScriptLogfileLoc
        }
        Invoke-Item -Path "$Env:SystemDrive\AdwCleaner\Logs"
        if ($LASTEXITCODE -eq 0) {
            Write-Output "AdwCleaner Log Folder Opened!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to open AdwCleaner Log Folder!" >> $ScriptLogfileLoc
        }
    }
    else {
        Write-Output "AdwCleaner Skipped!" >> $ScriptLogfileLoc
    }

    # Run Disk Cleanup
    $DCSetValue = "6213"
    $DCRegPath = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\D3D Shader Cache",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Diagnostic Data Viewer database files"
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Feedback Hub Archive log files",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Language Pack",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\RetailDemo Offline Content",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender"
    )
    if (-not $NoDC) {
        foreach ($Regpath in $DCRegPath) {
            New-ItemProperty -Path $Regpath -Name "StateFlags$DCSetValue" -Value "2" -PropertyType DWORD -ErrorAction SilentlyContinue | Out-Null
        }
        Start-Process "cleanmgr.exe" -ArgumentList "/d $Env:SystemDrive /sagerun:$DCSetValue"
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Disk Cleanup Success!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to Run Disk Cleanup!" >> $ScriptLogfileLoc
        }
    }
    else {
        Write-Output "Disk Cleanup Skipped!" >> $ScriptLogfileLoc
    }

    # Run DISM Scan
    if (-not $NoDISM) {
        DISM /Online /Cleanup-Image /RestoreHealth
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Deployment Image Servicing and Management Success!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to Run Deployment Image Servicing and Management!" >> $ScriptLogfileLoc
        }
    }
    else {
        Write-Output "Deployment Image Servicing and Management Skipped!" >> $ScriptLogfileLoc
    }

    # Run SFC Scan
    if (-not $NoSFC) {
        SFC /Scannow
        if ($LASTEXITCODE -eq 0) {
            Write-Output "System File Checker Success!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Failed to Run System File Checker!" >> $ScriptLogfileLoc
        }
    }
    else {
        Write-Output "System File Checker Skipped!" >> $ScriptLogfileLoc
    }

    # Check for Windows Updates and Install any
    Write-Output "`n==========`nComputer Updates Status`n==========" >> $ScriptLogfileLoc
    if (-not $NoUpdate) {
        $Updates = Get-WindowsUpdate
        if ($null -eq $Updates) {
            Write-Output "Windows up to date!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Windows Updates Found!" >> $ScriptLogfileLoc
        }
        Install-WindowsUpdate -AcceptAll -IgnoreReboot
        if ($?) {
            Write-Output "Windows Updates Installed!" >> $ScriptLogfileLoc
        }
        else {
            Write-Output "Windows Updates Failed to install!" >> $ScriptLogfileLoc
        }
    }
    else {
        Write-Output "Windows Updates Skipped!" >> $ScriptLogfileLoc
    }

    # Pause till technician is ready (For if manual scans are still running)
    Write-Host "Waiting for Technician to signal manual scans are done."
    Write-Host "Press Enter to continue..."
    Read-Host | Out-Null
    Write-Host "Continuing script execution."

    if ($Choco) {
        Write-Output "`n==========`nProgram Uninstall Status`n==========" >> $ScriptLogfileLoc
        # Cleanup what was installed via the script
        if (-not $NoUninstall -or $ForceUninstall) {
            # Malwarebyts
            if ((-not $MBPreInstalledCheck -and -not $NoMB) -or $ForceUninstall) {
                choco uninstall $ProgramListIDs.Malwarebytes -y
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "Malwarebytes Uninstalled!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Failed to uninstall Malwarebytes!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "Malwarebytes Uninstall Skipped!" >> $ScriptLogfileLoc
            }

            # BCUninstaller
            if ((-not $BCPreInstallCheck -and -not $NoBC) -or $ForceUninstall) {
                choco uninstall $ProgramListIDs.BulkCrapUninstaller -ItemType
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "BulkCrapUninstaller Uninstalled!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Failed to uninstall BulkCrapUninstaller!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "BulkCrapUninstaller Uninstall Skipped!" >> $ScriptLogfileLoc
            }

            # Remove ADWCleaner folder if installed by us
            if (-not $NoADW) {
                Remove-Item -path "$Env:SystemDrive\AdwCleaner" -Recurse -Force -ErrorAction SilentlyContinue
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "AdwCleaner Folder Deleted!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Failed to delete ADWCleaner Folder!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "AdwCleaner Folder Removal Skipped!" >> $ScriptLogfileLoc
            }

            # Remove Chocolatey
            if ((-not $NoInstall -or -not $KeepChoco) -or $ForceUninstall) {
                Remove-Item -Path $Env:ChocolateyInstall -Recurse -Force -ErrorAction SilentlyContinue
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "Chocolatey Uninstalled!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Failed to uninstall Chocolatey!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "Chocolatey Uninstall Skipped!" >> $ScriptLogfileLoc
            }
        }
    }

    if ($Winget) {
        # Cleanup what was installed via the script
        if (-not $NoUninstall -or $ForceUninstall) {
            # Malwarebyts
            if ((-not $MBPreInstalledCheck -and -not $NoMB) -or $ForceUninstall) {
                Winget Uninstall $ProgramListIDs.Malwarebytes
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "Malwarebytes Uninstalled!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Failed to uninstall Malwarebytes!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "Malwarebytes Uninstall Skipped!" >> $ScriptLogfileLoc
            }

            # BCUninstaller
            if ((-not $BCPreInstallCheck -and -not $NoBC) -or $ForceUninstall) {
                Winget Uninstall $ProgramListIDs.BulkCrapUninstaller
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "BulkCrapUninstaller Uninstalled!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Failed to uninstall BulkCrapUninstaller!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "BulkCrapUninstaller Uninstall Skipped!" >> $ScriptLogfileLoc
            }

            # Remove ADWCleaner folder if installed by us
            if (-not $NoADW) {
                Remove-Item -path "$Env:SystemDrive\AdwCleaner" -Recurse -Force -ErrorAction SilentlyContinue
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "AdwCleaner Folder Deleted!" >> $ScriptLogfileLoc
                }
                else {
                    Write-Output "Failed to delete ADWCleaner Folder!" >> $ScriptLogfileLoc
                }
            }
            else {
                Write-Output "AdwCleaner Folder Removal Skipped!" >> $ScriptLogfileLoc
            }
        }
    }

    if (-not $NoDC -or $ForceDCRegRemoval) {
        foreach ($Regpath in $DCRegPath) {
            Remove-ItemProperty -Path $Regpath -Name "StateFlags$DCSetValue" -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

    # Remove Module - Doesnt work for some reason so commented out
    #if (-not $NoUpdate) {
    #    Remove-Module PSWindowsUpdate -Force
    #    Uninstall-Module PSWindowsUpdate
    #}

    # Wait a few seconds just in case before next step
    Start-Sleep -seconds 5

    # Restart PC
    if (-not $NoRestart) {
        Restart-Computer
    }
}
else {
    Write-Host "Try again and please choose one package manager!"
    Pause
}
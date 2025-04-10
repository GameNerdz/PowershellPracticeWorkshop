# New-SemesterFolder
# Creates Folders for College Semester in OneDrive folders and Custom locations, such as class folders, week folders and assignment folders.
# Joseph Wahba

# Settings Phase

# Check where the user wants the folder to be created
$LocationCheck = Read-Host 'Where do you want to create the semester folder? Enter:
"Home" for OneDrive home root folder
"Work" for OneDrive commercial root folder
Leave blank for a custom folder location.

Input'

# Read LocationCheck and Set as Path
switch ($LocationCheck) {
    "Home" {$PathLoc = $env:OneDrive}
    "Work" {$PathLoc = $env:OneDriveCommercial}
    Default {
        Add-Type -AssemblyName System.Windows.Forms
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
            RootFolder            = "MyComputer"
            Description           = "$Env:ComputerName - Select a folder"
        }
        $Null = $FolderBrowser.ShowDialog()
        $PathLoc = $FolderBrowser.SelectedPath
    }
}
#Write Folder path
Write-Host "The folder path is: $PathLoc"

# Check if User wants weekly folders
do {
    $WeekFolderCheck = Read-Host "Do you want week folders? Y/N"
    switch ($WeekFolderCheck) {
        Y {Write-Host "Continuing with creating week folders."}
        N {Write-Host "Skipping creating week folders."}
        Default {Write-Host "Invalid entry. Please enter again"}
    }
} until (
    $WeekFolderCheck -eq 'Y' -xor $WeekFolderCheck -eq 'N'
)

# If WeekfolderCheck is Y, Determine how many weeks a semester is.
if ($WeekFolderCheck -eq "Y") {
        [Int]$Weeks = Read-Host "How many weeks is your semester? (Leave blank for default: 14 weeks)"

    if ($Weeks -eq 14 -xor $Weeks -eq 0 ) {
        $Weeks = 14
        Write-Host "Using default weeks setting: $Weeks"
    }
    else {
        Write-Host "Weeks setting set to: $Weeks"
    }
}

# Check if user wants assignment folders
do {
    $AssignmentFolderCheck = Read-Host 'Do you want an Assignments folder to be created in each class/course folder or in each week folder?
    "C" for the Assignments folder to be made in each Class/Course folder.
    "W" for the Assignments folder to be made in each Week folder.
    "N" to skip making an assignments folder all together.

    Input'
    switch ($AssignmentFolderCheck) {
        C {Write-Host "Creating asignments folders in class/course folders."}
        W {
            if ($WeekFolderCheck -eq "Y") {
                Write-Host "Creating asignments folders in week folders."
            }
            else {
                Write-Host "Week Folders are not enabled! Please re-run script and enable week folders!"
                Exit
            }
        }
        N {Write-Host "Skipping creating assignments folders"}
        Default {Write-Host "Invalid entry. Please enter again"}
    }
} until (
    $AssignmentFolderCheck -eq 'C' -xor $AssignmentFolderCheck -eq 'W' -xor $AssignmentFolderCheck -eq 'N'
)

# Creation Phase
$Semester = Read-Host "What semester are you creating folders for?"
$TestPath = Test-Path -Path "$PathLoc\Semester $Semester\"
if ($TestPath -eq $false) {
    New-Item -Path "$PathLoc\" -name "Semester $Semester" -ItemType Directory
    Write-Output " Created: $Path\Semester $Semester\"
} else {
    Write-Output "Location Exists: Skipping over creating folder"
}

do {
    $Class = Read-Host 'Enter your class name or the course code. Enter "End" to end'
    if ($Class -ne "End") {
        $TestPath = Test-Path -Path "$PathLoc\Semester $Semester\$Class\"
        if ($TestPath -eq $false) {
            New-Item -Path "$PathLoc\Semester $Semester\" -Name $Class -ItemType Directory
            Write-Output " Created: $Path\Semester $Semester\$Class\"
        }
        if ($WeekFolderCheck -eq "Y") {
            for ($i = 1; $i -le $Weeks; $i++) {
                $TestPath = Test-Path -Path "$PathLoc\Semester $Semester\$Class\Week $i\"
                if ($TestPath -eq $false) {
                    New-Item -Path "$PathLoc\Semester $Semester\$Class\" -Name "Week $i" -ItemType Directory
                    if ($AssignmentFolderCheck -eq "W") {
                        New-Item -Path "$PathLoc\Semester $Semester\$Class\Week $i" -Name "Assignments" -ItemType Directory
                    }
                    Write-Output "Created: Week folders"
                    if ($AssignmentFolderCheck -eq "W") {
                        Write-Output "Created Assignment folders in Week folders."
                    }
                }
            }
        }
        if ($AssignmentFolderCheck -eq "C") {
            $TestPath = Test-Path -Path "$PathLoc\Semester $Semester\$Class\Assignments\"
            if ($TestPath -eq $false) {
                New-Item -Path "$PathLoc\Semester $Semester\$Class\" -Name "Assignments" -ItemType Directory
                Write-Output "Created: Assignment folder"
            }
        }
    }
} until (
    $Class -eq "End"
)
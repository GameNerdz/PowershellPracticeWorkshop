# New-SemesterFolder
# Creates Folders for College Semester in OneDrive folder, Including Week Folders.
# Joseph Wahba

#Require -Version 7.5

# Check where the user wants the folder to be created
$LocationCheck = Read-Host 'Where do you want to create the semester folder? Enter:
"Home" for OneDrive Home root folder
"Work" for OneDrive Commercial root folder
Leave blank for a custom folder location.

Input:'

# Read LocationCheck and Set as Path
switch ($LocationCheck) {
    "Home" {$PathLoc = $env:OneDrive}
    "Work" {$PathLoc = $env:OneDriveCommercial}
    Default {
        $PathLoc = Read-Host "Please enter the custom folder locaton"
        $PathTest = Test-Path $PathLoc
        if (!$PathTest) {
            New-Item -Path $PathLoc -ItemType Directory
            Write-Host "Created: $PathLoc"
        }
    }
}

Write-Output "The folder path is: $PathLoc"

# Create Root Sememster Folder
$Semester = Read-Host "What Semester are you creating folders for?"
New-Item -Path "$PathLoc\" -name "Semester $Semester" -ItemType Directory
Write-Output " Created: $Path\Semester $Semester\"

# Check if User wants weekly folders
do {
    $WeekFolderCheck = Read-Host "Do you want Week folders? Y/N"
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
    # Check how many weeks the semester is
        [Int]$Weeks = Read-Host "How many weeks is your Semester? (Leave Blank for Default: 14 Weeks)"

    if ($Weeks -eq 14 -xor $Weeks -eq 0 ) {
        $Weeks = 14
        Write-Host "Using default weeks setting: $Weeks"
    }
    else {
        Write-Host "Weeks setting set to: $Weeks"
    }
}

# Create Class Folders
do {
    $Class = Read-Host 'Enter "CourseCode - Course Name". "End" to end'
    if ($Class -ne "End") {
        New-Item -Path "$PathLoc\Semester $Semester\" -Name $Class -ItemType Directory
        Write-Output " Created: $Path\Semester $Semester\$Class"
        if ($WeekFolderCheck -eq "Y") {
            for ($i = 1; $i -le $Weeks; $i++) {
                New-Item -Path "$PathLoc\Semester $Semester\$Class\" -Name "Week $i" -ItemType Directory
            }
            Write-Output "Created: Week Folders"
        }
    }
} until (
    $Class -eq "End"
)
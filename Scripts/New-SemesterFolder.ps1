# New-SemesterFolder
# Creates Folders for College Semester in OneDrive folder, Including Week Folders.
# Joseph Wahba

#Require -Version 7.5

# Check where the user wants the folder to be created
$LocationCheck = Read-Host 'Where do you want to create the Semester folder? Enter:
"Home" for OneDrive Home Root Folder
"Work" for OneDrive Commercial Root Folder
A file Path for a Custom Location'

# Read LocationCheck and Set as Path
if ($LocationCheck -eq "Home") {
    $PathLoc = $env:OneDrive
}
elseif ($LocationCheck -eq "Work") {
    $PathLoc = $env:OneDriveCommercial
}
else {
    $PathLoc = $LocationCheck
}
Write-Output "The Location Path is: $PathLoc"

# Create Root Sememster Folder
$Semester = Read-Host "What Semester are you creating folders for?"
New-Item -Path "$PathLoc\" -name "Semester $Semester" -ItemType Directory
Write-Output " Created: $Path\Semester $Semester\"

# Check if User wants weekly folders
do {
    $WeekFolderCheck = Read-Host "Do you want Week Folders? Y/N"
} until (
    $WeekFolderCheck -eq 'Y' -or $WeekFolderCheck -eq 'N'
)

if ($WeekFolderCheck -eq "Y") {
    # Check how many weeks the semester is
    [int]$Weeks = Read-Host "How many weeks is your Semester? (Leave Blank for Default: 13 Weeks)"

    if ($Weeks -eq 13 -xor $Weeks -eq 0 ) {
        $Weeks = 13
        Write-Host "Using default weeks setting: $Weeks"
    }
    else {
        Write-Host "Weeks setting set to: $Weeks"
    }

}
else {
    Write-Host "Continuing on without creation of Week Folders"
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
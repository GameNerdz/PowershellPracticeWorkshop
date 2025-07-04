# Sort-MusicFiles
# Sorts Music Files by creating a folder and then moving music files with filenames that match your input(s) into the folder.
# This script is probably useless to most but its something I currently need and its good practice.
# Joseph Wahba

$MusicFileTypes = @("*.mp3", "*.aac", "*.wav", "*.flac", "*.m4a")

do {
    # Locate Music Folder
    Write-Host "Please select where your music is located."
    Add-Type -AssemblyName System.Windows.Forms
    $MusicLoc = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        InitialDirectory = [System.Environment]::GetFolderPath('MyMusic')
}
    $null = $MusicLoc.ShowDialog()
    Write-Host "Folder Path set to: $($MusicLoc.SelectedPath)"

    # Ask User for file query(?) info
    $UserQueryInput = Read-Host 'Please enter the strings you want to identify music files for (For example if your sorting multiple music files that contain "Bob" in the name, enter "Bob") Seperate strings with ","'
    $MusicQuery = $UserQueryInput.Split(',')

    # Ask User For Sorting New Folder Name
    Write-Host "Select Where you want your music to be sorted to."
    Add-Type -AssemblyName System.Windows.Forms
    $SortLoc = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        InitialDirectory = [System.Environment]::GetFolderPath('MyMusic')
}
    $null = $SortLoc.ShowDialog()
    Write-Host "Folder Path set to: $($SortLoc.SelectedPath)"

    # Find and move Music Files!
    $MusicFiles = Get-ChildItem -Path "$($MusicLoc.SelectedPath)\*" -File -Include $MusicFileTypes
    foreach ($line in $MusicQuery) {
        $QueryMatch = $MusicFiles | Where-Object -Property Name -Match $line
            foreach ($file in $QueryMatch) {
                Move-Item -Path $file.FullName -Destination $SortLoc.SelectedPath
            }
    }

    $EndTaskCheck = Read-Host "Do you want to sort another music file? Y/N"
    do {
        switch ($EndTaskCheck) {
            Y {$EndTaskCheck = "Continue"}
            N {$EndTask = $true}
            Default {
                Write-Host "Invalid entry. Please enter again."
            }
    }
    } until (
    ($EndTaskCheck -eq "Continue") -or ($EndTask -eq $true)
)

} until (
    $EndTask -eq $true
)

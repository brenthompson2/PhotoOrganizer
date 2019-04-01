# ============================================================================================== 
# NAME: PhotosByMonth.ps1
# 
# UPDATED: Brendan Thompson
# DATE: 31 March 2019
#
# AUTHOR:  Kim Oppalfens, 
# DATE  : 12/2/2007
# 
# COMMENT: Helps you organize your digital photos into subdirectories based on the picture's Exif meta data 
# Based on the date picture taken property the pictures will be organized into <SourceFolderPath>\Sorted\YYYY\YYYY-MM
# ============================================================================================== 

# Listen for arguments
[CmdletBinding()]
param ( )

# Add Dependencies
[reflection.assembly]::loadfile( "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll")
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

# Get the source folder
$PATH = Split-Path -parent $PSCommandPath
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.SelectedPath = $PATH;
$folderBrowser.Description = "Select Source folder"
$folderBrowser.rootfolder = "MyComputer"
if($folderBrowser.ShowDialog() -eq "OK")
{
  $sourceFolderPath += $folderBrowser.SelectedPath
}
else
{
  Write-Host "Failed to select source folder. Returning..." 
  return
}
Write-Verbose "Source Folder: $sourceFolderPath"

# Copy each photo into the sorted directory structure
$Files = Get-ChildItem -path $sourceFolderPath -recurse
foreach ($file in $Files) 
{
  # Handle .jpg
  if ($file.Extension -eq ".jpg")
  {
    # Get the photo as a bitmap
    $photoAsBitmap = New-Object -TypeName system.drawing.bitmap -ArgumentList $file.fullname 

    # Parse the photo date from the bitmap
    $foundDate = $FALSE
    try
    {
      $date = $photoAsBitmap.GetPropertyItem(36867).value[0..9]  
      $yearArray = [Char]$date[0],[Char]$date[1],[Char]$date[2],[Char]$date[3]
      $year = [String]::Join("",$yearArray)
      $monthArray = [Char]$date[5],[Char]$date[6]
      $month = [String]::Join("",$monthArray)
      $dayArray = [Char]$date[8],[Char]$date[9]
      $day = [String]::Join("",$dayArray)
      $foundDate = $TRUE
    }
    catch [ArgumentException]
    {
      Write-Warning "Unable to get meta data for file $file.Name"
    }

    if ($foundDate)
    {
      # Create the sorted path based off the photo date
      $DateTaken = $year + "-" + $month
      $TargetPath = $sourceFolderPath + "\Sorted\" + $year + "\" + $DateTaken
      $newFilename = $DateTaken + "-" + $day + "_" + $file.Name
      $TargetPathWithRename = $TargetPath + "\" + $newFilename
    }
    else
    {
      $TargetPath = $sourceFolderPath + "\Unsorted\"
      $TargetPathWithRename = $TargetPath + $file.Name
    }
  }
  else
  {   
    # Handle all other file types 
    $TargetPath = $sourceFolderPath + "\Other\"
    $TargetPathWithRename = $TargetPath + $file.Name
  }
  
  # Copy the file to the new folder
  Write-Verbose "Destination Folder: $TargetPathWithRename"
  if (Test-Path $TargetPath)
  {
    copy-item $file.FullName $TargetPathWithRename
  }
  else
  {
    New-Item $TargetPath -Type Directory
    copy-item $file.FullName $TargetPathWithRename
  }
}
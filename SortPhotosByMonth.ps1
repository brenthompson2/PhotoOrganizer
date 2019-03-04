﻿# ============================================================================================== 
# NAME: PhotosByMonth.ps1
# 
# UPDATED: Brendan Thompson
# DATE: 03 March 2019
#
# AUTHOR:  Kim Oppalfens, 
# DATE  : 12/2/2007
# 
# COMMENT: Helps you organise your digital photos into subdirectories based on the picture's Exif meta data 
# Based on the date picture taken property the pictures will be organized into <SourceFolderPath>\Sorted\YYYY\YYYY-MM
# ============================================================================================== 

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
Write-Host $sourceFolderPath

# Copy each photo into the sorted directory structure
$Files = Get-ChildItem -path $sourceFolderPath -recurse -filter *.jpg
foreach ($file in $Files) 
{
  # Get the photo as a bitmap
  $photoAsBitmap = New-Object -TypeName system.drawing.bitmap -ArgumentList $file.fullname 

  # Parse the photo date from the bitmap
  $date = $photoAsBitmap.GetPropertyItem(36867).value[0..9]  
  $yearArray = [Char]$date[0],[Char]$date[1],[Char]$date[2],[Char]$date[3]
  $year = [String]::Join("",$yearArray)
  $monthArray = [Char]$date[5],[Char]$date[6]
  $month = [String]::Join("",$monthArray)
  $dayArray = [Char]$date[8],[Char]$date[9]
  $day = [String]::Join("",$dayArray)

  # Create the sorted path based off the photo date
  $DateTaken = $year + "-" + $month
  $TargetPath = $sourceFolderPath + "\Sorted\" + $year + "\" + $DateTaken
  
  # Copy the file to the new folder
  If (Test-Path $TargetPath)
  {
    xcopy /Y/Q $file.FullName $TargetPath
  }
  Else
  {
    New-Item $TargetPath -Type Directory
    xcopy /Y/Q $file.FullName $TargetPath
  }
}
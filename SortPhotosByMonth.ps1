# ============================================================================================== 
# NAME: PhotosByMonth.ps1
# 
# UPDATED: Brendan Thompson
# DATE: 03 March 2019
#
# AUTHOR:  Kim Oppalfens, 
# DATE  : 12/2/2007
# 
# COMMENT: Helps you organise your digital photos into subdirectories based on the picture's Exif meta data 
# Based on the date picture taken property the pictures will be organized into c:\RecentlyUploadedPhotos\YYYY\YYYY-MM
# ============================================================================================== 

# Add Dependencies
[reflection.assembly]::loadfile( "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll")
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

# Get Folder
$path = Split-Path -parent $PSCommandPath
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.SelectedPath = $path;
$folderBrowser.Description = "Select a folder"
$folderBrowser.rootfolder = "MyComputer"
if($folderBrowser.ShowDialog() -eq "OK")
{
    $folder += $folderBrowser.SelectedPath
}
Write-Host $folder

$Files = Get-ChildItem -path $folder -recurse -filter *.jpg
foreach ($file in $Files) 
{
  # Get the image as a bitmap
  $imageAsBitmap = New-Object -TypeName system.drawing.bitmap -ArgumentList $file.fullname 

  # Parse the date from the bitmap
  $date = $imageAsBitmap.GetPropertyItem(36867).value[0..9]  
  $yearArray = [Char]$date[0],[Char]$date[1],[Char]$date[2],[Char]$date[3]
  $year = [String]::Join("",$yearArray)
  $monthArray = [Char]$date[5],[Char]$date[6]
  $month = [String]::Join("",$monthArray)
  $dayArray = [Char]$date[8],[Char]$date[9]
  $day = [String]::Join("",$dayArray)

  # Get the folder name from the date
  $DateTaken = $year + "-" + $month + "-" + $day
  $TargetPath = "c:\RecentlyUploadedPhotos\" + $year + "\" + $DateTaken
  
  # Copy the file to new folder
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
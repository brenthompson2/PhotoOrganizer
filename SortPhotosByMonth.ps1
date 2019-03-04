# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 4.1
# 
# NAME: OrgPhotos.ps1
# 
# UPDATED: Steve Smith
# DATE: 18 January 2009
# COMMENT: Changed file paths and confirmed it works.  Note that file extension must be .psONE not .psELL
#
# AUTHOR:  Kim Oppalfens, 
# DATE  : 12/2/2007
# 
# COMMENT: Helps you organise your digital photos into subdirectory, based on the Exif data 
# found inside the picture. Based on the date picture taken property the pictures will be organized into
# c:\RecentlyUploadedPhotos\YYYY\YYYY-MM-DD
# ============================================================================================== 

[reflection.assembly]::loadfile( "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll") 

$Files = Get-ChildItem -recurse -filter *.jpg
foreach ($file in $Files) 
{
  $foo=New-Object -TypeName system.drawing.bitmap -ArgumentList $file.fullname 

#each character represents an ascii code number 0-10 is date 
#10th character is space separator between date and time
#48 = 0 49 = 1 50 = 2 51 = 3 52 = 4 53 = 5 54 = 6 55 = 7 56 = 8 57 = 9 58 = : 
#date is in YYYY/MM/DD format
  $date = $foo.GetPropertyItem(36867).value[0..9]
  $arYear = [Char]$date[0],[Char]$date[1],[Char]$date[2],[Char]$date[3]
  $arMonth = [Char]$date[5],[Char]$date[6]
  $arDay = [Char]$date[8],[Char]$date[9]
  $strYear = [String]::Join("",$arYear)
  $strMonth = [String]::Join("",$arMonth) 
  $strDay = [String]::Join("",$arDay)
  $DateTaken = $strYear + "-" + $strMonth + "-" + $strDay
  $TargetPath = "c:\RecentlyUploadedPhotos\" + $strYear + "\" + $DateTaken
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


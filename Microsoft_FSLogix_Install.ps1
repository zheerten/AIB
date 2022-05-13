<# 
.SYNOPSIS
    This script performs the installation of the latest version of Microsoft FSLogix
.DESCRIPTION 
    The script pulls the latest setup files for Microsoft FSLogix before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/13/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install latest version of Microsoft FSLogix'
$Directory = 'Microsoft_FSLogix'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Download Micorosft FSLogix
Write-Host 'AIB Customization: Downloading FsLogix'
$fsLogixURL="https://aka.ms/fslogix_download"
$installerFile="fslogix_download.zip"

Invoke-WebRequest $fsLogixURL -OutFile $LocalPath\$installerFile
Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath
Write-Host 'AIB Customization: Download Fslogix installer finished'
#endregion

#region Install Microsoft FSLogix
try {
     Write-Host 'AIB Customization: Starting installation of the latest version of Microsoft FSLogix'
     Start-Process -FilePath C:\Build\Microsoft_FSLogix\x64\Release\FSLogixAppsSetup.exe -Wait -ErrorAction Stop -ArgumentList "/install /quiet"
     Write-Host 'AIB Customization: Finished installing the latest version of Microsoft FSLogix'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Microsoft FSLogix - ERROR: $ErrorMessage"
}
#endregion
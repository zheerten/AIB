<# 
.SYNOPSIS
    This script performs the installation of the latest version of Microsoft M365 Apps for Enterprise
.DESCRIPTION 
    The script pulls the configuration files for Microsoft M365 Apps for Enterprise before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/16/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install latest version of Microsoft M365 Apps'
$Directory = 'Microsoft_M365_Apps'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Download Micorosft M365 Apps for Enterprise Configuration Files
Write-Host 'AIB Customization: Downloading M365 Apps Configuration Files'
$M365ArtifactsURL="https://saaibfp1cushub.blob.core.windows.net/azure-image-builder/M365_Apps.zip"
$installerFile="M365_Apps.zip"
$installerDirectory="M365_Apps"
$InstallPath = $LocalPath + '\' + $installerDirectory

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $M365ArtifactsURL -OutFile $LocalPath\$installerFile
Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath -Force
Remove-Item -Path $LocalPath\$installerFile -Force -ErrorAction SilentlyContinue
$ProgressPreference = 'Continue'

Set-Location $InstallPath
Write-Host 'AIB Customization: Downloading M365 Apps Configuration Files finished'
#endregion

#region Install Microsoft M365 Apps for Enterprise
try {
     Write-Host 'AIB Customization: Starting installation of the latest version of Microsoft M365 Apps for Enterprise'
     Start-Process -FilePath "setup.exe" -Wait -ErrorAction Stop -ArgumentList "/configure AVD_No_Access.xml"
     Write-Host 'AIB Customization: Finished installing the latest version of Microsoft M365 Apps for Enterprise'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Microsoft M365 Apps for Enterprise - ERROR: $ErrorMessage"
}
#endregion
<# 
.SYNOPSIS
    This script performs the installation of the ProofPoint Encryption and SecureShare Plugins.
.DESCRIPTION 
    The script pulls the setup files for ProofPoint Encryption and SecureShare Plugins before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/18/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install ProofPoint Encryption and SecureShare Plugins'
$Directory = 'ProofPoint_Plugins'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Download ProofPoint plugin setup files
Write-Host 'AIB Customization: Downloading ProofPoint setup files'
$ProofPointArtifactsURL="https://saaibfp1cushub.blob.core.windows.net/azure-image-builder/ProofPoint_Apps.zip"
$installerFile="ProofPoint_Apps.zip"
$installerDirectory="ProofPoint_Apps"
$InstallPath = $LocalPath + '\' + $installerDirectory

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $ProofPointArtifactsURL -OutFile $LocalPath\$installerFile
Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath -Force
Remove-Item -Path $LocalPath\$installerFile -Force -ErrorAction SilentlyContinue
$ProgressPreference = 'Continue'

Set-Location $InstallPath
Write-Host 'AIB Customization: Downloading ProofPoint setup files finished'
#endregion


#region Install ProofPoint Encryption Plugin
$encryptionMSI = "PE_Plugin_Outlook_1.3.9.5_x64.msi"
try {
     Write-Host 'AIB Customization: Starting installation of the ProofPoint Encryption Plugin'
     Start-Process -filepath msiexec.exe -Wait -ErrorAction Stop -ArgumentList '/i', "$encryptionMSI", 'REBOOT=ReallySuppress', '/qn'
     Write-Host 'AIB Customization: Finished installing the ProofPoint Encryption Plugin'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing the ProofPoint Encryption Plugin - ERROR: $ErrorMessage"
}
#endregion

#region Install ProofPoint SecureShare Plugin
$secureShareMSI = "ProofpointSecureSharePlugin_1.3.20.0_x64.msi"
try {
     Write-Host 'AIB Customization: Starting installation of the ProofPoint SecureShare Plugin'
     Start-Process -filepath msiexec.exe -Wait -ErrorAction Stop -ArgumentList '/i', "$secureShareMSI", 'REBOOT=ReallySuppress', '/qn'
     Write-Host 'AIB Customization: Finished installing the ProofPoint Encryption Plugin'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing the ProofPoint SecureShare Plugin - ERROR: $ErrorMessage"
}
#endregion
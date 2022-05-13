<# 
.SYNOPSIS
    This script performs the installation of the latest version of Azure Information Protection
.DESCRIPTION 
    The script pulls the latest setup files for Azure Information Protection before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/13/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install latest version of Azure Information Protection'
$Directory = 'Microsoft_AIP'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Install Microsoft AIP
try {
     $aipURL = 'https://download.microsoft.com/download/4/9/1/491251F7-46BA-46EC-B2B5-099155DD3C27/AzInfoProtection_UL.msi'
     $aipURLmsi = 'AzInfoProtection_UL.msi'
     $outputPath = $LocalPath + '\' + $aipURLmsi
     Invoke-WebRequest -Uri $aipURL -OutFile $outputPath
     Write-Host 'AIB Customization: Starting installation of the latest version of Microsoft Azure Information Protection'
     Start-Process -filepath msiexec.exe -Wait -ErrorAction Stop -ArgumentList '/i', "$outputPath", 'REBOOT=ReallySuppress', '/qn'
     Write-Host 'AIB Customization: Finished installing the latest version of Microsoft Azure Information Protection'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Microsoft Azure Information Protection - ERROR: $ErrorMessage"
}
#endregion
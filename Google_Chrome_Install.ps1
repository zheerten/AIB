<# 
.SYNOPSIS
    This script performs the installation of the latest version of Google Chrome
.DESCRIPTION 
    The script pulls the latest setup files for Google Chrome before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/13/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install latest version of Google Chrome'
$Directory = 'Google_Chrome'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Install Google Chrome
try {
     $chromeURL = 'https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi'
     $chromeURLmsi = 'GoogleChromeStandaloneEnterprise64.msi'
     $outputPath = $LocalPath + '\' + $chromeURLmsi
     Invoke-WebRequest -Uri $chromeURL -OutFile $outputPath
     Write-Host 'AIB Customization: Starting installation of the latest version of Google Chrome'
     Start-Process -filepath msiexec.exe -Wait -ErrorAction Stop -ArgumentList '/i', "$outputPath", 'REBOOT=ReallySuppress', '/qn'
     Write-Host 'AIB Customization: Finished installing the latest version of Google Chrome'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Google Chrome - ERROR: $ErrorMessage"
}
#endregion
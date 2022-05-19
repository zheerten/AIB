<# 
.SYNOPSIS
    This script performs the installation of the Crowdstrike Falcon Sensor for VDI
.DESCRIPTION 
    The script pulls the setup files for the Crowdstrike Falcon sensor before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/18/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install Crowdstrike Falcon Sensor'
$Directory = 'CrowdStrike_Falcon'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Download Crowdstrike Falcon Sensor
Write-Host 'AIB Customization: Downloading Crowdstrike'
$CrowdStrikeURL="https://saaibfp1cushub.blob.core.windows.net/azure-image-builder/Crowdstrike_App.zip"
$installerFile="Crowdstrike_App.zip"

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $CrowdStrikeURL -OutFile $LocalPath\$installerFile
Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath -Force
Remove-Item -Path $LocalPath\$installerFile -Force -ErrorAction SilentlyContinue
$ProgressPreference = 'Continue'

Write-Host 'AIB Customization: Download of CrowdStrike Falcon Sensor finished'
#endregion

#region Install Microsoft FSLogix
try {
     Write-Host 'AIB Customization: Starting installation of the CrowdStrike Falcon Sensor'
     Start-Process -FilePath C:\Build\CrowdStrike_Falcon\Crowdstrike_App\WindowsSensor.exe -Wait -ErrorAction Stop -ArgumentList "/install /quiet /norestart CID=8E465457F7524514B96B25C42760EB28-38 NO_START=1 VDI=1"
     Write-Host 'AIB Customization: Finished installing the CrowdStrike Falcon Sensor'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing CrowdStrike Falcon Sensor - ERROR: $ErrorMessage"
}
#endregion
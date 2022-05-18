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
$CrowdStrikeURL="https://saaibfs1cushub.blob.core.windows.net/scripts/Crowdstrike_App.zip?sp=r&st=2022-05-18T19:48:54Z&se=2025-05-19T03:48:54Z&spr=https&sv=2020-08-04&sr=b&sig=AjKgwJQeydXjzdqXmR%2F2dELyW2T7qE%2FMLumEvlKWSH0%3D"
$installerFile="Crowdstrike_App.zip"

Invoke-WebRequest $CrowdStrikeURL -OutFile $LocalPath\$installerFile
Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath
Write-Host 'AIB Customization: Download of CrowdStrike Falcon Sensor finished'
#endregion

#region Install Microsoft FSLogix
try {
     Write-Host 'AIB Customization: Starting installation of the CrowdStrike Falcon Sensor'
     Start-Process -FilePath C:\Build\CrowdStrike_Falcon\Crowdstrike_App\WindowsSensor.exe -Wait -ErrorAction Stop -ArgumentList "/install CID=8E465457F7524514B96B25C42760EB28-38 NO_START=1 VDI=1"
     Write-Host 'AIB Customization: Finished installing the CrowdStrike Falcon Sensor'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing CrowdStrike Falcon Sensor - ERROR: $ErrorMessage"
}
#endregion
<# 
.SYNOPSIS
    This script performs the installation of the Tenable Nessus Agent for VDI
.DESCRIPTION 
    The script pulls the setup files for the Tenable Nessus Agent before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/19/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install Tenable Nessus Agent'
$Directory = 'Tenable_Nessus'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Download Tenable Nessus Agent
Write-Host 'AIB Customization: Downloading Tenable Nessus Agent'
$TenableURL="https://saaibfp1cushub.blob.core.windows.net/azure-image-builder/Tenable_App.zip"
$installerFile="Tenable_App.zip"
$tenableMSI=""

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $TenableURL -OutFile $LocalPath\$installerFile
Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath -Force
Remove-Item -Path $LocalPath\$installerFile -Force -ErrorAction SilentlyContinue
$ProgressPreference = 'Continue'

Write-Host 'AIB Customization: Download of Tenable Nessus Agent finished'
#endregion

#region Install Tenable Nessus Agent
try {
     Write-Host 'AIB Customization: Starting installation of the Tenable Nessus Agent'
     Start-Process -filepath msiexec.exe -Wait -ErrorAction Stop -ArgumentList '/i', "$tenableMSI", 'NESSUS_GROUPS="Workstations', 'NESSUS_SERVER="cloud.tenable.com:443"', 'NESSUS_KEY=6a420fd3a6052cc761eb71fe757e232dca372076b9894abfc1bc8502412de805', 'REBOOT=ReallySuppress', '/qn'
     Execute-Process -Path "C:\Program Files\Tenable\Nessus Agent\nessuscli.exe" -Parameters 'prepare-image'
     Write-Host 'AIB Customization: Finished installing the Tenable Nessus Agent'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Tenable Nessus Agent - ERROR: $ErrorMessage"
}
#endregion
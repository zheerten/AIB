<# 
.SYNOPSIS
    This script performs the installation of the latest version of Microsoft Teams for VDI
.DESCRIPTION 
    The script pulls the latest setup files for Microsoft Teams before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/13/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Install Microsoft Teams'
$Directory = 'Microsoft_Teams'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Set Required Registry Key
write-host 'AIB Customization: Set required regKey'
try {
    New-Item -Path HKLM:\SOFTWARE\Microsoft -Name "Teams" 
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Teams -Name "IsWVDEnvironment" -Type "Dword" -Value "1"
    write-host 'AIB Customization: Finished Set required regKey'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong setting required Microsoft Teams registry key - ERROR: $ErrorMessage"
}
#endregion

#region Install Web Socket Service
Write-Host 'AIB Customization: Install the Teams WebSocket Service'
try {
    $webSocketsURL = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt'
    $webSocketsInstallerMsi = 'webSocketSvc.msi'
    $outputPath = $LocalPath + '\' + $webSocketsInstallerMsi
    Invoke-WebRequest -Uri $webSocketsURL -OutFile $outputPath
    Start-Process -FilePath msiexec.exe -Args "/I $outputPath /quiet /norestart /log webSocket.log" -Wait
    Write-Host 'AIB Customization: Finished installing the Teams WebSocket Service'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing the Teams WebSocket Service - ERROR: $ErrorMessage"
}
#endregion

#region Install Microsoft Teams
Write-Host 'AIB Customization: Install MS Teams'
try {
    $teamsURL = 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true'
    $teamsMsi = 'teams.msi'
    $outputPath = $LocalPath + '\' + $teamsMsi
    Invoke-WebRequest -Uri $teamsURL -OutFile $outputPath
    Start-Process -FilePath msiexec.exe -Args "/I $outputPath /quiet /norestart /log teams.log ALLUSER=1 ALLUSERS=1" -Wait
    write-host 'AIB Customization: Finished Install MS Teams'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing MS Teams - ERROR: $ErrorMessage"
}
#endregion
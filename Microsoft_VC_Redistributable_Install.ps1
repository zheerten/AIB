<# 
.SYNOPSIS
    This script performs the installation of the latest Microsoft Visual C++ Redistributables (x64/x86)
.DESCRIPTION 
    The script pulls the latest x64/x86 setup files for Visual C++ from Microsoft sources before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/13/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Installing the latest Microsoft Visual C++ Redistributable'
$Directory = 'Microsoft_VC_Redistributable'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Install x64 c++ redistributable
try {
     $visCplusURL = 'https://aka.ms/vs/17/release/vc_redist.x64.exe'
     $visCplusURLexe = 'vc_redist.x64.exe'
     $outputPath = $LocalPath + '\' + $visCplusURLexe
     Invoke-WebRequest -Uri $visCplusURL -OutFile $outputPath
     Write-Host 'AIB Customization: Starting installation of the latest Microsoft Visual C++ Redistributable (x64)'
     Start-Process -FilePath $outputPath -Args "/install /quiet /norestart /log vcdist64.log" -Wait
     Write-Host 'AIB Customization: Finished installing the latest Microsoft Visual C++ Redistributable (x64)'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Microsoft Visual C++ Redistributable x64 - ERROR: $ErrorMessage"
}
#endregion

#region Install x86 c++ redistributable
try {
    $visCplusURL = 'https://aka.ms/vs/17/release/vc_redist.x86.exe'
    $visCplusURLexe = 'vc_redist.x86.exe'
    $outputPath = $LocalPath + '\' + $visCplusURLexe
    Invoke-WebRequest -Uri $visCplusURL -OutFile $outputPath
    Write-Host 'AIB Customization: Starting installation of the latest Microsoft Visual C++ Redistributable (x86)'
    Start-Process -FilePath $outputPath -Args "/install /quiet /norestart /log vcdist86.log" -Wait
    Write-Host 'AIB Customization: Finished installing the latest Microsoft Visual C++ Redistributable (x86)'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Microsoft Visual C++ Redistributable x86 - ERROR: $ErrorMessage"
}
#endregion
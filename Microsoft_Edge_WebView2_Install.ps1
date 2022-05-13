<# 
.SYNOPSIS
    This script performs the installation of the latest Microsoft Edge WebView 2 Plugin
.DESCRIPTION 
    The script pulls the latest setup files for Microsoft Edge WebView 2 Plugin before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/13/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Installing the latest Microsoft Edge WebView 2 Plugin'
$Directory = 'Microsoft_VC_Redistributable'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Install Microsoft WebView 2 Plugin
try {
     $webView2URL = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/59b78510-f596-45fa-a7f8-521bca3d99b2/MicrosoftEdgeWebView2RuntimeInstallerX64.exe'
     $webView2URLexe = 'MicrosoftEdgeWebView2RuntimeInstallerX64.exe'
     $outputPath = $LocalPath + '\' + $webView2URLexe
     Invoke-WebRequest -Uri $webView2URL -OutFile $outputPath
     Write-Host 'AIB Customization: Starting installation of the latest Microsoft Edge WebView 2 Plugin'
     Start-Process -FilePath $outputPath -Args "/install /quiet /norestart /log webview2.log" -Wait
     Write-Host 'AIB Customization: Finished installing the latest Microsoft Edge WebView 2 Plugin'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing Microsoft Edge WebView 2 Plugin - ERROR: $ErrorMessage"
}
#endregion
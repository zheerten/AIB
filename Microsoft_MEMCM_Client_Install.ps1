<# 
.SYNOPSIS
    This script performs the installation of the Microsoft Endpoint Manager Configuration Manager Client (MEMCM/SCCM)
.DESCRIPTION 
    The script pulls the setup files for MEMCM before silently installing on the local machine.
    This script was designed for use within the Azure Image Builder customization phase.
.NOTES 
    Version History:
        1.0 - 05/19/2022 - Zach Heerten
#>

#region Create folder / set path
Write-Host 'AIB Customization: Installing the SCCM Client'
$Directory = 'Microsoft_SCCM_Client'
$Path = 'C:\Build'
New-Item -Path $Path -Name $Directory  -ItemType Directory -ErrorAction SilentlyContinue -Force
$LocalPath = $Path + '\' + $Directory 
Set-Location $LocalPath
#endregion

#region Install MEMCM Client
try {
     $sccmClientArtifactsURL = 'https://saaibfp1cushub.blob.core.windows.net/azure-image-builder/Microsoft_SCCM_Client.zip'
     $installerFile="Microsoft_SCCM_Client.zip"
     $installerDirectory="Microsoft_SCCM_Client"
     $installerEXE="ccmsetup.exe"
     $installPath = $LocalPath + '\' + $installerDirectory
     $outputPath = $LocalPath + '\' + $installerFile
     Invoke-WebRequest -Uri $sccmClientArtifactsURL -OutFile $outputPath
     Expand-Archive $LocalPath\$installerFile -DestinationPath $LocalPath -Force
     Set-Location $installPath

     Write-Host 'AIB Customization: Starting installation of the SCCM Client'
     Start-Process -FilePath $installerEXE -Args "CCMHOSTNAME=BCBSNEHUBCMG.NEBRASKABLUE.COM/CCM_Proxy_MutualAuth/72057594037927991 SMSSITECODE=P12 SMSCACHESIZE=30720 RESETKEYINFORMATION=TRUE DNSSUFFIX=BCBSNEPRD.COM CCMLOGMAXHISTORY=5 CCMLOGMAXSIZE=900000" -Wait
     Start-Sleep -s 300
     Write-Host 'AIB Customization: Finished installing the SCCM Client'
}
 catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong installing the SCCM Client - ERROR: $ErrorMessage"
}
#endregion

#region Prepare for sysprep
try {
    Write-Host 'Preparing SCCM Client for Sysprep'
        # Stop SCCM Client Service (if running)
        if (Get-Service ccmexec | where {$_.Status -eq 'Running'}) {
            Write-Host "SMS Agent Running..."
            Write-Host "Stopping SMS Agent Host Service"
            Get-Service ccmexec | Stop-Service -Force -ErrorAction SilentlyContinue
            Start-Sleep -s 5
        }
        else {
            Write-Host "SMS Agent Host Service not currently running"
        }

        # Delete SMSCFG.ini
        Write-Host "Deleting SMSCFG.ini"
        Remove-Item -Path "C:\Windows\SMSCFG.INI" -Force -ErrorAction SilentlyContinue
        Start-Sleep -s 5

        # Delete SMS Certificates
        Write-Host "Deleting SMS Certificates"
        Remove-Item -Path HKLM:\Software\Microsoft\SystemCertificates\SMS\Certificates\* -Force -ErrorAction SilentlyContinue
        Start-Sleep -s 5
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Host "Something went wrong preparing the SCCM client for sysprep - ERROR: $ErrorMessage"
}
#endregion
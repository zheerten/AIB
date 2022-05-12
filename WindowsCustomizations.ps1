<# 
.SYNOPSIS
    This script performs the customization of the Windows 10 operating system during the Azure Image Builder template build.
.DESCRIPTION 
    This script customizes the operating system according the Blue Cross and Blue Shield of Nebraska's standards.
    This script is designed to run under "SYSTEM" context during the Azure Image Builder customization phase.
    This script references resources stored in blob storage.  The URL contains a shared access signature (SAS) token used to grant restricted access to the resource.  These tokens expire every 2 years.
.NOTES 
    Information about the environment, things to need to be consider and other information.

.COMPONENT 
    Information about PowerShell Modules to be required.

.LINK 
    Useful Link to ressources or others.
 
.Parameter ParameterName 
    Description for a parameter in param definition section. Each parameter requires a separate description. The name in the description and the parameter section must match. 
#>

#region Configure Logging 
$logFile = "c:\temp\" + (get-date -format 'yyyyMMdd') + '_AIB_WindowsCustomizations.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

Write-Log 'AIB Customization: Windows Settings'

#region Download Artifacts
Write-Log 'Downloading Script Artifacts'
$Directory = 'Build'
$Drive = 'C:\'
New-Item -Path $Drive -Name $Directory -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = $Drive + $Directory
Set-Location $LocalPath

$ArtifactsURL = 'https://github.com/zheerten/AIB/raw/main/Windows_Customizations.zip'
$ArtifactsURLFile = 'Windows_Customizations.zip'
$ArtifactsURLFolder = 'Windows_Customizations'

$OutputPath = $LocalPath + '\' + $ArtifactsURLFile
Invoke-WebRequest -Uri $ArtifactsURL -OutFile $OutputPath
Write-Log 'Expanding Archive'
Expand-Archive -LiteralPath $OutputPath -DestinationPath $LocalPath -Force -Verbose
Write-Log "Files downloaded and extracted to $LocalPath\$ArtifactsURLFolder"
#endregion

#region Customize Wallpaper
try {
    Write-Log 'Starting Wallpaper Customization'
    .\Windows_Customizations\Wallpaper\ChangeWallpaper.ps1
    Write-Log 'Wallpaper Customization Complete'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Something went wrong customizing system wallpaper - ERROR: $ErrorMessage"
}
#endregion

#region Remove Taskbar Search
try {
    Write-Log 'Removing Taskbar Search'
    Start-Process -FilePath .\Windows_Customizations\TaskbarSearch\Deploy-Application.exe -Wait -ErrorAction Stop
    Write-Log 'Taskbar Search Removal Complete'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Something went wrong removing taskbar search - ERROR: $ErrorMessage"
}
#endregion

#region Change Start Layout
try {
    Write-Log 'Changing Start Layout'
    Import-StartLayout -LayoutPath .\Windows_Customizations\StartLayout\LayoutModification_010721.xml -MountPath C:\
    Write-Log 'Start Layout Imported'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Something went wrong importing start layout - ERROR: $ErrorMessage"
}
#endregion

#region Configure System Branding
try {
    Write-Log 'Configuring System Branding'
    Copy-Item -Path ".\Windows_Customizations\SystemBranding\OEMLogo\oemlogo.bmp" -Destination "C:\Windows\System32" -Force -ErrorAction Stop
    Start-Process -FilePath regedit.exe -ErrorAction Stop -ArgumentList @("/s", "`"C:\Build\Windows_Customizations\SystemBranding\SystemBranding.reg`"")
    Write-Log 'System Branding Configuration Complete'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Something went wrong configuring system branding - ERROR: $ErrorMessage"
}
#endregion

#region Install Screen Saver Content
try {
    Write-Log 'Installing Screen Saver Content'
    Start-Process -FilePath .\Windows_Customizations\ScreenSaver\Deploy-Application.exe -Wait -ErrorAction Stop
    Write-Log 'Screen Saver content copied to system'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Something went wrong installing screen saver content - ERROR: $ErrorMessage"
}
#endregion

#region Customize Lock Screen
try {
    Write-Log 'Starting Lock Screen Customization'
    Copy-Item -Path ".\Windows_Customizations\Lockscreen\LockScreen.jpg" -Destination "C:\ProgramData\BCBSNE\LockScreen\" -Force -ErrorAction Stop
    Start-Process -FilePath regedit.exe -ErrorAction Stop -ArgumentList @("/s", "`"C:\Build\Windows_Customizations\Lockscreen\LockScreen.reg`"")
    Write-Log 'Lock Screen Customization Complete'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Something went wrong customizing lock screen - ERROR: $ErrorMessage"
}
#endregion

#region Import Default App Associations
try {
    Write-Log 'Importing default app associations'
    Copy-Item -Path ".\Windows_Customizations\SystemBranding\OEMLogo\oemlogo.bmp" -Destination "C:\Windows\System32" -Force -ErrorAction Stop
    Start-Process -FilePath dism.exe -ErrorAction Stop -ArgumentList @("/online", "/Import-DefaultAppAssociations:`"C:\Build\Windows_Customizations\DefaultAppAssociation\DefaultAssociations_022420.xml`"")
    Write-Log 'Finished importing default app assoications'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Something went wrong importing default app associations - ERROR: $ErrorMessage"
}
#endregion

#region Import Code Signing Certificate
Write-Log 'Importing Code Signing Certificate'
$Key = "HKLM:\SOFTWARE\Policies\Microsoft\windows\WindowsUpdate"
$Name = "AcceptTrustedPublisherCerts"
$Value = "1"
try {
    if ((Get-ItemProperty $Key).PSObject.Properties.Name -contains $name) {
            Write-Log "Registry key already exists...updating $Name value"
            Set-ItemProperty -Path $Key -Name $Name -Value $Value
    }
    elseif (-not(Test-Path -Path $Key)) {
            Write-Log "Registry key does not exist...creating key $Key"
            New-Item -Path $Key -Force
            Write-Log "Registry value does not exist...setting value of $Name"
            New-ItemProperty -Path $Key -Name $Name -PropertyType DWord -Value $Value
    }
    else {
            Write-Log "Registry key does not exist....setting value of $Name"
            New-ItemProperty -Path $Key -Name $Name -PropertyType DWord -Value $Value
    }
    Import-Certificate -FilePath .\Windows_Customizations\CodeSigning\BCBSNEPRD_WSUS_Signing.cer -CertStoreLocation Cert:\LocalMachine\Root
    Import-Certificate -FilePath .\Windows_Customizations\CodeSigning\BCBSNEPRD_WSUS_Signing.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
    Write-Log 'Successfully imported code signing certificate'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to import code signing certificate ERROR: $ErrorMessage"
}
#endregion

#region Disable Consumer Features
Write-Log 'Disabling Windows Consumer Features'
$Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$Name = "DisableWindowsConsumerFeatures"
$Value = "1"
try {
    if ((Get-ItemProperty $Key).PSObject.Properties.Name -contains $name) {
            Write-Log "Registry key already exists...updating $Name value"
            Set-ItemProperty -Path $Key -Name $Name -Value $Value
    }
    elseif (-not(Test-Path -Path $Key)) {
            Write-Log "Registry key does not exist...creating key $Key"
            New-Item -Path $Key -Force
            Write-Log "Registry value does not exist...setting value of $Name"
            New-ItemProperty -Path $Key -Name $Name -PropertyType DWord -Value $Value
    }
    else {
            Write-Log "Registry key does not exist....setting value of $Name"
            New-ItemProperty -Path $Key -Name $Name -PropertyType DWord -Value $Value
    }
    Write-Log 'Successfully disabled Windows Consumer Features'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to disable Windows Consumer Features ERROR: $ErrorMessage"
}
#endregion

#region Time Zone Redirection
Write-Log "Configuring Time Zone Redirection"
$Name = "fEnableTimeZoneRedirection"
$value = "1"
# Add Registry value
try {
    New-ItemProperty -ErrorAction Stop -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services").PSObject.Properties.Name -contains $name) {
        Write-Log "Added time zone redirection registry key"
    }
    else {
        Write-Log "Error locating the Teams registry key"
    }
    Write-Log "Successfully configured Time Zone Redirection"
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Error adding teams registry KEY: $ErrorMessage"
}
#endregion

#region Disable Logon Animation
Write-Log 'Disabling Logon Animation'
$Name = "EnableFirstLogonAnimation"
$Value = "0"
try {
if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System").PSObject.Properties.Name -contains $name) {
        Write-Log "Registry key already exists...updating $Name value"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name $Name -Value $Value
    }
    else {
        Write-Log "Registry key does not exist...setting $Name value"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name $Name -PropertyType DWord -Value $Value
    }
    Write-Log 'Successfully disabled Logon Animation'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to disable Logon Animation ERROR: $ErrorMessage"
}
#endregion 

#region Show "Run as different user"
Write-Log 'Enabling Run As Different User'
$Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
$Name = "ShowRunasDifferentuserinStart"
$Value = "1"
try {
    if ((Get-ItemProperty $Key).PSObject.Properties.Name -contains $name) {
            Write-Log "Registry key already exists...updating $Name value"
            Set-ItemProperty -Path $Key -Name $Name -Value $Value
    }
    elseif (-not(Test-Path -Path $Key)) {
            Write-Log "Registry key does not exist...creating key $Key"
            New-Item -Path $Key -Force
            Write-Log "Registry value does not exist...setting value of $Name"
            New-ItemProperty -Path $Key -Name $Name -PropertyType DWord -Value $Value
    }
    else {
            Write-Log "Registry key does not exist....setting value of $Name"
            New-ItemProperty -Path $Key -Name $Name -PropertyType DWord -Value $Value
    }
    Write-Log 'Successfully enabled Run As Different User'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to enable Run As Different User ERROR: $ErrorMessage"
}
#endregion

#region Disable SMB1"
Write-Log 'Disabling SMB1 Protocol'
try {
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
    Write-Log 'Successfully disabled SMB1 Protocol'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to disable SMB1 Protocol ERROR: $ErrorMessage"
}
#endregion

#region Disable PowerShellv2"
Write-Log 'Disabling PowerShellv2'
try {
    Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart
    Write-Log 'Successfully disabled PowerShellv2'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to disable PowerShellv2 ERROR: $ErrorMessage"
}
#endregion

#region Enable .NET Framework 3.5"
Write-Log 'Enabling .NET Framework 3.5'
try {
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
    Write-Log 'Successfully enabled .NET Framework 3.5'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to enable .NET Framework 3.5 ERROR: $ErrorMessage"
}
#endregion

#region Sysprep Fix
# Fix for first login delays due to Windows Module Installer
try {
    ((Get-Content -path C:\DeprovisioningScript.ps1 -Raw) -replace 'Sysprep.exe /oobe /generalize /quiet /quit', 'Sysprep.exe /oobe /generalize /quit /mode:vm' ) | Set-Content -Path C:\DeprovisioningScript.ps1
    write-log "Sysprep Mode:VM fix applied"
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error updating script: $ErrorMessage"
}
#endregion

Write-Log 'AIB Customization: Windows Settings - COMPLETED'

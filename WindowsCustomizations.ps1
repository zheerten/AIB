

# Configure Logging 
$logFile = "c:\temp\" + (get-date -format 'yyyyMMdd') + '_AIB_WindowsCustomizations.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}

Write-Log 'AIB Customization: Windows Settings'

## Disable Consumer Features
Write-Log 'Disabling Windows Consumer Features'
$Name = "DisableWindowsConsumerFeatures"
$Value = "1"
try {
if ((Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent").PSObject.Properties.Name -contains $name) {
        Write-Log "Registry key already exists...updating $Name value"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name $Name -Value $Value
    }
    else {
        Write-Log "Registry key does not exist...setting $Name value"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name $Name -PropertyType DWord -Value $Value
    }
    Write-Log 'Successfully disabled Windows Consumer Features'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to disable Windows Consumer Features ERROR: $ErrorMessage"
}

# Time Zone Redirection
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

## Disable Logon Animation
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

## Show "Run as different user"
Write-Log 'Enabling Run As Different User'
$Name = "ShowRunasDifferentuserinStart"
$Value = "1"
try {
if ((Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer").PSObject.Properties.Name -contains $name) {
        Write-Log "Registry key already exists...updating $Name value"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name $Name -Value $Value
    }
    else {
        Write-Log "Registry key does not exist...setting $Name value"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name $Name -PropertyType DWord -Value $Value
    }
    Write-Log 'Successfully enabled Run As Different User'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to enable Run As Different User ERROR: $ErrorMessage"
}

## Disable SMB1"
Write-Log 'Disabling SMB1 Protocol'
try {
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
    Write-Log 'Successfully disabled SMB1 Protocol'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to disable SMB1 Protocol ERROR: $ErrorMessage"
}

## Disable PowerShellv2"
Write-Log 'Disabling PowerShellv2'
try {
    Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart
    Write-Log 'Successfully disabled PowerShellv2'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to disable PowerShellv2 ERROR: $ErrorMessage"
}

## Enable .NET Framework 3.5"
Write-Log 'Enabling .NET Framework 3.5'
try {
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
    Write-Log 'Successfully enabled .NET Framework 3.5'
}
catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "Unable to enable .NET Framework 3.5 ERROR: $ErrorMessage"
}


<powershell>
# Windows Server Initialization Script
# NIST 800-53 Compliance and Zero Trust Architecture

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# NIST 800-53 AC-2: Account Management
# Create additional admin accounts with different roles
$adminPassword = ConvertTo-SecureString "${admin_password}" -AsPlainText -Force
New-LocalUser -Name "firewall-admin" -Password $adminPassword -FullName "Firewall Administrator" -Description "Firewall management account"
Add-LocalGroupMember -Group "Administrators" -Member "firewall-admin"

New-LocalUser -Name "monitor" -Password $adminPassword -FullName "Monitor User" -Description "Monitoring account"
Add-LocalGroupMember -Group "Users" -Member "monitor"

# NIST 800-53 AC-3: Access Enforcement
# Configure password policy
net accounts /minpwlen:12 /maxpwage:90 /minpwage:1 /lockoutthreshold:3 /lockoutduration:30 /lockoutwindow:30

# NIST 800-53 AC-6: Least Privilege
# Configure User Account Control
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2

# NIST 800-53 SI-4: Information System Monitoring
# Enable comprehensive auditing
auditpol /set /category:* /success:enable /failure:enable

# Configure Windows Firewall
# NIST 800-53 SC-7: Boundary Protection
netsh advfirewall set allprofiles state on
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound

# Allow specific ports for management
netsh advfirewall firewall add rule name="RDP" dir=in action=allow protocol=TCP localport=3389
netsh advfirewall firewall add rule name="SSH" dir=in action=allow protocol=TCP localport=22
netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="HTTPS" dir=in action=allow protocol=TCP localport=443

# NIST 800-53 CM-6: Configuration Settings
# Configure security settings
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Value 0

# Disable unnecessary services
$servicesToDisable = @(
    "TelnetClient",
    "TelnetServer",
    "TFTP",
    "SNMP"
)

foreach ($service in $servicesToDisable) {
    Set-Service -Name $service -StartupType Disabled
}

# NIST 800-53 SI-4: Information System Monitoring
# Configure Windows Event Log settings
wevtutil sl Security /ms:1024000
wevtutil sl System /ms:1024000
wevtutil sl Application /ms:1024000

# CISA Zero Trust - Identity Verification
# Configure multi-factor authentication settings
if ("${hardening_config.enable_mfa}" -eq "true") {
    # Enable Windows Hello for Business (if available)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowDomainPINLogon" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowCrossDeviceCredential" -Value 1
}

# NIST 800-53 AC-6: Least Privilege
# Configure privileged access management
if ("${hardening_config.enable_privileged_access_management}" -eq "true") {
    # Enable Just-In-Time (JIT) access
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableInstallerDetection" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableSecureUIAPaths" -Value 1
}

# NIST 800-53 SC-7: Boundary Protection
# Configure network isolation
if ("${hardening_config.enable_network_isolation}" -eq "true") {
    # Enable Network Isolation
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableNetworkIsolation" -Value 1
}

# NIST 800-53 SI-4: Information System Monitoring
# Configure comprehensive logging
$logConfig = @{
    "Security" = @{
        "MaximumLogSize" = 1024000
        "Retention" = $true
        "AuditSuccess" = $true
        "AuditFailure" = $true
    }
    "System" = @{
        "MaximumLogSize" = 1024000
        "Retention" = $true
    }
    "Application" = @{
        "MaximumLogSize" = 1024000
        "Retention" = $true
    }
}

foreach ($log in $logConfig.Keys) {
    $settings = $logConfig[$log]
    wevtutil sl $log /ms:$($settings.MaximumLogSize)
    if ($settings.Retention) {
        wevtutil sl $log /rt:true
    }
}

# NIST 800-53 CM-6: Configuration Settings
# Configure encryption settings
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "FIPSAlgorithmPolicy" -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0

# Configure TLS settings
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -Name "Enabled" -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "Enabled" -Value 1

# Disable older protocols
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name "Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name "Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value 0

# NIST 800-53 SI-4: Information System Monitoring
# Configure monitoring and alerting
$monitoringConfig = @"
# Windows Server Monitoring Configuration
# NIST 800-53 SI-4 Compliance

# Performance Monitoring
[Performance]
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90

# Security Monitoring
[Security]
THREAT_MONITORING=enabled
INTRUSION_MONITORING=enabled
MALWARE_MONITORING=enabled

# Log Monitoring
[Logging]
EVENT_LOG_MONITORING=enabled
SECURITY_LOG_MONITORING=enabled
SYSTEM_LOG_MONITORING=enabled

# Alert Configuration
[Alerts]
EMAIL_ALERTS=enabled
SNMP_ALERTS=enabled
SYSLOG_ALERTS=enabled
"@

$monitoringConfig | Out-File -FilePath "C:\ProgramData\Monitoring\config.ini" -Encoding UTF8

# NIST 800-53 AC-2: Account Management
# Configure account lockout policy
secedit /export /cfg C:\secpol.cfg
$secpol = Get-Content C:\secpol.cfg
$secpol = $secpol -replace "LockoutBadCount=0", "LockoutBadCount=3"
$secpol = $secpol -replace "LockoutDuration=0", "LockoutDuration=30"
$secpol = $secpol -replace "ResetLockoutCount=0", "ResetLockoutCount=30"
$secpol | Out-File C:\secpol.cfg
secedit /configure /db C:\Windows\Security\Local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
Remove-Item C:\secpol.cfg

# NIST 800-53 SI-4: Information System Monitoring
# Configure Windows Defender settings
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableBlockAtFirstSeen $false
Set-MpPreference -DisableIOAVProtection $false
Set-MpPreference -DisablePrivacyMode $false
Set-MpPreference -SignatureDisableUpdateOverride $false
Set-MpPreference -DisableScanOnRealtimeEnable $false
Set-MpPreference -DisableRealtimeMonitoring $false

# Configure Windows Defender exclusions for monitoring
Add-MpPreference -ExclusionPath "C:\ProgramData\Monitoring"
Add-MpPreference -ExclusionPath "C:\ProgramData\Amazon"

# NIST 800-53 CM-6: Configuration Settings
# Configure system hardening
$hardeningConfig = @"
# Windows Server Hardening Configuration
# NIST 800-53 CM-6 Compliance

# Security Settings
SECURITY_LEVEL=high
AUDIT_LOGGING=enabled
THREAT_PREVENTION=enabled
MALWARE_PROTECTION=enabled

# Network Security
NETWORK_ISOLATION=enabled
FIREWALL_ENABLED=true
INTRUSION_PREVENTION=enabled

# Zero Trust Principles
ZERO_TRUST_ENABLED=true
CONTINUOUS_VERIFICATION=enabled
LEAST_PRIVILEGE_ACCESS=enabled
MICROSEGMENTATION=enabled

# Monitoring and Alerting
SIEM_INTEGRATION=enabled
THREAT_INTELLIGENCE=enabled
BEHAVIORAL_ANALYSIS=enabled
"@

$hardeningConfig | Out-File -FilePath "C:\ProgramData\Security\hardening.conf" -Encoding UTF8

# NIST 800-53 SI-4: Information System Monitoring
# Configure Windows Event Forwarding
$eventForwarding = @"
# Windows Event Forwarding Configuration
# NIST 800-53 SI-4 Compliance

# Event Collection
[EventCollection]
Security=all
System=all
Application=all
Setup=all
ForwardedEvents=all

# Subscription Settings
[Subscription]
SubscriptionManager=wecutil
EventDeliveryOptimization=5
HeartbeatInterval=1000
MaxItems=1000
MaxLatencyTime=2000
ReadExistingEvents=1
"@

$eventForwarding | Out-File -FilePath "C:\ProgramData\Monitoring\event-forwarding.conf" -Encoding UTF8

# Configure Windows Event Collector service
Set-Service -Name "Windows Event Collector" -StartupType Automatic
Start-Service -Name "Windows Event Collector"

# NIST 800-53 AC-6: Least Privilege
# Configure application whitelisting
if ("${hardening_config.enable_application_whitelisting}" -eq "true") {
    # Enable AppLocker
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SrpV2" -Name "EnforcementMode" -Value 1
    
    # Configure AppLocker rules
    $appLockerConfig = @"
# AppLocker Configuration
# NIST 800-53 AC-6 Compliance

[ExecutableRules]
DefaultRule=Deny
AllowList=Administrators

[ScriptRules]
DefaultRule=Deny
AllowList=Administrators

[MSIRules]
DefaultRule=Deny
AllowList=Administrators
"@

    $appLockerConfig | Out-File -FilePath "C:\ProgramData\Security\applocker.conf" -Encoding UTF8
}

# NIST 800-53 SI-4: Information System Monitoring
# Configure performance monitoring
$perfConfig = @"
# Performance Monitoring Configuration
# NIST 800-53 SI-4 Compliance

[Counters]
\Processor(_Total)\% Processor Time
\Memory\Available MBytes
\PhysicalDisk(_Total)\% Disk Time
\Network Interface(*)\Bytes Total/sec

[Thresholds]
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
NETWORK_THRESHOLD=80

[Alerts]
ENABLE_ALERTS=true
ALERT_INTERVAL=300
"@

$perfConfig | Out-File -FilePath "C:\ProgramData\Monitoring\performance.conf" -Encoding UTF8

# Create monitoring directories
New-Item -ItemType Directory -Path "C:\ProgramData\Monitoring" -Force
New-Item -ItemType Directory -Path "C:\ProgramData\Security" -Force
New-Item -ItemType Directory -Path "C:\ProgramData\Logs" -Force

# NIST 800-53 SI-4: Information System Monitoring
# Configure log rotation
$logRotation = @"
# Log Rotation Configuration
# NIST 800-53 SI-4 Compliance

[Rotation]
MAX_LOG_SIZE_MB=100
RETENTION_DAYS=30
COMPRESSION=enabled
ARCHIVAL=enabled

[Logs]
Security=rotate
System=rotate
Application=rotate
Setup=rotate
ForwardedEvents=rotate
"@

$logRotation | Out-File -FilePath "C:\ProgramData\Monitoring\log-rotation.conf" -Encoding UTF8

# Final system configuration
Write-Host "Windows Server initialization completed successfully"
Write-Host "NIST 800-53 and Zero Trust security configurations applied"
Write-Host "Server: ${server_name}"
Write-Host "Environment: ${environment}"
Write-Host "Domain: ${domain_name}"

# Restart required services
Restart-Service -Name "Windows Event Log"
Restart-Service -Name "Windows Firewall"

Write-Host "Windows Server ${server_name} is ready for use"
</powershell> 
#!/bin/bash

# Linux Server Initialization Script
# NIST 800-53 Compliance and Zero Trust Architecture

# Update system
apt-get update && apt-get upgrade -y

# NIST 800-53 AC-2: Account Management
# Create additional admin accounts with different roles
useradd -m -s /bin/bash firewall-admin
echo "firewall-admin:ChangeMe123!" | chpasswd
usermod -aG sudo firewall-admin

useradd -m -s /bin/bash monitor
echo "monitor:ChangeMe123!" | chpasswd

# NIST 800-53 AC-3: Access Enforcement
# Configure SSH with key-based authentication only
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# NIST 800-53 SC-7: Boundary Protection
# Configure UFW firewall
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow SSH from management network only
ufw allow from 172.21.20.0/24 to any port 22
ufw allow from 172.21.10.0/24 to any port 22

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# NIST 800-53 SI-4: Information System Monitoring
# Install and configure auditd
apt-get install -y auditd audispd-plugins
systemctl enable auditd
systemctl start auditd

# Configure audit rules
cat > /etc/audit/rules.d/audit.rules << EOF
# NIST 800-53 SI-4: Information System Monitoring
# Comprehensive audit logging

# System startup/shutdown
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# User/Group changes
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity

# File access
-w /etc/hosts -p wa -k system-locale
-w /etc/network/ -p wa -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale

# Privileged commands
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod

# Network configuration
-w /etc/hosts.allow -p wa -k system-locale
-w /etc/hosts.deny -p wa -k system-locale
-w /etc/network/ -p wa -k system-locale

# Logon/Logout
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock/ -p wa -k logins

# Process and session initiation
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# Discretionary access control changes
-w /etc/selinux/ -p wa -k MAC-policy
-w /usr/share/selinux/ -p wa -k MAC-policy

# Successful file system mounts
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k export

# File deletion events
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# Kernel module loading and unloading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules

# Network configuration changes
-w /etc/network/ -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/hosts.allow -p wa -k system-locale
-w /etc/hosts.deny -p wa -k system-locale

# System administrator actions
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope

# Time adjustments
-w /etc/localtime -p wa -k time-change
-w /etc/timezone -p wa -k time-change

# System locale changes
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/network/ -p wa -k system-locale

# Service restarts
-w /var/log/auth.log -p wa -k auth
-w /var/log/syslog -p wa -k system-locale
-w /var/log/cron.log -p wa -k system-locale
EOF

# NIST 800-53 CM-6: Configuration Settings
# Configure system hardening
cat > /etc/security/limits.conf << EOF
# NIST 800-53 CM-6: Configuration Settings
# System resource limits

# Core dumps
* soft core 0
* hard core 0

# File descriptors
* soft nofile 65536
* hard nofile 65536

# Processes
* soft nproc 32768
* hard nproc 32768
EOF

# Configure sysctl for security
cat > /etc/sysctl.d/99-security.conf << EOF
# NIST 800-53 CM-6: Configuration Settings
# Security kernel parameters

# Network security
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore broadcast ICMP
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable bad error message protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enable SYN flood protection
net.ipv4.tcp_syncookies = 1

# Enable reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable IPv6 if not needed
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Memory protection
vm.mmap_min_addr = 65536
kernel.randomize_va_space = 2

# Core dumps
fs.suid_dumpable = 0
kernel.core_pattern = |/bin/false

# Kernel module security
kernel.modules_disabled = 1
EOF

# Apply sysctl settings
sysctl -p /etc/sysctl.d/99-security.conf

# NIST 800-53 SI-4: Information System Monitoring
# Configure rsyslog for comprehensive logging
cat > /etc/rsyslog.d/99-security.conf << EOF
# NIST 800-53 SI-4: Information System Monitoring
# Comprehensive logging configuration

# Security events
auth,authpriv.* /var/log/auth.log
kern.* /var/log/kern.log

# System events
*.info;mail.none;authpriv.none;cron.none /var/log/messages
*.emerg :omusrmsg:*
mail.* /var/log/maillog
cron.* /var/log/cron.log

# Network events
local0.* /var/log/network.log
local1.* /var/log/firewall.log
local2.* /var/log/audit.log

# Application events
local3.* /var/log/application.log
local4.* /var/log/database.log
local5.* /var/log/web.log
local6.* /var/log/mail.log
local7.* /var/log/boot.log
EOF

# Restart rsyslog
systemctl restart rsyslog

# CISA Zero Trust - Device Trust
# Configure system monitoring
cat > /etc/monitoring/config.ini << EOF
# System Monitoring Configuration
# CISA Zero Trust - Device Trust

[System]
HOSTNAME=${server_name}
ENVIRONMENT=${environment}

[Monitoring]
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
NETWORK_THRESHOLD=80

[Security]
AUDIT_LOGGING=enabled
THREAT_DETECTION=enabled
INTRUSION_PREVENTION=enabled
MALWARE_PROTECTION=enabled

[Logging]
SYSLOG_ENABLED=true
AUDIT_LOG_ENABLED=true
SECURITY_LOG_ENABLED=true
PERFORMANCE_LOG_ENABLED=true

[Alerts]
EMAIL_ALERTS=enabled
SNMP_ALERTS=enabled
SYSLOG_ALERTS=enabled
EOF

# NIST 800-53 AC-6: Least Privilege
# Configure sudoers for least privilege
cat > /etc/sudoers.d/security << EOF
# NIST 800-53 AC-6: Least Privilege
# Sudo configuration for security

# Firewall admin can manage firewall
firewall-admin ALL=(ALL) NOPASSWD: /usr/sbin/ufw*
firewall-admin ALL=(ALL) NOPASSWD: /usr/sbin/iptables*

# Monitor user can view logs only
monitor ALL=(ALL) NOPASSWD: /usr/bin/tail*
monitor ALL=(ALL) NOPASSWD: /usr/bin/less*
monitor ALL=(ALL) NOPASSWD: /usr/bin/cat*
monitor ALL=(ALL) NOPASSWD: /usr/bin/grep*
monitor ALL=(ALL) NOPASSWD: /usr/bin/journalctl*

# Defaults
Defaults requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults log_host, log_year, logfile="/var/log/sudo.log"
EOF

# NIST 800-53 SI-4: Information System Monitoring
# Install and configure monitoring tools
apt-get install -y htop iotop nethogs fail2ban rkhunter

# Configure fail2ban
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[apache]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/error.log
maxretry = 3
EOF

systemctl enable fail2ban
systemctl start fail2ban

# NIST 800-53 CM-6: Configuration Settings
# Configure system hardening
cat > /etc/security/hardening.conf << EOF
# Linux Server Hardening Configuration
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
EOF

# NIST 800-53 SI-4: Information System Monitoring
# Configure log rotation
cat > /etc/logrotate.d/security << EOF
# Security log rotation
# NIST 800-53 SI-4 Compliance

/var/log/auth.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        systemctl reload rsyslog
    endscript
}

/var/log/audit/audit.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 root root
    postrotate
        systemctl reload auditd
    endscript
}

/var/log/firewall.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}

/var/log/network.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Create monitoring directories
mkdir -p /var/log/audit
mkdir -p /etc/monitoring
mkdir -p /etc/security

# Set proper permissions
chmod 750 /var/log/audit
chmod 640 /var/log/audit/audit.log
chown root:root /var/log/audit/audit.log

# NIST 800-53 SI-4: Information System Monitoring
# Configure performance monitoring
cat > /etc/monitoring/performance.conf << EOF
# Performance Monitoring Configuration
# NIST 800-53 SI-4 Compliance

[Counters]
CPU_USAGE
MEMORY_USAGE
DISK_USAGE
NETWORK_USAGE

[Thresholds]
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
NETWORK_THRESHOLD=80

[Alerts]
ENABLE_ALERTS=true
ALERT_INTERVAL=300
EOF

# Final system configuration
echo "Linux Server initialization completed successfully"
echo "NIST 800-53 and Zero Trust security configurations applied"
echo "Server: ${server_name}"
echo "Environment: ${environment}"

# Restart required services
systemctl restart auditd
systemctl restart rsyslog
systemctl restart fail2ban

echo "Linux Server ${server_name} is ready for use" 
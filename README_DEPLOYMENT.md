# Academic Infrastructure as Code - Deployment Guide

## Overview

This document provides comprehensive instructions for deploying the Academic Infrastructure as Code (IaC) environment. The infrastructure implements NIST 800-53 compliance and CISA Zero Trust architecture principles for educational purposes.

## Architecture Summary

### Network Zones
- **Critical Infrastructure Zone (172.21.10.0/24)**: Active Directory servers
- **Infrastructure Zone (172.21.20.0/24)**: Core infrastructure servers
- **Users Zone (172.21.30.0/24)**: Client machines
- **Dirty Zone (192.168.0.0/16)**: Untrusted network

### System Components
- **2 Active Directory Servers** (Windows Server 2022)
- **2 Windows Infrastructure Servers** (Windows Server 2022)
- **3 Linux Infrastructure Servers** (Debian 12)
- **5 Windows Clients** (Windows 11)
- **3 Linux Clients** (Debian 12)
- **1 Palo Alto Networks Firewall**

## Prerequisites

### Required Software
- **Terraform** (>= 1.0)
- **Ansible** (>= 2.9)
- **AWS CLI** (>= 2.0)
- **Python 3** (>= 3.8)
- **SSH client**

### AWS Requirements
- AWS account with appropriate permissions
- Configured AWS credentials (`aws configure`)
- Sufficient AWS service limits for the deployment

### Security Requirements
- Understanding of NIST 800-53 compliance requirements
- Familiarity with Zero Trust architecture principles
- Access to Palo Alto Networks licensing (if using production licenses)

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd academic-iac
```

### 2. Configure AWS Credentials
```bash
aws configure
```

### 3. Deploy Infrastructure
```bash
chmod +x deploy.sh
./deploy.sh deploy
```

## Detailed Deployment Process

### Phase 1: Infrastructure Provisioning (Terraform)

#### 1.1 Network Infrastructure
- VPC with CIDR `172.21.0.0/16`
- Subnets for each zone with proper routing
- Security groups with NIST 800-53 compliant rules
- NAT Gateway for private subnet internet access

#### 1.2 Security Groups
- **Critical Infrastructure**: Restricted access, AD replication ports
- **Infrastructure**: Management access, application ports
- **Users**: Client access, web browsing
- **Dirty**: Minimal access for monitoring only

#### 1.3 Server Provisioning
- Windows servers with encrypted EBS volumes
- Linux servers with security hardening
- Palo Alto Networks firewall with multi-interface setup

### Phase 2: Configuration Management (Ansible)

#### 2.1 Common Security Hardening
- Password policies (NIST 800-53 AC-2)
- Account management (NIST 800-53 AC-3)
- Access enforcement (NIST 800-53 AC-6)
- Audit logging (NIST 800-53 SI-4)

#### 2.2 Operating System Specific
- **Windows**: Group Policy, Windows Defender, UAC
- **Linux**: SELinux, AppArmor, fail2ban, auditd
- **Firewall**: Palo Alto Networks security policies

#### 2.3 Zero Trust Implementation
- Identity verification (CISA Zero Trust)
- Device trust validation
- Continuous monitoring
- Least privilege access

## Security Compliance

### NIST 800-53 Controls Implemented

#### Access Control (AC)
- **AC-2**: Account Management
- **AC-3**: Access Enforcement
- **AC-6**: Least Privilege

#### Configuration Management (CM)
- **CM-6**: Configuration Settings
- **CM-7**: Least Functionality

#### System and Communications Protection (SC)
- **SC-7**: Boundary Protection
- **SC-8**: Transmission Confidentiality and Integrity

#### System and Information Integrity (SI)
- **SI-4**: Information System Monitoring
- **SI-7**: Software and Information Integrity

### CISA Zero Trust Implementation

#### Identity Verification
- Multi-factor authentication
- Strong password policies
- Account lockout mechanisms

#### Device Trust
- Endpoint security validation
- Device encryption
- Security posture assessment

#### Network Segmentation
- Zone-based isolation
- Micro-segmentation
- Traffic monitoring

## Configuration Files

### Terraform Configuration
```
terraform/
├── main.tf                 # Main infrastructure configuration
├── variables.tf            # Variable definitions
├── modules/
│   ├── networking/         # Network infrastructure
│   ├── palo_alto_firewall/ # Firewall configuration
│   ├── windows_servers/    # Windows server modules
│   └── linux_servers/      # Linux server modules
└── ssh/                    # SSH key storage
```

### Ansible Configuration
```
ansible/
├── playbooks/
│   └── main.yml           # Main configuration playbook
├── roles/
│   ├── common/            # Common security hardening
│   ├── security/          # Security controls
│   ├── monitoring/        # Monitoring configuration
│   └── compliance/        # Compliance validation
└── inventory/             # Dynamic inventory
```

## Deployment Commands

### Full Deployment
```bash
./deploy.sh deploy
```

### Infrastructure Only (Terraform)
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Configuration Only (Ansible)
```bash
cd ansible
ansible-playbook -i inventory/hosts.yml playbooks/main.yml
```

### Security Validation
```bash
cd ansible
ansible-playbook -i inventory/hosts.yml playbooks/security_validation.yml
```

### Compliance Check
```bash
cd ansible
ansible-playbook -i inventory/hosts.yml playbooks/compliance_check.yml
```

## Monitoring and Logging

### CloudWatch Integration
- System metrics collection
- Log aggregation
- Performance monitoring
- Security event logging

### Security Monitoring
- Intrusion detection
- Threat prevention
- Behavioral analysis
- Compliance reporting

### Log Management
- Centralized logging
- Log retention policies
- Audit trail maintenance
- Security event correlation

## Troubleshooting

### Common Issues

#### Terraform Errors
```bash
# Validate configuration
terraform validate

# Check state
terraform show

# Refresh state
terraform refresh
```

#### Ansible Errors
```bash
# Test connectivity
ansible all -m ping

# Check inventory
ansible-inventory --list

# Verbose output
ansible-playbook -vvv playbooks/main.yml
```

#### Security Issues
```bash
# Check security groups
aws ec2 describe-security-groups

# Verify firewall rules
aws ec2 describe-network-acls

# Test connectivity
telnet <host> <port>
```

### Log Locations
- **Terraform**: `terraform/terraform.tfstate`
- **Ansible**: `ansible/inventory/hosts.yml`
- **System Logs**: `/var/log/` (Linux), Event Viewer (Windows)
- **Security Logs**: `/var/log/audit/` (Linux), Security Event Log (Windows)

## Security Best Practices

### Network Security
- Use security groups to restrict access
- Implement network segmentation
- Monitor network traffic
- Use encrypted communications

### System Security
- Regular security updates
- Strong authentication
- Principle of least privilege
- Continuous monitoring

### Data Protection
- Encrypt data at rest
- Encrypt data in transit
- Implement backup strategies
- Secure data disposal

## Compliance Validation

### NIST 800-53 Assessment
```bash
# Run compliance checks
./scripts/compliance_check.sh

# Generate compliance report
./scripts/generate_compliance_report.py
```

### Zero Trust Validation
```bash
# Validate identity verification
./scripts/identity_validation.sh

# Test device trust
./scripts/device_trust_test.sh

# Verify network segmentation
./scripts/network_segmentation_test.sh
```

## Cost Optimization

### AWS Cost Management
- Use appropriate instance types
- Implement auto-scaling
- Monitor resource usage
- Clean up unused resources

### Resource Optimization
- Right-size instances
- Use spot instances where appropriate
- Implement cost alerts
- Regular cost reviews

## Maintenance and Updates

### Regular Maintenance
- Security patch management
- Configuration drift detection
- Performance monitoring
- Capacity planning

### Update Procedures
- Test updates in staging
- Use blue-green deployment
- Maintain rollback procedures
- Document changes

## Disaster Recovery

### Backup Strategy
- Automated daily backups
- Cross-region replication
- Point-in-time recovery
- Regular backup testing

### Recovery Procedures
- Document recovery steps
- Test recovery procedures
- Maintain recovery documentation
- Regular disaster recovery drills

## Support and Documentation

### Documentation
- Architecture diagrams
- Configuration guides
- Troubleshooting guides
- Compliance documentation

### Support Contacts
- Infrastructure team
- Security team
- Compliance team
- Vendor support

## Legal and Compliance

### Academic Use
- This infrastructure is for educational purposes only
- Not intended for production use
- Follow institutional policies
- Respect privacy requirements

### Compliance Requirements
- NIST 800-53 compliance
- CISA Zero Trust implementation
- Institutional security policies
- Data protection regulations

## Conclusion

This deployment guide provides comprehensive instructions for implementing a secure, compliant infrastructure using Infrastructure as Code principles. The implementation follows NIST 800-53 and CISA Zero Trust frameworks while maintaining educational focus.

For additional support or questions, please refer to the project documentation or contact the development team.

---

**Note**: This infrastructure is designed for academic and educational purposes only. It implements security best practices but should not be used in production environments without proper review and customization. 
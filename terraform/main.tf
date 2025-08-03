terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Academic-IaC"
      Environment = "Academic"
      Owner       = "Academic-Project"
      Purpose     = "Educational"
    }
  }
}

# VPC and Network Infrastructure
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr_block = var.vpc_cidr_block
  environment    = var.environment
  
  # Zone CIDR blocks following NIST 800-53 network segmentation
  zones = {
    critical_infrastructure = "172.21.10.0/24"  # Active Directory servers
    infrastructure         = "172.21.20.0/24"  # Core infrastructure servers
    users                 = "172.21.30.0/24"  # Client machines
    dirty                 = "192.168.0.0/16"   # Untrusted zone
  }
}

# Palo Alto Networks Firewall
module "palo_alto_firewall" {
  source = "./modules/palo_alto_firewall"
  
  vpc_id                    = module.networking.vpc_id
  subnet_ids                = module.networking.subnet_ids
  environment               = var.environment
  firewall_instance_type    = var.firewall_instance_type
  key_name                 = aws_key_pair.iac_key.key_name
  
  depends_on = [module.networking]
}

# Active Directory Servers (Critical Infrastructure Zone)
module "active_directory" {
  source = "./modules/windows_servers"
  
  count = 2
  
  server_name     = "dc-0${count.index + 1}"
  instance_type   = var.ad_instance_type
  subnet_id       = module.networking.subnet_ids["critical_infrastructure"]
  security_groups = [module.networking.security_groups["critical_infrastructure"]]
  key_name        = aws_key_pair.iac_key.key_name
  environment     = var.environment
  
  # NIST 800-53 AC-2: Account Management
  # NIST 800-53 AC-3: Access Enforcement
  # NIST 800-53 AC-6: Least Privilege
  hardening_config = {
    enable_audit_logging = true
    enforce_password_policy = true
    enable_smart_card_auth = true
    restrict_admin_access = true
    enable_privileged_access_management = true
  }
  
  depends_on = [module.networking, module.palo_alto_firewall]
}

# Infrastructure Zone - Windows Servers
module "infrastructure_windows" {
  source = "./modules/windows_servers"
  
  count = 2
  
  server_name     = "infra-win-0${count.index + 1}"
  instance_type   = var.infrastructure_instance_type
  subnet_id       = module.networking.subnet_ids["infrastructure"]
  security_groups = [module.networking.security_groups["infrastructure"]]
  key_name        = aws_key_pair.iac_key.key_name
  environment     = var.environment
  
  # CISA Zero Trust - Identity Verification
  # NIST 800-207 Zero Trust Architecture
  hardening_config = {
    enable_audit_logging = true
    enforce_password_policy = true
    enable_mfa = true
    restrict_admin_access = true
    enable_privileged_access_management = true
    enable_network_isolation = true
  }
  
  depends_on = [module.networking, module.palo_alto_firewall]
}

# Infrastructure Zone - Linux Servers
module "infrastructure_linux" {
  source = "./modules/linux_servers"
  
  count = 3
  
  server_name     = "infra-linux-0${count.index + 1}"
  instance_type   = var.infrastructure_instance_type
  subnet_id       = module.networking.subnet_ids["infrastructure"]
  security_groups = [module.networking.security_groups["infrastructure"]]
  key_name        = aws_key_pair.iac_key.key_name
  environment     = var.environment
  
  # NIST 800-53 SI-4: Information System Monitoring
  # CISA Zero Trust - Device Trust
  hardening_config = {
    enable_audit_logging = true
    enable_syslog = true
    restrict_ssh_access = true
    enable_firewall = true
    enable_selinux = true
    enable_privileged_access_management = true
    enable_network_isolation = true
  }
  
  depends_on = [module.networking, module.palo_alto_firewall]
}

# Users Zone - Windows Clients
module "windows_clients" {
  source = "./modules/windows_clients"
  
  count = 5
  
  client_name     = "win-client-0${count.index + 1}"
  instance_type   = var.client_instance_type
  subnet_id       = module.networking.subnet_ids["users"]
  security_groups = [module.networking.security_groups["users"]]
  key_name        = aws_key_pair.iac_key.key_name
  environment     = var.environment
  
  # CISA Zero Trust - User Trust
  # NIST 800-207 Zero Trust Architecture
  hardening_config = {
    enable_audit_logging = true
    enforce_password_policy = true
    enable_mfa = true
    restrict_admin_access = true
    enable_device_encryption = true
    enable_network_isolation = true
    enable_application_whitelisting = true
  }
  
  depends_on = [module.networking, module.palo_alto_firewall]
}

# Users Zone - Linux Clients
module "linux_clients" {
  source = "./modules/linux_clients"
  
  count = 3
  
  client_name     = "linux-client-0${count.index + 1}"
  instance_type   = var.client_instance_type
  subnet_id       = module.networking.subnet_ids["users"]
  security_groups = [module.networking.security_groups["users"]]
  key_name        = aws_key_pair.iac_key.key_name
  environment     = var.environment
  
  # CISA Zero Trust - Device Trust
  # NIST 800-207 Zero Trust Architecture
  hardening_config = {
    enable_audit_logging = true
    enable_syslog = true
    restrict_ssh_access = true
    enable_firewall = true
    enable_device_encryption = true
    enable_network_isolation = true
    enable_application_whitelisting = true
  }
  
  depends_on = [module.networking, module.palo_alto_firewall]
}

# SSH Key Pair for all instances
resource "aws_key_pair" "iac_key" {
  key_name   = "iac-academic-key-${var.environment}"
  public_key = file("${path.module}/ssh/iac_key.pub")
}

# Outputs for Ansible integration
output "inventory" {
  description = "Ansible inventory data"
  value = {
    active_directory_servers = module.active_directory[*].private_ip
    infrastructure_windows   = module.infrastructure_windows[*].private_ip
    infrastructure_linux     = module.infrastructure_linux[*].private_ip
    windows_clients         = module.windows_clients[*].private_ip
    linux_clients           = module.linux_clients[*].private_ip
    palo_alto_firewall      = module.palo_alto_firewall.private_ip
    vpc_id                  = module.networking.vpc_id
    subnet_ids              = module.networking.subnet_ids
  }
} 
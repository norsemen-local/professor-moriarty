#!/bin/bash

# Academic Infrastructure as Code Deployment Script
# NIST 800-53 Compliance and Zero Trust Architecture

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="academic-iac"
ENVIRONMENT="academic"
AWS_REGION="us-east-1"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        error "Terraform is not installed. Please install Terraform first."
    fi
    
    # Check if Ansible is installed
    if ! command -v ansible &> /dev/null; then
        error "Ansible is not installed. Please install Ansible first."
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        error "AWS CLI is not installed. Please install AWS CLI first."
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials are not configured. Please run 'aws configure' first."
    fi
    
    # Check if SSH key exists
    if [ ! -f "terraform/ssh/iac_key" ]; then
        error "SSH key not found. Please generate SSH key pair first."
    fi
    
    log "Prerequisites check passed."
}

# Generate SSH key pair
generate_ssh_keys() {
    log "Generating SSH key pair..."
    
    mkdir -p terraform/ssh
    ssh-keygen -t rsa -b 4096 -f terraform/ssh/iac_key -N "" -C "academic-iac@$(hostname)"
    
    log "SSH key pair generated successfully."
}

# Initialize Terraform
init_terraform() {
    log "Initializing Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Validate Terraform configuration
    terraform validate
    
    log "Terraform initialized successfully."
}

# Plan Terraform deployment
plan_terraform() {
    log "Planning Terraform deployment..."
    
    cd terraform
    
    # Create Terraform plan
    terraform plan -out=tfplan
    
    log "Terraform plan created successfully."
}

# Apply Terraform deployment
apply_terraform() {
    log "Applying Terraform deployment..."
    
    cd terraform
    
    # Apply Terraform configuration
    terraform apply tfplan
    
    # Get outputs for Ansible
    terraform output -json > ../ansible/inventory/terraform_output.json
    
    log "Terraform deployment completed successfully."
}

# Generate Ansible inventory
generate_ansible_inventory() {
    log "Generating Ansible inventory..."
    
    cd ansible
    
    # Create inventory directory
    mkdir -p inventory
    
    # Generate inventory from Terraform outputs
    python3 scripts/generate_inventory.py
    
    log "Ansible inventory generated successfully."
}

# Run Ansible playbooks
run_ansible() {
    log "Running Ansible playbooks..."
    
    cd ansible
    
    # Run main playbook
    ansible-playbook -i inventory/hosts.yml playbooks/main.yml --private-key=../terraform/ssh/iac_key
    
    log "Ansible playbooks completed successfully."
}

# Security validation
security_validation() {
    log "Running security validation..."
    
    cd ansible
    
    # Run security validation playbook
    ansible-playbook -i inventory/hosts.yml playbooks/security_validation.yml --private-key=../terraform/ssh/iac_key
    
    log "Security validation completed successfully."
}

# Compliance check
compliance_check() {
    log "Running compliance check..."
    
    cd ansible
    
    # Run compliance check playbook
    ansible-playbook -i inventory/hosts.yml playbooks/compliance_check.yml --private-key=../terraform/ssh/iac_key
    
    log "Compliance check completed successfully."
}

# Generate documentation
generate_documentation() {
    log "Generating documentation..."
    
    # Generate infrastructure documentation
    python3 scripts/generate_docs.py
    
    log "Documentation generated successfully."
}

# Cleanup function
cleanup() {
    log "Cleaning up temporary files..."
    
    # Remove Terraform plan file
    rm -f terraform/tfplan
    
    # Remove temporary inventory files
    rm -f ansible/inventory/terraform_output.json
    
    log "Cleanup completed."
}

# Main deployment function
deploy() {
    log "Starting Academic Infrastructure as Code deployment..."
    log "Project: $PROJECT_NAME"
    log "Environment: $ENVIRONMENT"
    log "AWS Region: $AWS_REGION"
    
    # Check prerequisites
    check_prerequisites
    
    # Generate SSH keys if they don't exist
    if [ ! -f "terraform/ssh/iac_key" ]; then
        generate_ssh_keys
    fi
    
    # Initialize Terraform
    init_terraform
    
    # Plan Terraform deployment
    plan_terraform
    
    # Ask for confirmation
    echo
    warning "This will deploy the following infrastructure:"
    echo "- 2 Active Directory servers (Critical Infrastructure Zone)"
    echo "- 2 Windows Server 2022 (Infrastructure Zone)"
    echo "- 3 Debian 12 Linux servers (Infrastructure Zone)"
    echo "- 5 Windows 11 clients (Users Zone)"
    echo "- 3 Debian 12 Linux clients (Users Zone)"
    echo "- 1 Palo Alto Networks firewall"
    echo
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Deployment cancelled by user."
        exit 0
    fi
    
    # Apply Terraform deployment
    apply_terraform
    
    # Generate Ansible inventory
    generate_ansible_inventory
    
    # Run Ansible playbooks
    run_ansible
    
    # Security validation
    security_validation
    
    # Compliance check
    compliance_check
    
    # Generate documentation
    generate_documentation
    
    # Cleanup
    cleanup
    
    log "Academic Infrastructure as Code deployment completed successfully!"
    log "Infrastructure is now ready for use."
    
    # Display summary
    echo
    info "Deployment Summary:"
    echo "=================="
    echo "Project: $PROJECT_NAME"
    echo "Environment: $ENVIRONMENT"
    echo "AWS Region: $AWS_REGION"
    echo "Compliance: NIST 800-53, CISA Zero Trust"
    echo
    info "Access Information:"
    echo "=================="
    echo "SSH Key: terraform/ssh/iac_key"
    echo "Terraform State: terraform/terraform.tfstate"
    echo "Ansible Inventory: ansible/inventory/hosts.yml"
    echo
    info "Next Steps:"
    echo "============"
    echo "1. Review the generated documentation"
    echo "2. Test connectivity to all systems"
    echo "3. Verify security configurations"
    echo "4. Run compliance validation tests"
    echo
    warning "Remember: This is an academic environment for educational purposes only."
}

# Destroy infrastructure
destroy() {
    log "Destroying infrastructure..."
    
    cd terraform
    
    # Plan destruction
    terraform plan -destroy -out=tfplan
    
    # Ask for confirmation
    echo
    warning "This will destroy all infrastructure components. This action cannot be undone."
    read -p "Do you want to proceed with destruction? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Destruction cancelled by user."
        exit 0
    fi
    
    # Apply destruction
    terraform apply tfplan
    
    log "Infrastructure destroyed successfully."
}

# Show help
show_help() {
    echo "Academic Infrastructure as Code Deployment Script"
    echo "=============================================="
    echo
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  deploy    Deploy the complete infrastructure"
    echo "  destroy   Destroy the infrastructure"
    echo "  plan      Show Terraform plan without applying"
    echo "  validate  Validate Terraform configuration"
    echo "  help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0 deploy    # Deploy the infrastructure"
    echo "  $0 destroy   # Destroy the infrastructure"
    echo "  $0 plan      # Show deployment plan"
    echo
    echo "Environment Variables:"
    echo "  AWS_PROFILE    AWS profile to use"
    echo "  AWS_REGION     AWS region for deployment"
    echo
}

# Main script logic
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    plan)
        cd terraform
        terraform plan
        ;;
    validate)
        cd terraform
        terraform validate
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac 
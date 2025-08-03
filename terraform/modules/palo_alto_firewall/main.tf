# Palo Alto Networks Firewall Instance
resource "aws_instance" "palo_alto_firewall" {
  ami           = var.palo_alto_ami
  instance_type = var.firewall_instance_type
  key_name      = var.key_name
  
  # Network interfaces for different zones
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.management.id
  }
  
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.trust.id
  }
  
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.untrust.id
  }
  
  # NIST 800-53 SI-4: Information System Monitoring
  monitoring = true
  
  # NIST 800-53 SC-7: Boundary Protection
  vpc_security_group_ids = [aws_security_group.palo_alto.id]
  
  # NIST 800-53 CM-6: Configuration Settings
  user_data = base64encode(templatefile("${path.module}/templates/palo_alto_init.tpl", {
    admin_password = var.admin_password
    domain_name    = var.domain_name
    timezone       = var.timezone
  }))
  
  tags = merge(var.common_tags, {
    Name = "palo-alto-firewall-${var.environment}"
    Role = "Firewall"
  })
  
  depends_on = [aws_network_interface.management, aws_network_interface.trust, aws_network_interface.untrust]
}

# Management Network Interface
resource "aws_network_interface" "management" {
  subnet_id         = var.subnet_ids["infrastructure"]
  security_groups   = [aws_security_group.palo_alto.id]
  source_dest_check = false
  
  tags = merge(var.common_tags, {
    Name = "palo-alto-mgmt-${var.environment}"
    Interface = "Management"
  })
}

# Trust Network Interface (Internal)
resource "aws_network_interface" "trust" {
  subnet_id         = var.subnet_ids["infrastructure"]
  security_groups   = [aws_security_group.palo_alto.id]
  source_dest_check = false
  
  tags = merge(var.common_tags, {
    Name = "palo-alto-trust-${var.environment}"
    Interface = "Trust"
  })
}

# Untrust Network Interface (External)
resource "aws_network_interface" "untrust" {
  subnet_id         = var.subnet_ids["infrastructure"]
  security_groups   = [aws_security_group.palo_alto.id]
  source_dest_check = false
  
  tags = merge(var.common_tags, {
    Name = "palo-alto-untrust-${var.environment}"
    Interface = "Untrust"
  })
}

# Security Group for Palo Alto Networks Firewall
resource "aws_security_group" "palo_alto" {
  name        = "palo-alto-sg-${var.environment}"
  description = "Security group for Palo Alto Networks firewall"
  vpc_id      = data.aws_subnet.selected.vpc_id
  
  # NIST 800-53 SC-7: Boundary Protection
  # Management access
  ingress {
    description = "HTTPS management access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  
  ingress {
    description = "SSH management access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  
  # Firewall traffic
  ingress {
    description = "Firewall traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "palo-alto-sg-${var.environment}"
  })
}

# CloudWatch Log Group for firewall logs
resource "aws_cloudwatch_log_group" "palo_alto_logs" {
  name              = "/aws/palo-alto/firewall-${var.environment}"
  retention_in_days = 30
  
  tags = merge(var.common_tags, {
    Name = "palo-alto-logs-${var.environment}"
  })
}

# IAM Role for Palo Alto Networks
resource "aws_iam_role" "palo_alto_role" {
  name = "palo-alto-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(var.common_tags, {
    Name = "palo-alto-role-${var.environment}"
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "palo_alto_profile" {
  name = "palo-alto-profile-${var.environment}"
  role = aws_iam_role.palo_alto_role.name
}

# Data source for subnet information
data "aws_subnet" "selected" {
  id = var.subnet_ids["infrastructure"]
} 
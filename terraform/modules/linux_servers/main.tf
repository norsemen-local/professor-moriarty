# Linux Server Instance
resource "aws_instance" "linux_server" {
  ami           = var.linux_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  
  # NIST 800-53 SI-4: Information System Monitoring
  monitoring = true
  
  # NIST 800-53 SC-7: Boundary Protection
  vpc_security_group_ids = var.security_groups
  
  # NIST 800-53 CM-6: Configuration Settings
  user_data = base64encode(templatefile("${path.module}/templates/linux_init.tpl", {
    server_name     = var.server_name
    environment     = var.environment
    hardening_config = var.hardening_config
  }))
  
  # NIST 800-53 SI-4: Information System Monitoring
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
    
    tags = merge(var.common_tags, {
      Name = "${var.server_name}-root-volume-${var.environment}"
    })
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-${var.environment}"
    Role = var.server_role
    Zone = var.zone
  })
  
  depends_on = [aws_cloudwatch_log_group.linux_logs]
}

# CloudWatch Log Group for Linux Server logs
resource "aws_cloudwatch_log_group" "linux_logs" {
  name              = "/aws/linux/${var.server_name}-${var.environment}"
  retention_in_days = 30
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-logs-${var.environment}"
  })
}

# IAM Role for Linux Server
resource "aws_iam_role" "linux_role" {
  name = "${var.server_name}-role-${var.environment}"
  
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
    Name = "${var.server_name}-role-${var.environment}"
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "linux_profile" {
  name = "${var.server_name}-profile-${var.environment}"
  role = aws_iam_role.linux_role.name
}

# CloudWatch Agent for Linux Server
resource "aws_cloudwatch_agent" "linux" {
  count = var.enable_cloudwatch_agent ? 1 : 0
  
  name = "${var.server_name}-agent-${var.environment}"
  
  configuration = jsonencode({
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path = "/var/log/syslog"
              log_group_name = "/aws/linux/${var.server_name}/syslog-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "/var/log/auth.log"
              log_group_name = "/aws/linux/${var.server_name}/auth-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "/var/log/audit/audit.log"
              log_group_name = "/aws/linux/${var.server_name}/audit-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "/var/log/ufw.log"
              log_group_name = "/aws/linux/${var.server_name}/firewall-${var.environment}"
              log_stream_name = "{instance_id}"
            }
          ]
        }
      }
    }
  })
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-agent-${var.environment}"
  })
}

# Backup Plan for Linux Server
resource "aws_backup_plan" "linux" {
  count = var.enable_backup ? 1 : 0
  
  name = "${var.server_name}-backup-${var.environment}"
  
  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.linux[0].name
    schedule          = "cron(0 2 * * ? *)"
    
    lifecycle {
      delete_after = var.backup_retention_days
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-backup-plan-${var.environment}"
  })
}

# Backup Vault for Linux Server
resource "aws_backup_vault" "linux" {
  count = var.enable_backup ? 1 : 0
  
  name = "${var.server_name}-vault-${var.environment}"
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-backup-vault-${var.environment}"
  })
}

# Backup Selection for Linux Server
resource "aws_backup_selection" "linux" {
  count = var.enable_backup ? 1 : 0
  
  name         = "${var.server_name}-selection-${var.environment}"
  plan_id      = aws_backup_plan.linux[0].id
  
  resources = [
    aws_instance.linux_server.arn
  ]
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-backup-selection-${var.environment}"
  })
} 
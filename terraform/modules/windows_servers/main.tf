# Windows Server Instance
resource "aws_instance" "windows_server" {
  ami           = var.windows_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  
  # NIST 800-53 SI-4: Information System Monitoring
  monitoring = true
  
  # NIST 800-53 SC-7: Boundary Protection
  vpc_security_group_ids = var.security_groups
  
  # NIST 800-53 CM-6: Configuration Settings
  user_data = base64encode(templatefile("${path.module}/templates/windows_init.tpl", {
    server_name     = var.server_name
    domain_name     = var.domain_name
    admin_password  = var.admin_password
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
  
  depends_on = [aws_cloudwatch_log_group.windows_logs]
}

# CloudWatch Log Group for Windows Server logs
resource "aws_cloudwatch_log_group" "windows_logs" {
  name              = "/aws/windows/${var.server_name}-${var.environment}"
  retention_in_days = 30
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-logs-${var.environment}"
  })
}

# IAM Role for Windows Server
resource "aws_iam_role" "windows_role" {
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
resource "aws_iam_instance_profile" "windows_profile" {
  name = "${var.server_name}-profile-${var.environment}"
  role = aws_iam_role.windows_role.name
}

# CloudWatch Agent for Windows Server
resource "aws_cloudwatch_agent" "windows" {
  count = var.enable_cloudwatch_agent ? 1 : 0
  
  name = "${var.server_name}-agent-${var.environment}"
  
  configuration = jsonencode({
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path = "C:\\ProgramData\\Amazon\\SSM\\Logs\\amazon-ssm-agent.log"
              log_group_name = "/aws/windows/${var.server_name}/ssm-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "C:\\Windows\\System32\\winevt\\Logs\\Security.evtx"
              log_group_name = "/aws/windows/${var.server_name}/security-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "C:\\Windows\\System32\\winevt\\Logs\\System.evtx"
              log_group_name = "/aws/windows/${var.server_name}/system-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "C:\\Windows\\System32\\winevt\\Logs\\Application.evtx"
              log_group_name = "/aws/windows/${var.server_name}/application-${var.environment}"
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

# Backup Plan for Windows Server
resource "aws_backup_plan" "windows" {
  count = var.enable_backup ? 1 : 0
  
  name = "${var.server_name}-backup-${var.environment}"
  
  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.windows[0].name
    schedule          = "cron(0 2 * * ? *)"
    
    lifecycle {
      delete_after = var.backup_retention_days
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-backup-plan-${var.environment}"
  })
}

# Backup Vault for Windows Server
resource "aws_backup_vault" "windows" {
  count = var.enable_backup ? 1 : 0
  
  name = "${var.server_name}-vault-${var.environment}"
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-backup-vault-${var.environment}"
  })
}

# Backup Selection for Windows Server
resource "aws_backup_selection" "windows" {
  count = var.enable_backup ? 1 : 0
  
  name         = "${var.server_name}-selection-${var.environment}"
  plan_id      = aws_backup_plan.windows[0].id
  
  resources = [
    aws_instance.windows_server.arn
  ]
  
  tags = merge(var.common_tags, {
    Name = "${var.server_name}-backup-selection-${var.environment}"
  })
} 
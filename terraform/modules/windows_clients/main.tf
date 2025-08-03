# Windows Client Instance
resource "aws_instance" "windows_client" {
  ami           = var.windows_client_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  
  # NIST 800-53 SI-4: Information System Monitoring
  monitoring = true
  
  # NIST 800-53 SC-7: Boundary Protection
  vpc_security_group_ids = var.security_groups
  
  # NIST 800-53 CM-6: Configuration Settings
  user_data = base64encode(templatefile("${path.module}/templates/windows_client_init.tpl", {
    client_name     = var.client_name
    environment     = var.environment
    hardening_config = var.hardening_config
  }))
  
  # NIST 800-53 SI-4: Information System Monitoring
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
    encrypted   = true
    
    tags = merge(var.common_tags, {
      Name = "${var.client_name}-root-volume-${var.environment}"
    })
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.client_name}-${var.environment}"
    Role = "windows-client"
    Zone = "users"
  })
  
  depends_on = [aws_cloudwatch_log_group.windows_client_logs]
}

# CloudWatch Log Group for Windows Client logs
resource "aws_cloudwatch_log_group" "windows_client_logs" {
  name              = "/aws/windows-clients/${var.client_name}-${var.environment}"
  retention_in_days = 30
  
  tags = merge(var.common_tags, {
    Name = "${var.client_name}-logs-${var.environment}"
  })
}

# IAM Role for Windows Client
resource "aws_iam_role" "windows_client_role" {
  name = "${var.client_name}-role-${var.environment}"
  
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
    Name = "${var.client_name}-role-${var.environment}"
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "windows_client_profile" {
  name = "${var.client_name}-profile-${var.environment}"
  role = aws_iam_role.windows_client_role.name
}

# CloudWatch Agent for Windows Client
resource "aws_cloudwatch_agent" "windows_client" {
  count = var.enable_cloudwatch_agent ? 1 : 0
  
  name = "${var.client_name}-agent-${var.environment}"
  
  configuration = jsonencode({
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path = "C:\\ProgramData\\Amazon\\SSM\\Logs\\amazon-ssm-agent.log"
              log_group_name = "/aws/windows-clients/${var.client_name}/ssm-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "C:\\Windows\\System32\\winevt\\Logs\\Security.evtx"
              log_group_name = "/aws/windows-clients/${var.client_name}/security-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "C:\\Windows\\System32\\winevt\\Logs\\System.evtx"
              log_group_name = "/aws/windows-clients/${var.client_name}/system-${var.environment}"
              log_stream_name = "{instance_id}"
            },
            {
              file_path = "C:\\Windows\\System32\\winevt\\Logs\\Application.evtx"
              log_group_name = "/aws/windows-clients/${var.client_name}/application-${var.environment}"
              log_stream_name = "{instance_id}"
            }
          ]
        }
      }
    }
  })
  
  tags = merge(var.common_tags, {
    Name = "${var.client_name}-agent-${var.environment}"
  })
}

# Backup Plan for Windows Client
resource "aws_backup_plan" "windows_client" {
  count = var.enable_backup ? 1 : 0
  
  name = "${var.client_name}-backup-${var.environment}"
  
  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.windows_client[0].name
    schedule          = "cron(0 2 * * ? *)"
    
    lifecycle {
      delete_after = var.backup_retention_days
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.client_name}-backup-plan-${var.environment}"
  })
}

# Backup Vault for Windows Client
resource "aws_backup_vault" "windows_client" {
  count = var.enable_backup ? 1 : 0
  
  name = "${var.client_name}-vault-${var.environment}"
  
  tags = merge(var.common_tags, {
    Name = "${var.client_name}-backup-vault-${var.environment}"
  })
}

# Backup Selection for Windows Client
resource "aws_backup_selection" "windows_client" {
  count = var.enable_backup ? 1 : 0
  
  name         = "${var.client_name}-selection-${var.environment}"
  plan_id      = aws_backup_plan.windows_client[0].id
  
  resources = [
    aws_instance.windows_client.arn
  ]
  
  tags = merge(var.common_tags, {
    Name = "${var.client_name}-backup-selection-${var.environment}"
  })
} 
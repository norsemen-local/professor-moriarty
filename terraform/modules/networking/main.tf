# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.common_tags, {
    Name = "academic-vpc-${var.environment}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "academic-igw-${var.environment}"
  })
}

# NAT Gateway for private subnets
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  
  domain = "vpc"
  
  tags = merge(var.common_tags, {
    Name = "academic-nat-eip-${var.environment}"
  })
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0
  
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  
  tags = merge(var.common_tags, {
    Name = "academic-nat-${var.environment}"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# Public Subnet for NAT Gateway
resource "aws_subnet" "public" {
  count = var.enable_nat_gateway ? 1 : 0
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.21.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = merge(var.common_tags, {
    Name = "academic-public-subnet-${var.environment}"
    Tier = "Public"
  })
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  count = var.enable_nat_gateway ? 1 : 0
  
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(var.common_tags, {
    Name = "academic-public-rt-${var.environment}"
  })
}

resource "aws_route_table_association" "public" {
  count = var.enable_nat_gateway ? 1 : 0
  
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

# Private Subnets for each zone
resource "aws_subnet" "private" {
  for_each = var.zones
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[0]
  
  tags = merge(var.common_tags, {
    Name = "academic-${each.key}-subnet-${var.environment}"
    Zone = each.key
    Tier = "Private"
  })
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  for_each = var.zones
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "academic-${each.key}-rt-${var.environment}"
    Zone = each.key
  })
}

resource "aws_route_table_association" "private" {
  for_each = var.zones
  
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# Security Groups following NIST 800-53 and Zero Trust principles
resource "aws_security_group" "critical_infrastructure" {
  name        = "critical-infrastructure-sg-${var.environment}"
  description = "Security group for critical infrastructure zone (Active Directory)"
  vpc_id      = aws_vpc.main.id
  
  # NIST 800-53 AC-3: Access Enforcement
  # NIST 800-53 SC-7: Boundary Protection
  ingress {
    description = "RDP from infrastructure zone only"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.zones.infrastructure]
  }
  
  ingress {
    description = "Active Directory replication"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = [var.zones.critical_infrastructure]
  }
  
  ingress {
    description = "Active Directory replication (SSL)"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = [var.zones.critical_infrastructure]
  }
  
  ingress {
    description = "Kerberos authentication"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = [var.zones.infrastructure, var.zones.users]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "critical-infrastructure-sg-${var.environment}"
    Zone = "critical_infrastructure"
  })
}

resource "aws_security_group" "infrastructure" {
  name        = "infrastructure-sg-${var.environment}"
  description = "Security group for infrastructure zone"
  vpc_id      = aws_vpc.main.id
  
  # NIST 800-53 SC-7: Boundary Protection
  ingress {
    description = "SSH from users zone"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.zones.users]
  }
  
  ingress {
    description = "RDP from users zone"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.zones.users]
  }
  
  ingress {
    description = "HTTP/HTTPS for web services"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.zones.users]
  }
  
  ingress {
    description = "Internal communication within infrastructure zone"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.zones.infrastructure]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "infrastructure-sg-${var.environment}"
    Zone = "infrastructure"
  })
}

resource "aws_security_group" "users" {
  name        = "users-sg-${var.environment}"
  description = "Security group for users zone"
  vpc_id      = aws_vpc.main.id
  
  # CISA Zero Trust - Device Trust
  ingress {
    description = "SSH for Linux clients"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.zones.users]
  }
  
  ingress {
    description = "RDP for Windows clients"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.zones.users]
  }
  
  ingress {
    description = "HTTP/HTTPS for web access"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.zones.users]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "users-sg-${var.environment}"
    Zone = "users"
  })
}

resource "aws_security_group" "dirty" {
  name        = "dirty-sg-${var.environment}"
  description = "Security group for dirty zone (untrusted)"
  vpc_id      = aws_vpc.main.id
  
  # NIST 800-53 SC-7: Boundary Protection - Highly restricted
  ingress {
    description = "Minimal access for monitoring"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.zones.infrastructure]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "dirty-sg-${var.environment}"
    Zone = "dirty"
  })
}

# VPC Flow Logs for network monitoring (NIST 800-53 SI-4)
resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id              = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "vpc-flow-logs-${var.environment}"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  
  name              = "/aws/vpc/flow-logs-${var.environment}"
  retention_in_days = 30
  
  tags = merge(var.common_tags, {
    Name = "vpc-flow-logs-${var.environment}"
  })
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
} 
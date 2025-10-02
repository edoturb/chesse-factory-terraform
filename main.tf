# Configuracion del proveedor y recursos principales
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# configuracion AWS
provider "aws" {
  region = var.aws_region
}

# Obtener zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cheese-factory-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cheese-factory-igw"
  }
}

# Public Subnets - Usando función cidrsubnet()
resource "aws_subnet" "subnet" {
  count                   = var.instance_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "cheese-factory-public-subnet-${count.index + 1}"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "cheese-factory-rt"
  }
}

# Route table associations
resource "aws_route_table_association" "public" {
  count          = var.instance_count
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name_prefix = "cheese-factory-ec2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Permitir ALB en puerto 80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Permitir HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Permitir SSH desde tu IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "cheese-factory-alb"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    echo "Starting user-data script at $(date)"
    
    # Update system
    yum update -y
    
    # Install Docker
    yum install -y docker
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
    
    # Wait for Docker to be ready
    echo "Waiting for Docker to be ready..."
    sleep 30
    
    # Verify Docker is running
    docker --version
    docker info
    
    # Pull and run cheese container
    echo "Starting cheese container: ${element(var.cheese_images, count.index)}"
    docker pull ${element(var.cheese_images, count.index)}
    
    # Stop any existing container
    docker stop cheese-app 2>/dev/null || true
    docker rm cheese-app 2>/dev/null || true
    
    # Start new container - Usando función element()
    docker run -d --restart=always --name=cheese-app -p 80:80 ${element(var.cheese_images, count.index)}
    
    # Verify container is running
    sleep 10
    docker ps
    docker logs cheese-app
    
    # Test local connection
    curl -s http://localhost:80 || echo "Local test failed"
    
    echo "User-data script completed at $(date)"
  EOF

  tags = {
    Name      = "cheese-web-${count.index + 1}"
    IsPrimary = count.index == 0 ? "true" : "false"
  }
}

# Balanceador de carga - ALB
resource "aws_lb" "cheese_alb" {
  name               = "cheese-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.subnet[*].id

  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "cheese_tg" {
  name     = "cheese-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 15 # Más frecuente
    matcher             = "200"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 10 # Más tiempo
    unhealthy_threshold = 3  # Más tolerante
  }
}

# Attach instances to target group
resource "aws_lb_target_group_attachment" "cheese_attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.cheese_tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Listener
resource "aws_lb_listener" "cheese_listener" {
  load_balancer_arn = aws_lb.cheese_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cheese_tg.arn
  }
}

# Subnets privadas para RDS - Usando función cidrsubnet()
resource "aws_subnet" "private_subnet" {
  count             = 2 # RDS requiere al menos 2 subnets en diferentes AZs
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10) # Offset para evitar conflictos
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "cheese-factory-private-subnet-${count.index + 1}"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "cheese_db_subnet_group" {
  name       = "cheese-db-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "Cheese Factory DB subnet group"
  }
}

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name        = "cheese-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  # Permitir acceso MySQL desde las instancias EC2
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cheese-rds-security-group"
  }
}

# RDS Instance - Usando expresiones condicionales
resource "aws_db_instance" "cheese_db" {
  identifier = "cheese-factory-db"

  # Configuración del motor de base de datos
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Configuración de almacenamiento
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2 # Auto-scaling hasta el doble
  storage_type          = "gp2"
  storage_encrypted     = true

  # Configuración de la base de datos  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Configuración de red
  db_subnet_group_name   = aws_db_subnet_group.cheese_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  # Configuración de respaldo y mantenimiento
  backup_retention_period = length(var.cheese_images) > 2 ? 7 : 3 # Expresión condicional
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Configuración de desarrollo - usar con precaución en producción
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "cheese-factory-database"
    Environment = var.db_allocated_storage > 20 ? "production" : "development" # Expresión condicional
  }
}

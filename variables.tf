# AWS Region
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# VPC CIDR
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# configuracion de instancias
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Type of EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2023
}

variable "key_name" {
  description = "AWS Key Pair name for EC2 instances"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
}

# imagenes de quesos container 
variable "cheese_images" {
  description = "List of cheese Docker images"
  type        = list(string)
  default = [
    "errm/cheese:wensleydale",
    "errm/cheese:cheddar",
    "errm/cheese:stilton"
  ]
}

# Variables para Base de Datos RDS
variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "cheesefactory"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

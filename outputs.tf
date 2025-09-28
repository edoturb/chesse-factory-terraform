# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Instance information
output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.web[*].id
}

output "instance_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.web[*].public_ip
}

# Load Balancer information
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.cheese_alb.dns_name
}

output "alb_url" {
  description = "URL to access the Cheese Factory application"
  value       = "http://${aws_lb.cheese_alb.dns_name}"
}

# RDS Database information
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.cheese_db.endpoint
  sensitive   = true
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.cheese_db.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.cheese_db.db_name
}

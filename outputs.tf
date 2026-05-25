# --- EC2 Outputs ---
output "ec2_public_ip" {
  description = "Public IP of the standalone EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the standalone EC2 instance"
  value       = module.ec2.public_dns
}

output "ec2_key_pair_name" {
  description = "Name of the generated key pair"
  value       = module.ec2.key_pair_name
}

output "ec2_private_key_path" {
  description = "Local path to the private key file"
  value       = module.ec2.private_key_path
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${module.ec2.private_key_path} ec2-user@${module.ec2.public_ip}"
}

# --- S3 Outputs ---
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "s3_bucket_domain" {
  description = "Domain name of the S3 bucket"
  value       = module.s3.bucket_domain
}

# --- VPC Outputs ---
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# --- ALB Outputs ---
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL to test the ALB"
  value       = "http://${module.alb.alb_dns_name}"
}

output "nginx_instance_ids" {
  description = "IDs of the Nginx EC2 instances"
  value       = module.alb.instance_ids
}

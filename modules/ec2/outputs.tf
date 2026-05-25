output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.this.public_dns
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "key_pair_name" {
  description = "Name of the AWS Key Pair"
  value       = aws_key_pair.this.key_name
}

output "private_key_path" {
  description = "Local path to the .pem private key"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.ec2.id
}

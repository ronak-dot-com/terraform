output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB Hosted Zone ID (for Route53)"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.this.arn
}

output "instance_ids" {
  description = "IDs of Nginx EC2 instances"
  value       = aws_instance.nginx[*].id
}

output "instance_private_ips" {
  description = "Private IPs of Nginx instances"
  value       = aws_instance.nginx[*].private_ip
}

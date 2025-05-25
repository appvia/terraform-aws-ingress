output "alb_arn" {
  description = "The ARN of the ALB/NLB"
  value       = aws_lb.load_balancer.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB/NLB"
  value       = aws_lb.load_balancer.dns_name
}

output "alb_zone_id" {
  description = "The Zone ID of the ALB/NLB (useful for Route 53 alias records)"
  value       = aws_lb.load_balancer.zone_id
}

output "target_group_arns" {
  description = "A map of Target Group ARNs"
  value       = local.target_group_arns
}

output "target_group_names" {
  description = "A map of Target Group names"
  value       = local.target_group_names
}

output "security_group_id" {
  description = "The security group ID assigned to the load balancer"
  value       = aws_security_group.baseline_sg.id
}

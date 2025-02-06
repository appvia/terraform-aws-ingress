output "alb_arn" {
  description = "The ARN of the ALB/NLB"
  value       = aws_lb.lb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB/NLB"
  value       = aws_lb.lb.dns_name
}

output "alb_zone_id" {
  description = "The Zone ID of the ALB/NLB (useful for Route 53 alias records)"
  value       = aws_lb.lb.zone_id
}

output "target_group_arns" {
  description = "A map of Target Group ARNs"
  value       = { for tg in aws_lb_target_group.backend : tg.name => tg.arn }
}

output "target_group_names" {
  description = "A map of Target Group names"
  value       = { for tg in aws_lb_target_group.backend : tg.name => tg.name }
}

output "security_group_id" {
  description = "The security group ID assigned to the ALB/NLB"
  value       = aws_security_group.baseline_sg.id
}

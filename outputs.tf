output "alb_arn" {
  description = "The ARN of the ALB/NLB"
  value       = aws_lb.lb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB/NLB"
  value       = aws_lb.lb.dns_name
}

output "alb_security_groups" {
  description = "The security groups attached to the ALB (if applicable)"
  value       = var.alb_config["lb_type"] == "application" ? aws_lb.lb.security_groups : []
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener (if ALB)"
  value       = length(aws_lb_listener.https_listener) > 0 ? aws_lb_listener.https_listener[0].arn : null
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener (if ALB)"
  value       = length(aws_lb_listener.http_listener) > 0 ? aws_lb_listener.http_listener[0].arn : null
}

output "tcp_listener_arn" {
  description = "The ARN of the TCP listener (if NLB)"
  value       = length(aws_lb_listener.tcp_listener) > 0 ? aws_lb_listener.tcp_listener[0].arn : null
}

output "target_group_arns" {
  description = "A map of Target Group ARNs"
  value       = { for tg in aws_lb_target_group.backend : tg.name => tg.arn }
}

output "baseline_security_group_id" {
  description = "The ID of the baseline security group created by the module"
  value       = length(aws_security_group.baseline_sg) > 0 ? aws_security_group.baseline_sg[0].id : null
}

output "security_groups_attached" {
  description = "The security groups attached to the ALB/NLB"
  value       = local.security_groups
}

output "waf_web_acl_association" {
  description = "The associated WAF Web ACL ARN (if applied)"
  value       = length(aws_wafv2_web_acl_association.lb_waf_assoc) > 0 ? aws_wafv2_web_acl_association.lb_waf_assoc[0].web_acl_arn : null
}

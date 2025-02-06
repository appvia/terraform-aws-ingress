output "alb_arn" {
  description = "The ARN of the ALB/NLB"
  value       = aws_lb.lb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB/NLB"
  value       = aws_lb.lb.dns_name
}

output "target_group_arns" {
  description = "A map of Target Group ARNs"
  value       = { for tg in aws_lb_target_group.backend : tg.name => tg.arn }
}

output "waf_web_acl_association" {
  description = "The associated WAF Web ACL ARN (if applied)"
  value       = length(aws_wafv2_web_acl_association.lb_waf_assoc) > 0 ? aws_wafv2_web_acl_association.lb_waf_assoc[0].web_acl_arn : null
}

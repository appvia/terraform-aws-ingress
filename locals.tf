locals {
  # Merge baseline security group (if created) with extra security groups
  security_groups = concat(
    var.alb_config["baseline_security_group_enabled"] ? [aws_security_group.baseline_sg[0].id] : [],
    var.extra_security_groups
  )

  # Determine WAF Web ACL ARN (shared AWS Org ACL or user-defined)
  waf_arn = var.alb_config["waf_web_acl_arn"] != null ? var.alb_config["waf_web_acl_arn"] : length(data.aws_wafv2_web_acl.shared_waf_rule_group) > 0 ? data.aws_wafv2_web_acl.shared_waf_rule_group[0].arn : null
}

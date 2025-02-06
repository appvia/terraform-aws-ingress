# Lookup the shared WAF Rule Group ARN if provided
data "aws_wafv2_web_acl" "shared_waf_rule_group" {
  count    = var.alb_config["shared_waf_rule_group_name"] != null ? 1 : 0
  name     = var.alb_config["shared_waf_rule_group_name"]
  scope    = "REGIONAL"
  provider = aws
}

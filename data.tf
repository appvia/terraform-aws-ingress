# Lookup a shared AWS WAF Rule Group based on the provided name
data "aws_wafv2_rule_group" "shared_waf_rule_group" {
  name  = var.waf_rule_group_name
  scope = "REGIONAL"
}

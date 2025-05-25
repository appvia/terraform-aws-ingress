# Lookup a shared AWS WAF Rule Group based on the provided name
data "aws_wafv2_rule_group" "rule_group" {
  count = local.enable_waf ? 1 : 0

  name  = var.waf_rule_group_name
  scope = "REGIONAL"
}

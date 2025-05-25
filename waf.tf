
## Associate the WAF Rule Group with the ALB if WAF is enabled
resource "aws_wafv2_web_acl_association" "association" {
  count = local.enable_waf ? 1 : 0

  resource_arn = aws_lb.load_balancer.arn
  web_acl_arn  = data.aws_wafv2_rule_group.rule_group[0].arn
}

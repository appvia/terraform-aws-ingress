#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "ingress" {
  source = "../.."

  vpc_id = "vpc-12345678"

  alb_config = {
    name         = "app-ingress"
    internal     = false
    subnets      = ["subnet-12345678", "subnet-23456789"]
    lb_type      = "application"
    enable_https = true
  }

  allowed_ingress_cidr_blocks = ["192.168.1.0/24"]
  allowed_egress_cidr_blocks  = ["10.0.0.0/16"]

  target_group_configs = [
    {
      name     = "backend-service-1"
      port     = 443
      protocol = "HTTPS"
    },
    {
      name     = "backend-service-2"
      port     = 80
      protocol = "HTTP"
    }
  ]

  waf_rule_group_name = "org-wide-waf-rules"
}

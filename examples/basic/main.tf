#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "internal_alb" {
  source = "../../"

  vpc_id = "vpc-12345678"

  lb_config = {
    name            = "internal-alb"
    type            = "application"
    internal        = true
    subnets         = ["subnet-12345678", "subnet-23456789"]
    certificate_arn = "arn:aws:acm:region:account:certificate/internal-cert"
  }

  target_group_configs = [
    {
      name     = "internal-service-1"
      port     = 443
      protocol = "HTTPS"
    }
  ]

  allowed_ingress_cidr_blocks = ["10.0.0.0/8"] # Only internal traffic allowed
  allowed_egress_cidr_blocks  = ["10.0.0.0/8"] # Restrict outbound traffic

  waf_rule_group_name = "internal-waf-rules"
}

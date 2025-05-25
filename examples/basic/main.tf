#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "internal_alb" {
  source = "../../"

  name                        = "ingress-alb"
  allowed_egress_cidr_blocks  = ["10.0.0.0/8"]
  allowed_ingress_cidr_blocks = ["0.0.0.0/8"]
  certificate_arn             = "arn:aws:acm:region:account:certificate/internal-cert"
  subnet_ids                  = ["subnet-12345678", "subnet-23456789"]
  tags                        = {}
  vpc_id                      = "vpc-12345678"
  waf_rule_group_name         = "internal-waf-rules"

  backends = {
    "web" = {
      port     = 80
      priority = 1

      health = {
        port                = 8080
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }

      condition = {
        host_headers = {
          values = ["web.example.com", "*.web.example.com"]
        }
      }

      targets = [
        {
          id   = "10.32.0.11"
          port = 8080
        },
        {
          id   = "10.23.0.10"
          port = 8080
        }
      ]
    },
  }
}

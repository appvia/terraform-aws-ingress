locals {
  ## Indicates if WAF is enabled for the ALB
  enable_waf = var.waf_rule_group_name != null

  ## A map of target group ARNs for the load balancer
  target_group_arns = { for x in aws_lb_target_group.backends : x.name => x.arn }

  ## A map of target group names for the load balancer
  target_group_names = { for x in aws_lb_target_group.backends : x.name => x.name }

  ## A map of backend to each target instance
  all_targets = flatten(
    [
      for k, v in var.backends : [
        for x in v.targets : [
          {
            availability_zone = x.availablity_zone
            backend           = k
            id                = x.id
            name              = format("%s_%s_%s", k, x.id, x.port)
            port              = x.port
          }
      ]]
  ])

  ## A map of targets with their details
  targets = { for x in local.all_targets : x.name => x }
}

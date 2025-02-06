# The VPC where the ALB/NLB is deployed
variable "vpc_id" {
  description = "The ID of the VPC where the ALB/NLB is deployed"
  type        = string
}

# Global Tags
variable "tags" {
  description = "Tags to apply to all created resources"
  type        = map(string)
  default     = {}
}

# Load Balancer Configuration Map
variable "alb_config" {
  description = "Configuration settings for the ALB/NLB"
  type = object({
    name                            = string
    internal                        = bool
    subnets                         = list(string)
    security_groups                 = list(string)
    lb_type                         = string               # "application" for ALB, "network" for NLB
    enable_https                    = optional(bool, true) # ALB only
    certificate_arn                 = optional(string, "")
    ssl_policy                      = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06") # ALB only
    tcp_port                        = optional(number, 443)                                   # NLB only
    waf_web_acl_arn                 = optional(string, "")                                    # ALB only
    shared_waf_rule_group_name      = optional(string, null)                                  # Optional AWS Org WAF Rule Group Name
    baseline_security_group_enabled = optional(bool, true)                                    # Create a default security group for inbound traffic
  })

  validation {
    condition     = contains(["application", "network"], var.alb_config.lb_type)
    error_message = "lb_type must be either 'application' (ALB) or 'network' (NLB)."
  }
}

# Additional security groups to attach to the ALB/NLB
variable "extra_security_groups" {
  description = "Additional security groups to attach to the ALB/NLB"
  type        = list(string)
  default     = []
}

# Target Groups Configuration Map for Workload Account NLBs/ALBs
variable "target_group_configs" {
  description = "List of target groups forwarding to workload accounts"
  type = list(object({
    name       = string
    port       = number
    protocol   = string
    target_ips = list(string)
  }))
}

# The VPC where the ALB/NLB is deployed
variable "vpc_id" {
  description = "The ID of the VPC where the ALB/NLB will be deployed"
  type        = string
}

# Global Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Load Balancer configuration map
variable "lb_config" {
  description = "Configuration settings for the ALB/NLB"
  type = object({
    name            = string
    type            = string # "application" (ALB) or "network" (NLB)
    internal        = bool
    subnets         = list(string)
    certificate_arn = optional(string, "")
    ssl_policy      = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
  })

  validation {
    condition     = contains(["application", "network"], var.lb_config.type)
    error_message = "lb_type must be either 'application' (ALB) or 'network' (NLB)."
  }
}

# Allowed CIDR blocks for ingress traffic
variable "allowed_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed for inbound HTTPS traffic"
  type        = list(string)
}

# Allowed CIDR blocks for egress traffic
variable "allowed_egress_cidr_blocks" {
  description = "List of CIDR blocks allowed for outbound traffic"
  type        = list(string)
}

# Additional security groups to attach to the ALB/NLB
variable "extra_security_groups" {
  description = "List of additional security groups to attach to the ALB/NLB"
  type        = list(string)
  default     = []
}

# Target Groups configuration map for Worload Account NLBs/ALBs
variable "target_group_configs" {
  description = "List of target groups forwarding traffic to backend instances or services"
  type = list(object({
    name     = string
    port     = number
    protocol = string
  }))
}

# Name of the AWS WAF Rule Group to attach to the ALB
variable "waf_rule_group_name" {
  description = "The name of the AWS WAF rule group to attach to the ALB (must be shared in the account)"
  type        = string
}

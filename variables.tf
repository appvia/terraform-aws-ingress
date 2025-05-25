# The VPC where the ALB/NLB is deployed
variable "allowed_egress_cidr_blocks" {
  description = "List of CIDR blocks allowed for outbound traffic"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# Allowed CIDR blocks for ingress traffic
variable "allowed_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed for inbound HTTPS traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Target Groups configuration map for Worload Account NLBs/ALBs
variable "backends" {
  description = "List of target groups forwarding traffic to backend instances or services"
  type = map(object({
    ## The port on which the target group listens
    port = optional(number, 80)
    ## The priority of the target group (lower numbers have higher priority)
    priority = number
    ## The protocol used by the target group (default is HTTP)
    protocol = optional(string, "HTTP")
    ## The target type for the target group (default is 'ip')
    target_type = optional(string, "ip")
    ## The health check configuration for the target group
    health = object({
      ## Path to check for health (default is "/")
      path = optional(string, "/")
      ## Port for health checks (default is the target group port)
      port = optional(string, 80)
      ## Protocol for health checks (default is HTTP)
      protocol = optional(string, "HTTP")
      ## Interval in seconds between health checks
      interval = optional(number, 30)
      ## Timeout in seconds for each health check
      timeout = optional(number, 5)
      ## Number of consecutive successful health checks before considering the target healthy
      healthy_threshold = optional(number, 2)
      ## Number of consecutive failed health checks before considering the target unhealthy
      unhealthy_threshold = optional(number, 3)
    })
    ## A list of conditions to match this target group
    condition = object({
      ## The type of condition (e.g., path, host header)
      host_header = optional(object({
        ## A list of host header values to match (e.g., example.com, *.example.com)
        values = list(string)
      }), null)
      ## A list of HTTP header conditions
      http_header = optional(object({
        ## The name of the HTTP header to match
        name = string
        ## The value to match against the header
        values = list(string)
      }), null)
      ## A list of path patterns to match (e.g., /api/*)
      path_pattern = optional(object({
        ## A list of path patterns to match
        values = list(string)
      }), null)
      ## A list of source IP conditions
      source_ip = optional(object({
        ## The CIDR block to match (e.g. 10.0.0/16)
        values = list(string)
      }), null)
    })
    ## Addresses of the backend instances or services
    targets = list(object({
      ## The availablity zone of the target, required as the ip is outside of the VPC
      availablity_zone = string
      ## ID of the target (e.g., instance ID, IP address)
      id = string
      ## Port on which the target is listening
      port = number
    }))
  }))
}

variable "certificate_arn" {
  description = "The certificate ARN for the Load Balancer (optional, required for ALB with HTTPS)"
  type        = string
}

variable "client_keepalive" {
  description = "The time in seconds to keep the connection alive for clients (default is 3600 seconds)"
  type        = number
  default     = 3600
}

variable "enable_https_redirect" {
  description = "Enable HTTP to HTTPS redirection (default is true)"
  type        = bool
  default     = true
}

variable "extra_security_groups" {
  description = "List of additional security groups to attach to the ALB/NLB"
  type        = list(string)
  default     = []
}

variable "http_port" {
  description = "The port for HTTP traffic (default is 80)"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "The port for HTTPS traffic (default is 443)"
  type        = number
  default     = 443
}

variable "name" {
  description = "Is the name of the load balancer"
  type        = string
}

variable "ssl_policy" {
  description = "The SSL policy for the Load Balancer (optional, defaults to a secure policy)"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "subnet_ids" {
  description = "List of subnets where the Load Balancer will be deployed"
  type        = list(string)
}

# Global Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB/NLB will be deployed"
  type        = string
}

# Name of the AWS WAF Rule Group to attach to the ALB
variable "waf_rule_group_name" {
  description = "The name of the AWS WAF rule group to attach to the ALB (must be shared in the account)"
  type        = string
  default     = null
}

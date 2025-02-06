# Add resources here
# Create the Load Balancer (ALB or NLB)
resource "aws_lb" "lb" {
  name               = var.alb_config["name"]
  internal           = var.alb_config["internal"]
  load_balancer_type = var.alb_config["lb_type"] # "application" (ALB) or "network" (NLB)
  subnets            = var.alb_config["subnets"]
  security_groups    = var.alb_config["lb_type"] == "application" ? local.security_groups : null
  tags               = var.tags
}

# HTTPS Listener (Only for ALB)
resource "aws_lb_listener" "https_listener" {
  count             = var.alb_config["lb_type"] == "application" && var.alb_config["enable_https"] ? 1 : 0
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.alb_config["ssl_policy"]
  certificate_arn   = var.alb_config["certificate_arn"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[var.target_group_configs[0].name].arn
  }
}

# HTTP Listener (Redirects to HTTPS, Only for ALB)
resource "aws_lb_listener" "http_listener" {
  count             = var.alb_config["lb_type"] == "application" && var.alb_config["enable_https"] ? 1 : 0
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# TCP Listener (Only for NLB)
resource "aws_lb_listener" "tcp_listener" {
  count             = var.alb_config["lb_type"] == "network" ? 1 : 0
  load_balancer_arn = aws_lb.lb.arn
  port              = var.alb_config["tcp_port"]
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[var.target_group_configs[0].name].arn
  }
}

# WAFv2 Web ACL Association (Only for ALB)
resource "aws_wafv2_web_acl_association" "lb_waf_assoc" {
  count        = local.waf_arn != null && var.alb_config["lb_type"] == "application" ? 1 : 0
  resource_arn = aws_lb.lb.arn
  web_acl_arn  = local.waf_arn
}

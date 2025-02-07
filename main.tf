# Secure baseline security group (Only for ALB)
resource "aws_security_group" "baseline_sg" {
  name   = "${var.lb_config.name}-baseline-sg"
  vpc_id = var.vpc_id

  description = "Baseline security group for ingress ALB"

  ingress {
    description = "Allow inbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic to workload subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_egress_cidr_blocks
  }

  tags = merge(var.tags, {
    "Name" = "${var.lb_config.name}-baseline-sg"
  })
}

# Create ALB or NLB
resource "aws_lb" "lb" {
  name                       = var.lb_config.name
  internal                   = var.lb_config.internal
  load_balancer_type         = var.lb_config.type
  subnets                    = var.lb_config.subnets
  security_groups            = concat([aws_security_group.baseline_sg.id], var.extra_security_groups)
  drop_invalid_header_fields = var.lb_config.type == "application" ? true : null
  tags                       = var.tags
}

# Create HTTPS listeners dynamically for ALB
resource "aws_lb_listener" "https_listeners" {
  for_each = { for tg in var.target_group_configs : tg.name => tg if var.lb_config.type == "application" && tg.protocol == "HTTPS" }

  load_balancer_arn = aws_lb.lb.arn
  port              = each.value.port
  protocol          = "HTTPS"
  ssl_policy        = var.lb_config.ssl_policy
  certificate_arn   = var.lb_config.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }
}

# Create TCP listeners dynamically for NLB
resource "aws_lb_listener" "tcp_listeners" {
  for_each = { for tg in var.target_group_configs : tg.name => tg if var.lb_config.type == "network" && tg.protocol == "TCP" }

  load_balancer_arn = aws_lb.lb.arn
  port              = each.value.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }
}

# Create target groups dynamically
resource "aws_lb_target_group" "backend" {
  for_each = { for tg in var.target_group_configs : tg.name => tg }

  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id

  health_check {
    protocol            = each.value.protocol == "HTTPS" && var.lb_config.type == "application" ? "HTTPS" : "TCP"
    port                = each.value.port
    path                = each.value.protocol == "HTTPS" ? "/health" : null
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = var.tags
}

# Associate WAF (Only for ALB)
resource "aws_wafv2_web_acl_association" "alb_waf_assoc" {
  count        = var.lb_config.type == "application" ? 1 : 0
  resource_arn = aws_lb.lb.arn
  web_acl_arn  = data.aws_wafv2_rule_group.shared_waf_rule_group.arn
}

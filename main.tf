# Create ALB or NLB
resource "aws_lb" "lb" {
  name               = var.alb_config["name"]
  internal           = var.alb_config["internal"]
  load_balancer_type = var.alb_config["lb_type"]
  subnets            = var.alb_config["subnets"]
  security_groups    = concat([aws_security_group.baseline_sg.id], var.extra_security_groups)
  tags               = var.tags
}

# Secure baseline security group
resource "aws_security_group" "baseline_sg" {
  name   = "${var.alb_config["name"]}-baseline-sg"
  vpc_id = var.vpc_id

  description = "Baseline security group for ingress ALB/NLB"

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
    "Name" = "${var.alb_config["name"]}-baseline-sg"
  })
}

# Create backend target groups dynamically
resource "aws_lb_target_group" "backend" {
  for_each = { for tg in var.target_group_configs : tg.name => tg }

  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id

  health_check {
    protocol = each.value.protocol
    port     = each.value.port
    path     = each.value.protocol == "HTTPS" || each.value.protocol == "HTTP" ? "/" : null
  }

  tags = var.tags
}

# Create dynamic listeners for each target group
resource "aws_lb_listener" "dynamic_listeners" {
  for_each = { for tg in var.target_group_configs : tg.name => tg }

  load_balancer_arn = aws_lb.lb.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }
}

# Associate WAF if an ARN is provided
resource "aws_wafv2_web_acl_association" "alb_waf_assoc" {
  resource_arn = aws_lb.lb.arn
  web_acl_arn  = data.aws_wafv2_rule_group.shared_waf_rule_group.arn
}

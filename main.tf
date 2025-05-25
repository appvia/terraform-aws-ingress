# Secure baseline security group (Only for ALB)
# tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group" "baseline_sg" {
  name        = var.name
  description = "Baseline security group for ingress load balancer traffic"
  tags        = merge(var.tags, { "Name" = var.name })
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP traffic to the load balancer: ${var.name}"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  ingress {
    description = "Allow inbound HTTPS traffic to the load balancer: ${var.name}"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic to workload subnets from the load balancer: ${var.name}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_egress_cidr_blocks
  }
}

## Provision the load balancer (ALB or NLB) based on the configuration
resource "aws_lb" "load_balancer" {
  name                       = var.name
  drop_invalid_header_fields = true
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = concat([aws_security_group.baseline_sg.id], var.extra_security_groups)
  subnets                    = var.subnet_ids
  tags                       = var.tags
}

## Provision the target groups for the backends
resource "aws_lb_target_group" "backends" {
  for_each = var.backends

  name     = each.key
  port     = each.value.port
  protocol = "TCP"
  tags     = var.tags
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = each.value.health.port
    interval            = each.value.health.interval
    timeout             = each.value.health.timeout
    healthy_threshold   = each.value.health.healthy_threshold
    unhealthy_threshold = each.value.health.unhealthy_threshold
  }
}

## Associate the static IPs with the backend target groups
resource "aws_lb_target_group_attachment" "targets" {
  for_each = local.targets

  target_group_arn = aws_lb_target_group.backends[each.value.key].arn
  target_id        = each.value.id
  port             = each.value.port
}

## Provision a HTTP listener and redirect to HTTPS
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.http_port
  protocol          = "HTTP"
  tags              = var.tags

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

## Provision TCP listeners for the load balancer (NLB)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  tags              = var.tags

  ## Default action is to 403
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

## Provision the rules for the HTTPS listener
resource "aws_lb_listener_rule" "https_listener_rules" {
  for_each = var.backends

  listener_arn = aws_lb_listener.https_listener.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backends[each.key].arn
  }

  condition {
    dynamic "host_header" {
      for_each = each.value.condition.host_headers != null ? each.value.condition.host_headers : []

      content {
        values = host_header.values
      }
    }

    dynamic "path_pattern" {
      for_each = each.value.condition.path_patterns != null ? each.value.condition.path_patterns.values : []

      content {
        values = path_pattern.values
      }
    }

    dynamic "http_header" {
      for_each = each.value.condition.http_header != null ? each.value.condition.http_header : []

      content {
        http_header_name = http_header.name
        values           = http_header.values
      }
    }

    dynamic "source_ip" {
      for_each = each.value.condition.source_ips != null ? each.value.condition.source_ip : []

      content {
        values = source_ip.values
      }
    }
  }
}

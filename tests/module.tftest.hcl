mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = [
        "eu-west-1a",
        "eu-west-1b",
        "eu-west-1c"
      ]
    }
  }
}

run "basic" {
  command = plan

  variables {
    name                        = "ingress-alb"
    allowed_egress_cidr_blocks  = ["10.0.0.0/8"]
    allowed_ingress_cidr_blocks = ["0.0.0.0/8"]
    certificate_arn             = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-5678-90ab-cdef-EXAMPLE11111"
    subnet_ids                  = ["subnet-12345678", "subnet-23456789"]
    vpc_id                      = "vpc-12345678"

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
          host_header = {
            values = ["web.example.com", "*.web.example.com"]
          }
        }

        targets = [
          {
            availablity_zone = "us-east-1a"
            id               = "10.32.0.11"
            port             = 8080
          },
          {
            availablity_zone = "us-east-1b"
            id               = "10.23.0.10"
            port             = 8080
          }
        ]
      },
    }

    tags = {
      "Environment" = "Testing"
      "GitRepo"     = "https://github.com/appvia/terraform-aws-ingress"
    }
  }

  assert {
    condition     = aws_lb.load_balancer != null
    error_message = "Load balancer should be created"
  }

  assert {
    condition     = aws_lb.load_balancer.name == "ingress-alb"
    error_message = "Load balancer name should be 'ingress-alb'"
  }

  assert {
    condition     = length(aws_lb.load_balancer.subnets) == 2
    error_message = "Load balancer should be created in the correct subnets"
  }

  assert {
    condition     = contains(aws_lb.load_balancer.subnets, "subnet-12345678")
    error_message = "Load balancer should be created in the correct subnets"
  }

  assert {
    condition     = contains(aws_lb.load_balancer.subnets, "subnet-23456789")
    error_message = "Load balancer should be created in the correct subnets"
  }

  assert {
    condition     = length(aws_lb.load_balancer.tags) == 2
    error_message = "Load balancer should be created with the correct tags"
  }

  assert {
    condition     = aws_lb.load_balancer.tags["Environment"] == "Testing"
    error_message = "Load balancer should be created with the correct tags"
  }

  assert {
    condition     = aws_lb.load_balancer.tags["GitRepo"] == "https://github.com/appvia/terraform-aws-ingress"
    error_message = "Load balancer should be created with the correct tags"
  }

  assert {
    condition     = aws_lb_listener.http_listener[0] != null
    error_message = "HTTP listener should be created"
  }

  assert {
    condition     = aws_lb_listener.http_listener[0].port == 80
    error_message = "HTTP listener should be created on port 80"
  }

  assert {
    condition     = aws_lb_listener.http_listener[0].tags["Environment"] == "Testing"
    error_message = "HTTP listener should be created with the correct tags"
  }

  assert {
    condition     = aws_lb_listener.http_listener[0].default_action[0].type == "redirect"
    error_message = "HTTP listener should redirect to HTTPS"
  }

  assert {
    condition     = aws_lb_listener.http_listener[0].default_action[0].redirect[0].port == "443"
    error_message = "HTTP listener should redirect to HTTPS on port 443"
  }

  assert {
    condition     = aws_lb_listener.https_listener != null
    error_message = "HTTPS listener should be created"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"] != null
    error_message = "Target group should be created"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].port == 80
    error_message = "Target group should be created on port 80"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].tags["Environment"] == "Testing"
    error_message = "Target group should be created with the correct tags"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].tags["GitRepo"] == "https://github.com/appvia/terraform-aws-ingress"
    error_message = "Target group should be created with the correct tags"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].health_check[0].port == "8080"
    error_message = "Target group should be created with the correct health check"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].health_check[0].interval == 30
    error_message = "Target group should be created with the correct health check"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].health_check[0].timeout == 5
    error_message = "Target group should be created with the correct health check"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].health_check[0].healthy_threshold == 3
    error_message = "Target group should be created with the correct health check"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].health_check[0].unhealthy_threshold == 3
    error_message = "Target group should be created with the correct health check"
  }

  assert {
    condition     = aws_lb_target_group.backends["web"].vpc_id == "vpc-12345678"
    error_message = "Target group should be created with the correct VPC"
  }

  assert {
    condition     = length(aws_lb_target_group_attachment.targets) == 2
    error_message = "Target group attachments should be created for each target"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.23.0.10_8080"] != null
    error_message = "Target group attachment should be created for the first target"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.23.0.10_8080"].port == 8080
    error_message = "Target group attachment should be created with the correct port"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.23.0.10_8080"].availability_zone == "us-east-1b"
    error_message = "Target group attachment should be created with the correct availability zone"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.23.0.10_8080"].target_id == "10.23.0.10"
    error_message = "Target group attachment should be created with the correct target ID"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.32.0.11_8080"] != null
    error_message = "Target group attachment should be created for the second target"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.32.0.11_8080"].port == 8080
    error_message = "Target group attachment should be created with the correct port"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.32.0.11_8080"].availability_zone == "us-east-1a"
    error_message = "Target group attachment should be created with the correct availability zone"
  }

  assert {
    condition     = aws_lb_target_group_attachment.targets["web_10.32.0.11_8080"].target_id == "10.32.0.11"
    error_message = "Target group attachment should be created with the correct target ID"
  }

  assert {
    condition     = aws_lb_listener_rule.https_listener_rules["web"] != null
    error_message = "HTTPS listener rule should be created"
  }

  assert {
    condition     = aws_lb_listener_rule.https_listener_rules["web"].priority == 1
    error_message = "HTTPS listener rule should have priority 1"
  }
}

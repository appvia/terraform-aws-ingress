<!-- markdownlint-disable -->
<a href="https://www.appvia.io/"><img src="https://github.com/appvia/terraform-aws-module-template/blob/main/docs/banner.jpg?raw=true" alt="Appvia Banner"/></a><br/><p align="right"> <a href="https://registry.terraform.io/modules/appvia/module-template/aws/latest"><img src="https://img.shields.io/static/v1?label=APPVIA&message=Terraform%20Registry&color=191970&style=for-the-badge" alt="Terraform Registry"/></a></a> <a href="https://github.com/appvia/terraform-aws-module-template/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-module-template.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-module-template/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-module-template.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](https://github.com/appvia/terraform-aws-module-template/actions/workflows/terraform.yml/badge.svg)

# Terraform AWS VPC Ingress Module

## Description

This module is a secure, reusable Terraform module for ALB/NLB-based ingress in AWS Organizations.

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backends"></a> [backends](#input\_backends) | List of target groups forwarding traffic to backend instances or services | <pre>map(object({<br/>    ## The port on which the target group listens<br/>    port = optional(number, 80)<br/>    ## The priority of the target group (lower numbers have higher priority)<br/>    priority = number<br/>    ## The health check configuration for the target group<br/>    health = object({<br/>      ## Port for health checks (default is the target group port)<br/>      port = optional(string, 80)<br/>      ## Interval in seconds between health checks<br/>      interval = optional(number, 30)<br/>      ## Timeout in seconds for each health check<br/>      timeout = optional(number, 5)<br/>      ## Number of consecutive successful health checks before considering the target healthy<br/>      healthy_threshold = optional(number, 2)<br/>      ## Number of consecutive failed health checks before considering the target unhealthy<br/>      unhealthy_threshold = optional(number, 3)<br/>    })<br/>    ## A list of conditions to match this target group<br/>    condition = object({<br/>      ## The type of condition (e.g., path, host header)<br/>      host_headers = optional(object({<br/>        ## A list of host header values to match (e.g., example.com, *.example.com)<br/>        values = list(string)<br/>      }), null)<br/>      ## A list of HTTP header conditions<br/>      http_header = optional(list(object({<br/>        ## The name of the HTTP header to match<br/>        name = string<br/>        ## The value to match against the header<br/>        values = list(string)<br/>      })), null)<br/>      ## A list of path patterns to match (e.g., /api/*)<br/>      path_patterns = optional(object({<br/>        ## A list of path patterns to match<br/>        values = list(string)<br/>      }), null)<br/>      ## A list of source IP conditions<br/>      source_ips = optional(object({<br/>        ## The CIDR block to match (e.g. 10.0.0/16)<br/>        values = list(string)<br/>      }), null)<br/>    })<br/>    ## Addresses of the backend instances or services<br/>    targets = list(object({<br/>      ## ID of the target (e.g., instance ID, IP address)<br/>      id = string<br/>      ## Port on which the target is listening<br/>      port = number<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Is the name of the load balancer | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets where the Load Balancer will be deployed | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the ALB/NLB will be deployed | `string` | n/a | yes |
| <a name="input_allowed_egress_cidr_blocks"></a> [allowed\_egress\_cidr\_blocks](#input\_allowed\_egress\_cidr\_blocks) | List of CIDR blocks allowed for outbound traffic | `list(string)` | <pre>[<br/>  "10.0.0.0/8"<br/>]</pre> | no |
| <a name="input_allowed_ingress_cidr_blocks"></a> [allowed\_ingress\_cidr\_blocks](#input\_allowed\_ingress\_cidr\_blocks) | List of CIDR blocks allowed for inbound HTTPS traffic | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The certificate ARN for the Load Balancer (optional, required for ALB with HTTPS) | `string` | `null` | no |
| <a name="input_enable_https_redirect"></a> [enable\_https\_redirect](#input\_enable\_https\_redirect) | Enable HTTP to HTTPS redirection (default is true) | `bool` | `true` | no |
| <a name="input_extra_security_groups"></a> [extra\_security\_groups](#input\_extra\_security\_groups) | List of additional security groups to attach to the ALB/NLB | `list(string)` | `[]` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | The port for HTTP traffic (default is 80) | `number` | `80` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | The port for HTTPS traffic (default is 443) | `number` | `443` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | The SSL policy for the Load Balancer (optional, defaults to a secure policy) | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_waf_rule_group_name"></a> [waf\_rule\_group\_name](#input\_waf\_rule\_group\_name) | The name of the AWS WAF rule group to attach to the ALB (must be shared in the account) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | The ARN of the ALB/NLB |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the ALB/NLB |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | The Zone ID of the ALB/NLB (useful for Route 53 alias records) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The security group ID assigned to the load balancer |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | A map of Target Group ARNs |
| <a name="output_target_group_names"></a> [target\_group\_names](#output\_target\_group\_names) | A map of Target Group names |
<!-- END_TF_DOCS -->

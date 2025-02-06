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
| <a name="input_alb_config"></a> [alb\_config](#input\_alb\_config) | Configuration settings for the ALB/NLB | <pre>object({<br/>    name                            = string<br/>    internal                        = bool<br/>    subnets                         = list(string)<br/>    security_groups                 = list(string)<br/>    lb_type                         = string               # "application" for ALB, "network" for NLB<br/>    enable_https                    = optional(bool, true) # ALB only<br/>    certificate_arn                 = optional(string, "")<br/>    ssl_policy                      = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06") # ALB only<br/>    tcp_port                        = optional(number, 443)                                   # NLB only<br/>    waf_web_acl_arn                 = optional(string, "")                                    # ALB only<br/>    shared_waf_rule_group_name      = optional(string, null)                                  # Optional AWS Org WAF Rule Group Name<br/>    baseline_security_group_enabled = optional(bool, true)                                    # Create a default security group for inbound traffic<br/>  })</pre> | n/a | yes |
| <a name="input_target_group_configs"></a> [target\_group\_configs](#input\_target\_group\_configs) | List of target groups forwarding to workload accounts | <pre>list(object({<br/>    name       = string<br/>    port       = number<br/>    protocol   = string<br/>    target_ips = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the ALB/NLB is deployed | `string` | n/a | yes |
| <a name="input_extra_security_groups"></a> [extra\_security\_groups](#input\_extra\_security\_groups) | Additional security groups to attach to the ALB/NLB | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all created resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | The ARN of the ALB/NLB |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the ALB/NLB |
| <a name="output_alb_security_groups"></a> [alb\_security\_groups](#output\_alb\_security\_groups) | The security groups attached to the ALB (if applicable) |
| <a name="output_baseline_security_group_id"></a> [baseline\_security\_group\_id](#output\_baseline\_security\_group\_id) | The ID of the baseline security group created by the module |
| <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn) | The ARN of the HTTP listener (if ALB) |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | The ARN of the HTTPS listener (if ALB) |
| <a name="output_security_groups_attached"></a> [security\_groups\_attached](#output\_security\_groups\_attached) | The security groups attached to the ALB/NLB |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | A map of Target Group ARNs |
| <a name="output_tcp_listener_arn"></a> [tcp\_listener\_arn](#output\_tcp\_listener\_arn) | The ARN of the TCP listener (if NLB) |
| <a name="output_waf_web_acl_association"></a> [waf\_web\_acl\_association](#output\_waf\_web\_acl\_association) | The associated WAF Web ACL ARN (if applied) |
<!-- END_TF_DOCS -->

locals {
  # Merge provided security groups with the baseline security group
  security_groups = concat([aws_security_group.baseline_sg.id], var.extra_security_groups)
}

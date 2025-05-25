
output "targets" {
  description = "A list of backend targets with their details"
  value       = module.lb.targets
}

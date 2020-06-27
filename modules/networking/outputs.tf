output "vpc" {
  value = "module.vpc"
}

output "sg" {
  value = {
    lb = module.lb_sg.security_group.id
  }
}

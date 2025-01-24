output "vpc_id" {
  value = module.net.vpc_id
}

output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}
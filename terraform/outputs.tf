output "vpc_id" {
  value = module.vpc.vpc_id
}



output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}


output "app_ecs_sg" {
  value = aws_security_group.alb_sg.name
}



output "ecs_subnet" {
  value = module.vpc.private_subnets[0]
}


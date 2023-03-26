##################################
# Create an ECS cluster
##################################
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Environment = "dev"
    
  }
}
##################################
# Create a load balancer
##################################
module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"

  name = "ecs-lb"

  subnets         = [module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  security_groups = [aws_security_group.ecs_tasks.id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    }
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  #access_logs = {
  #  bucket = "my-access-logs-bucket"
  #}


  tags = {
  
    Environment = "dev"
  }
}

#############################################
# Create a security group for the ECS tasks
#############################################
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "ecs_tasks_"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

####################################################################
# Create a VPC endpoint for ECS to access the internet gateway
####################################################################
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.ecs_tasks.id]

  endpoints = {
    ecs = {
      # gateway endpoint
      service         = "ecs"
      route_table_ids = flatten(["${module.vpc.private_route_table_ids}"])
      tags            = { Name = "ecs-vpc-endpoint" }
    },
  }

  tags = {
    Environment = "dev"
  }
}

##################################
# Define the task definition
##################################
resource "aws_ecs_task_definition" "my_task_definition" {
  family = "my_task_definition"

container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.container_image
      essential = true
      
      command   = ["serve"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "ap-southeast-2"
          awslogs-group         = aws_cloudwatch_log_group.default.name
          awslogs-stream-prefix = "app"
        }
      }
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])

  cpu       = 256
  memory    = 512
  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.ecs.arn
}

##################################
# Define the ECS service
##################################
resource "aws_ecs_service" "my_service" {
  name            = "my_service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 2

  network_configuration {
    assign_public_ip = false

    security_groups = [aws_security_group.ecs_tasks.id]

    subnets = [module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  }
}


####################################################################
#### Create a security group for the Application Load Balancer  ####
####################################################################
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description      = "port 80"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "allowing healthcheck access"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = [local.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "alb-sg"
  }
}
##################################
### ALB  ######
##################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = [module.vpc.private_subnets[0],module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  security_groups    = [aws_security_group.alb_sg.id]

  #access_logs = {
  #  bucket = "alb-logs"
  #}

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      }
    
  ]

  
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "dev"
  }
}
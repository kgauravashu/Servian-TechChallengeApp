
##############################################
# Create a security group for the RDS instance
##############################################
resource "aws_security_group" "rds_instance" {
  name_prefix = "rds_instance_"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################
#### Create a RDS instance and Database  ####
##############################################
module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "rdsapp"

  engine            = "postgres"
  engine_version    = "10.17"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "app"
  username = "postgres"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.ecs_tasks.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = [module.vpc.database_subnets[0], module.vpc.database_subnets[1], module.vpc.database_subnets[2]]
  

  # DB parameter group
  family = "postgres10"

  # DB option group
  major_engine_version = "10.7"

  # Database Deletion Protection
  deletion_protection = true

  #parameters = [
  #  {
  #    name = "character_set_client"
  #    value = "utf8mb4"
  #  },
  #  {
  #    name = "character_set_server"
  #    value = "utf8mb4"
  #  }
  #]
}



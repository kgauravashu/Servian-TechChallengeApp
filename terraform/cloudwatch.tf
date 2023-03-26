##################################
### Monitoring  ###
##################################

resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/app"
  retention_in_days = 7
}
variable "vpc_id" {
    type = string
    default = "gaurav-vpc"
}

variable "container_image" {
  description = "Application container image"
  default     = "servian/techchallengeapp:latest"
}


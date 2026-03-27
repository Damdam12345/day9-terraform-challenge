variable "server_port" {
  description = "port number for the security group rule for instance and ALB"
  type        = number
  default     = 80
}
variable "ami_id" {
  description = "ami for the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}
variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}
variable "min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
}
variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}
variable "max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
}
variable "tags" {
  description = "Optional extra tags to add to all resources"
  type        = map(string)
  default     = {}
}
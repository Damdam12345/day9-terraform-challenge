# Local values used across the module for naming and tagging
locals {
  name_prefix  = var.cluster_name # Prefix to use for all resource names, based on the cluster name
  common_tags  = merge(
    { Cluster = var.cluster_name },
    var.tags
  )
}

# security group to allow traffic to the server
resource "aws_security_group" "web_sg" {
   name = "${local.name_prefix}-web-sg"
   description = "Allow HTTP traffic"
   vpc_id = var.vpc_id

# allow incoming http traffic
ingress {
  from_port = var.server_port
  to_port = var.server_port
  protocol = "tcp"
  security_groups = [aws_security_group.alb_sg.id]
}

# allow all outgoing traffic
 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
}
  tags = local.common_tags
}

# security group for load balancer to allow traffic to the server
resource "aws_security_group" "alb_sg" {
  name = "${local.name_prefix}-alb-sg"
  description = "Allow HTTP traffic"
  vpc_id= var.vpc_id

# allow incoming http traffic
ingress {
  from_port = var.server_port
  to_port = var.server_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# allow all outgoing traffic
 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
}
    tags = local.common_tags
}

# create launch template to define the configuration of the EC2 instance
resource "aws_launch_template" "webserver" {
  name_prefix = "${local.name_prefix}-webserver-"
  image_id = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(<<-EOF
   #!/bin/bash
   apt-get update -y
   apt-get install -y nginx
   systemctl start nginx
   systemctl enable nginx
   echo "<h1>Welcome to My Terraform Challenge Page</h1>" > /var/www/html/index.html
   EOF
  )

   lifecycle {
    create_before_destroy = true
     }
    tags = local.common_tags
}

# create target group for the load balancer
resource "aws_lb_target_group" "web" {
  name  = "${local.name_prefix}-tg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    port = var.server_port
    protocol = "HTTP"
    interval = 30
    timeout  = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
    tags = local.common_tags
}

# create application load balancer
resource "aws_lb" "webserver" {
  name  = "${local.name_prefix}-alb"
  internal  = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = var.subnet_ids
  tags = local.common_tags
}

# create listener for the load balancer
resource "aws_lb_listener" "webserver_listener" {
  load_balancer_arn = aws_lb.webserver.arn
  port = var.server_port
  protocol = "HTTP"

  default_action {
    type= "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
  tags = local.common_tags
}

# create auto scaling group to manage the EC2 instances
resource "aws_autoscaling_group" "webserver" {
  min_size  = var.min_size
  max_size  = var.max_size

 # spreads instances across default subnets in all availability zones
  vpc_zone_identifier = var.subnet_ids

 # reads the launch template blueprint
  launch_template {
    id = aws_launch_template.webserver.id
    version = "$Latest"
   }

# connects ASG instances to the ALB target group
   target_group_arns = [aws_lb_target_group.web.arn]

  # health check through the ALB not just EC2 status
  health_check_type = "ELB"
  health_check_grace_period = 200

  tag {
   key = "Name"
   value  = "${local.name_prefix}-webserver"
   propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]  # don't override scaling changes
  }
}
##Providing the AWS access cred####
provider "aws" {
  region = "ap-southeast-2"
  access_key = "access_key"
  secret_key = "secret_key"
}
##Adding the default Vpc
data "aws_vpc" "existing_vpc" {
  id = "vpc-02a3e04587e2ae5ad"
}

###Terraform created subnets####
resource "aws_subnet" "new_subnet" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.16.0/20"
  availability_zone = "ap-southeast-2c"
  tags = {
    Name = "Terraform-Owned-VPC"
  }
}


##Subnets-1###
data "aws_subnet" "reuse" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.32.0/20"
  availability_zone = "ap-southeast-2b"
  tags = {
    Name = "Main-2"
  }
}

##Subnets-2####
data "aws_subnet" "reuse-2" {
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.0.0/20"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "Main-1"
  }
}

##########Terraform Imported Target Group - 1######
resource "aws_lb_target_group" "Wildcard-Prod-apac-f4f-com" {
  name = "Wildcard-Prod-apac-f4f-com"
  target_type = "instance"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.existing_vpc.id
  health_check {
    path = "/health"
    interval = 35
    timeout = 5
    healthy_threshold = 6
    unhealthy_threshold = 2
    matcher = "301"
  }
  tags = {
    Name = "Prod"
  }
}

#####Terrafor Imported Target group -2#########
resource "aws_lb_target_group" "service-desk" {
  name = "service-desk"
  target_type = "instance"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.existing_vpc.id
    health_check {
    path = "/health"
    interval = 35
    timeout = 5
    healthy_threshold = 6
    unhealthy_threshold = 2
    matcher = "301"
  }
  tags = {
    Name = "Prod-2"
  }
}

#####Terrafor Imported Target group -3#########
resource "aws_lb_target_group" "barclays" {
  name = "barclays"
  target_type = "instance"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.existing_vpc.id
    health_check {
    path = "/health"
    interval = 35
    timeout = 5
    healthy_threshold = 6
    unhealthy_threshold = 2
    matcher = "301"
  }
  tags = {
    Name = "Prod-3"
  }
}

####Terraform Imported ALB######
resource "aws_lb" "food-lb" {
  name = "food-lb"
  internal = false
  load_balancer_type = "application"

  subnets = [
    data.aws_subnet.reuse.id,
    data.aws_subnet.reuse-2.id,
    #"subnet-05270ba135519444e"
  ]
    tags = {
    Name = "Prod-lb"
  }

}

#####ALB Listener Group of HTTP######
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.food-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.Wildcard-Prod-apac-f4f-com.arn
    type             = "forward"
}
  }

#####ALB Listener Group of HTTPS######
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.food-lb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:ap-southeast-2:036557561906:certificate/d1167f6d-1bde-4417-a0c0-09fe2785ff54"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.Wildcard-Prod-apac-f4f-com.arn

  }
}

#####ALB Listener Group of HTTPS RULE-2######
resource "aws_lb_listener_rule" "HTTPS_Rule_2" {
  listener_arn = aws_alb_listener.https.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service-desk.arn
  }
  condition {
    host_header {
      values = ["service-desk.*"]
    }
  }
}

#####ALB Listener Group of HTTPS RULE-3######
resource "aws_lb_listener_rule" "HTTPS_Rule_3" {
  listener_arn = aws_alb_listener.https.arn
  priority     = 2
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.barclays.arn
  }
  condition {
    host_header {
      values = ["barclays.*"]
    }
  }
}

###Instance####
data "aws_instance" "new_server" {
  instance_id = "i-050bacb3b916583cd"
}

###Attaching the Instance to Target Group-1######
resource "aws_lb_target_group_attachment" "instance-1" {
  target_group_arn = aws_lb_target_group.Wildcard-Prod-apac-f4f-com.arn
  target_id        = "i-050bacb3b916583cd"
  port             = 80
}

###Attaching the Instance to Target Group-2######
resource "aws_lb_target_group_attachment" "instance-2" {
  target_group_arn = aws_lb_target_group.service-desk.arn
  target_id        = "i-050bacb3b916583cd"
  port             = 80
}

###Attaching the Instance to Target Group-3######
resource "aws_lb_target_group_attachment" "instance-3" {
  target_group_arn = aws_lb_target_group.barclays.arn
  target_id        = "i-050bacb3b916583cd"
  port             = 80
}
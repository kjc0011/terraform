###################
# Common Resources
###################
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

###################
# WEB Tier
###################
# WEB Security Group
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# WEB Application Load Balancer
resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets

  tags = {
    Name = "web-alb"
  }
}

# WEB ALB Target Group
resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# WEB ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# WEB Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "web"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = "miniproject2"  # 키 페어 이름 추가

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from WEB Server!</h1>" > /var/www/html/index.html
              EOF
  )

  tags = {
    Name = "web-server"
  }
}

# WEB Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "web-asg"
  desired_capacity    = 1
  max_size           = 2
  min_size           = 1
  target_group_arns  = [aws_lb_target_group.web.arn]
  vpc_zone_identifier = var.private_subnets
  health_check_type  = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value              = "web-server"
    propagate_at_launch = true
  }
}

###################
# WAS Tier
###################
# WAS Security Group
resource "aws_security_group" "was" {
  name        = "was-sg"
  description = "Security group for WAS servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "was-sg"
  }
}

# WAS Launch Template
resource "aws_launch_template" "was" {
  name_prefix   = "was"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = "miniproject2"  # 키 페어 이름 추가

  vpc_security_group_ids = [aws_security_group.was.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd php php-mysql
              systemctl start httpd
              systemctl enable httpd
              echo "<?php phpinfo(); ?>" > /var/www/html/index.php
              EOF
  )

  tags = {
    Name = "was-server"
  }
}

# WAS Auto Scaling Group
resource "aws_autoscaling_group" "was" {
  name                = "was-asg"
  desired_capacity    = 1
  max_size           = 2
  min_size           = 1
  vpc_zone_identifier = var.private_subnets
  health_check_type  = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.was.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value              = "was-server"
    propagate_at_launch = true
  }
}
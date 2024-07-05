
### VPCs ###

resource "aws_vpc" "devops_project" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "devops_project"
  }
}


### Subnets ###

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.devops_project.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az_b
  depends_on              = [aws_vpc.devops_project]

  tags = {
    Name = "public_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.devops_project.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az_c
  depends_on              = [aws_vpc.devops_project]

  tags = {
    Name = "public_b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.devops_project.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az_c
  depends_on        = [aws_vpc.devops_project]

  tags = {
    Name = "private_a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.devops_project.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.az_b
  depends_on        = [aws_vpc.devops_project]

  tags = {
    Name = "private_b"
  }
}


### IGW & NAT GW ###

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_project.id

  tags = {
    Name = "devops_igw"
  }
}


resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "eip" {
  domain = "vpc"
}


### RT ###


resource "aws_route_table" "devops_public" {
  vpc_id = aws_vpc.devops_project.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "public_rt"
  }
}


resource "aws_route_table" "devops_private" {
  vpc_id = aws_vpc.devops_project.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  depends_on = [aws_nat_gateway.natgw]

  tags = {
    Name = "private_rt"
  }
}


resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.devops_public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.devops_public.id
}


resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.devops_private.id
}


resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.devops_private.id
}



### LB ###

resource "aws_lb" "web_lb" {
  name               = "webLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  tags = {
    Environment = "test"
  }
}


### Trget Group ###

### Target Group ###
resource "aws_lb_target_group" "alb-web" {
  name        = "tf-web-lb-alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.devops_project.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

### Target Group Attachments ###
resource "aws_lb_target_group_attachment" "web_server_1" {
  target_group_arn = aws_lb_target_group.alb-web.arn
  target_id        = aws_instance.web_server.id
  port             = 5000
}

resource "aws_lb_target_group_attachment" "web_server_2" {
  target_group_arn = aws_lb_target_group.alb-web.arn
  target_id        = aws_instance.web_server_2.id
  port             = 5000
}


### Listener ###
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-web.arn
  }
}




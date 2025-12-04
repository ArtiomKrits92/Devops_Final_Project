provider "aws" {
  region = var.aws_region
}

# Data source to get Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Conditional VPC creation
resource "aws_vpc" "main" {
  count    = var.use_existing_vpc ? 0 : 1
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Data source for existing VPC
data "aws_vpc" "existing" {
  count = var.use_existing_vpc ? 1 : 0
  id    = var.existing_vpc_id
}

locals {
  vpc_id = var.use_existing_vpc ? var.existing_vpc_id : aws_vpc.main[0].id
  subnet_ids = var.use_existing_vpc ? var.existing_subnet_ids : [aws_subnet.public[0].id, aws_subnet.public2[0].id]
  primary_subnet_id = var.use_existing_vpc ? var.existing_subnet_ids[0] : aws_subnet.public[0].id
}

# Create a public subnet for our EC2 instances
resource "aws_subnet" "public" {
  count                   = var.use_existing_vpc ? 0 : 1
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Create a second public subnet in different availability zone for load balancer
resource "aws_subnet" "public2" {
  count                   = var.use_existing_vpc ? 0 : 1
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# Create Internet Gateway for internet access
resource "aws_internet_gateway" "main" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "main-igw"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id

  # Route all internet traffic through the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public" {
  count          = var.use_existing_vpc ? 0 : 1
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

# Associate route table with second public subnet
resource "aws_route_table_association" "public2" {
  count          = var.use_existing_vpc ? 0 : 1
  subnet_id      = aws_subnet.public2[0].id
  route_table_id = aws_route_table.public[0].id
}
# Security group for Load Balancer
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Allow HTTP traffic from internet"
  vpc_id      = local.vpc_id

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

# Security group for EC2 instances
resource "aws_security_group" "instances" {
  name        = "instance-security-group"
  description = "Allow required ports for cluster"
  vpc_id      = local.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # NodePort for app
  ingress {
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # NFS server
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Kubelet API
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}
# EC2 Instance - Master Node
resource "aws_instance" "master" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = local.primary_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instances.id]

  private_ip = "10.0.1.10"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              EOF

  tags = {
    Name = "master-node"
  }
}

# EC2 Instance - Worker 1
resource "aws_instance" "worker1" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = local.primary_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instances.id]

  private_ip = "10.0.1.11"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              EOF

  tags = {
    Name = "worker-node-1"
  }
}

# EC2 Instance - Worker 2
resource "aws_instance" "worker2" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = local.primary_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instances.id]

  private_ip = "10.0.1.12"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              EOF

  tags = {
    Name = "worker-node-2"
  }
}
# Application Load Balancer
resource "aws_lb" "main" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "app-alb"
  }
}

# ALB attributes - increase idle timeout to 120 seconds for POST requests (NFS writes can be slow)
resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  deregistration_delay = 30  # Wait 30s before removing unhealthy targets during draining

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "app-tg"
  }
}

# ALB idle timeout is set via AWS CLI after creation (not supported as separate resource in this provider version)
# Run: aws elbv2 modify-load-balancer-attributes --load-balancer-arn <arn> --attributes Key=idle_timeout.timeout_seconds,Value=120


# Listener for Load Balancer
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Attach instances to target group
# Only register worker nodes in target group (master is control-plane, doesn't run app pods)
resource "aws_lb_target_group_attachment" "worker1" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.worker1.id
  port             = 30080
}

resource "aws_lb_target_group_attachment" "worker2" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.worker2.id
  port             = 30080
}

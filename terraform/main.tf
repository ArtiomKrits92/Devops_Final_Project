provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Create a public subnet for our EC2 instances
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Create a second public subnet in different availability zone for load balancer
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# Create Internet Gateway for internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route all internet traffic through the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Associate route table with second public subnet
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
# Security group for Load Balancer
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Allow HTTP traffic from internet"
  vpc_id      = aws_vpc.main.id

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
  vpc_id      = aws_vpc.main.id

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
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public.id
  key_name      = "cluster-key"

  vpc_security_group_ids = [aws_security_group.instances.id]

  private_ip = "10.0.1.10"

  tags = {
    Name = "master-node"
  }
}

# EC2 Instance - Worker 1
resource "aws_instance" "worker1" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public.id
  key_name      = "cluster-key"

  vpc_security_group_ids = [aws_security_group.instances.id]

  private_ip = "10.0.1.11"

  tags = {
    Name = "worker-node-1"
  }
}

# EC2 Instance - Worker 2
resource "aws_instance" "worker2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public.id
  key_name      = "cluster-key"

  vpc_security_group_ids = [aws_security_group.instances.id]

  private_ip = "10.0.1.12"

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
  subnets            = [aws_subnet.public.id, aws_subnet.public2.id]

  tags = {
    Name = "app-alb"
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "app-tg"
  }
}

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
resource "aws_lb_target_group_attachment" "master" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.master.id
  port             = 30080
}

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

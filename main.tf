# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

# Create the first subnet in Availability Zone us-east-1a
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Create the second subnet in Availability Zone us-east-1b
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Create a Route Table for the VPC
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  # Add a route to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the first subnet with the Route Table
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

# Associate the second subnet with the Route Table
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

# Create a Security Group for the web application
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  # Allow inbound HTTP traffic
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow inbound SSH traffic
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "ishaterraformbucket"
}

# Launch the first EC2 instance in the first subnet
resource "aws_instance" "webserver1" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))
}

# Launch the second EC2 instance in the second subnet
resource "aws_instance" "webserver2" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))
}

# Create an Application Load Balancer
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webSg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

# Create a Target Group for the ALB
resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  # Health check configuration
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# Attach the first EC2 instance to the Target Group
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

# Attach the second EC2 instance to the Target Group
resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# Create a Listener for the ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  # Default action to forward traffic to the Target Group
  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

# Output the DNS name of the Load Balancer
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}

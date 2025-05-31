provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get available subnets in default VPC
data "aws_subnet" "default" {
  availability_zone = "us-east-1a"  
  default_for_az    = true
}

# Get Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Key pair
resource "aws_key_pair" "my_key" {
  key_name   = "clo835-key"
  public_key = file("clo835-key.pub")
}

# Security group to allow SSH and ports for app
resource "aws_security_group" "clo835_sg" {
  name        = "clo835-sg"
  description = "Allow SSH and web traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow 8081, 8082, 8083
  dynamic "ingress" {
    for_each = [8081, 8082, 8083]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "webapp_host" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.clo835_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.my_key.key_name
  
  iam_instance_profile =  "LabInstanceProfile"

  tags = {
    Name = "clo835-webapp-host"
  }
}

# ECR repository for webapp
resource "aws_ecr_repository" "webapp_repo" {
  name                 = "clo835-webapp"
  image_tag_mutability = "MUTABLE"
}

# ECR repository for mysql
resource "aws_ecr_repository" "mysql_repo" {
  name                 = "clo835-mysql"
  image_tag_mutability = "MUTABLE"
}
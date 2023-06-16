#aws is a provider
provider "aws" {
  region = "ap-south-1"  # Replace with your desired region
  access_key = "AKIAREO4DEESTW3JTPEB"
  secret_key = "KTn7vfhBV5rCXVqKLDuoeH85GShxR99TttriQ97L"
}
#we creating a vpc
resource "aws_vpc" "my_vpc-2" {
  cidr_block = "10.0.0.0/16"
}
#we are creating a public subnet
resource "aws_subnet" "public_subnet-2" {
  vpc_id     = aws_vpc.my_vpc-2.id
  cidr_block = "10.0.1.0/24"
  availability_zone= "ap-south-1a"
  map_public_ip_on_launch = true
}
#we are craeting a private subnet
resource "aws_subnet" "private_subnet-2" {
  vpc_id     = aws_vpc.my_vpc-2.id
  cidr_block = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
}
#we are creating security groups for public subnet
resource "aws_security_group" "public_sg-2" {
  vpc_id = aws_vpc.my_vpc-2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}
#we are creating security for private subnet
resource "aws_security_group" "private_sg-2" {
  vpc_id = aws_vpc.my_vpc-2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#we are creating an instance
resource "aws_instance" "ec2_instance-2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet-2.id
  vpc_security_group_ids = [aws_security_group.public_sg-2.id]


user_data = <<-EOF
    #!/bin/bash
    echo "Starting user data script"
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo aws ecr get-login-password --region ap-south-1 |sudo docker login --username AWS --password-stdin 078307860773.dkr.ecr.ap-south-1.amazonaws.com

     sudo docker pull 078307860773.dkr.ecr.ap-south-1.amazonaws.com/final-assessment-1:latest

     sudo docker run -d -p 80:80 078307860773.dkr.ecr.ap-south-1.amazonaws.com/final-assessment-1:latest

EOF
}
output "public_ip" {
  value = aws_instance.ec2_instance-2.public_ip
}

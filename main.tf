terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = " ~> 5.0"
    }
  }
}

provider "aws" {
  # Configuration options
}


resource "aws_security_group" "tf-docker-sec-gr" {
  name = "docker-sec-group"
  tags = {
    Name = "docker-sec-gr"
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "tf-docker-ec2" {
  ami = "ami-0f9fc25dd2506cf6d"
  instance_type = "t2.micro"
  key_name = "us-east-1-adartis-bahattin"
  security_groups = ["docker-sec-group"]
  tags = {
    Name = "Web Server of Bookstore"
  }

  user_data = <<-EOF
          #! /bin/bash
          yum update -y
          yum install wget -y
          amazon-linux-extras install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
          -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          mkdir -p /home/ec2-user/bookstore-api       
          cd /home/ec2-user/bookstore-api         
          wget https://raw.githubusercontent.com/bahattinatalay/Dockerization-of-Bookstore-Web-API/main/docker-compose.yaml
          wget https://raw.githubusercontent.com/bahattinatalay/Dockerization-of-Bookstore-Web-API/main/bookstore-api.py
          wget https://raw.githubusercontent.com/bahattinatalay/Dockerization-of-Bookstore-Web-API/main/requirements.txt
          wget https://raw.githubusercontent.com/bahattinatalay/Dockerization-of-Bookstore-Web-API/main/Dockerfile
          docker build -t bahattinatalay/bookstoreapi:latest .
          docker-compose up -d
          EOF

 
}

output "website" {
  value = "http://${aws_instance.tf-docker-ec2.public_dns}"

}
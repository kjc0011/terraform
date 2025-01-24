# 개발자용 EC2 보안 그룹
resource "aws_security_group" "dev" {
  name        = "dev-sg"
  description = "Security group for developer instance"
  vpc_id      = var.vpc_id

  # SSH 접속 허용
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

  tags = {
    Name = "dev-sg"
  }
}

# 개발자용 EC2 인스턴스
resource "aws_instance" "dev" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[0]
  key_name      = "miniproject2"  # 키 페어 이름 확인 필요

  vpc_security_group_ids = [aws_security_group.dev.id]

  tags = {
    Name = "developer-instance"
  }
}

# 탄력적 IP 할당
resource "aws_eip" "dev" {
  instance = aws_instance.dev.id
  domain   = "vpc"

  tags = {
    Name = "dev-eip"
  }
}
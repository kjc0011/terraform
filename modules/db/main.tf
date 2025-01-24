# DB 보안 그룹
resource "aws_security_group" "mysql" {
  name        = "mysql-sg"
  description = "Security group for MySQL cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.web_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
  }
}

# DB 서브넷 그룹
resource "aws_db_subnet_group" "mysql" {
  name       = "mysql-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "MySQL DB subnet group"
  }
}

# MySQL DB 클러스터
resource "aws_rds_cluster" "mysql" {
  cluster_identifier     = "mysql-cluster"
  engine                = "aurora-mysql"
  engine_version        = "5.7.mysql_aurora.2.11.2"
  database_name         = "myapp"
  master_username       = var.db_username
  master_password       = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  
  skip_final_snapshot   = true
  
  tags = {
    Name = "mysql-cluster"
  }
}

# DB 인스턴스들
resource "aws_rds_cluster_instance" "mysql" {
  count               = 2
  identifier          = "mysql-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.mysql.id
  instance_class      = "db.t3.small"
  engine              = aws_rds_cluster.mysql.engine
  engine_version      = aws_rds_cluster.mysql.engine_version
}
resource "aws_db_subnet_group" "main-db-sg" {
  name       = "ha-webapp-db-sg"
  subnet_ids = [aws_subnet.private-DB-subnet-az1.id, aws_subnet.private-DB-subnet-az2.id]

  tags = {
    Name = "My ha webapp DB subnet group"
  }
}

resource "aws_db_instance" "main-db-instance" {
  allocated_storage           = 20
  max_allocated_storage       = 50
  db_name                     = "hadb"
  identifier                  = "ha-webapp-db"
  engine                      = "mysql"
  instance_class              = "db.t3.micro"
  multi_az                    = true
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.DB-SG.id]
  db_subnet_group_name        = aws_db_subnet_group.main-db-sg.name
  storage_encrypted           = true
  username                    = "dbadminilia"
  manage_master_user_password = true
  skip_final_snapshot         = true
  deletion_protection         = false
}
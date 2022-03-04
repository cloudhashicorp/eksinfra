resource "aws_db_instance" "rdsforeks" {

  engine         = "mysql"
  engine_version = "8.0.20"
  instance_class = "db.t3.medium"

  allocated_storage = 20
  storage_encrypted = false

  name     = "rubriccloudrds"
  username = "myrdsadmin"
  password = "YourPwdShouldBeLongAndSecure!"
  port     = 3306

  vpc_security_group_ids = [var.outrdsrubriccloudapp]
  db_subnet_group_name   = var.outrdssubnetgroup

  availability_zone   = var.azsrds

  skip_final_snapshot  = true
 
 

}
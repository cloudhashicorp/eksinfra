# Search for Amazon Linux AMI

data "aws_ami" "amazon_linux_lc" {

  most_recent = true
  owners      = ["amazon"]


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#Bastion Launch Configuration
resource "aws_launch_configuration" "bastionrubriccloudapp" {

  name                        = var.bastionname
  image_id                    = data.aws_ami.amazon_linux_lc.id
  instance_type               = var.bastioninstancetype
  key_name                    = var.keyname
  security_groups             = [var.outbastionrubriccloudapp]
  associate_public_ip_address = var.asspubip

}

#Webserver Launch Configuration
resource "aws_launch_configuration" "webserverrubriccloudapp" {

  name            = var.webserverame
  image_id        = data.aws_ami.amazon_linux_lc.id
  instance_type   = var.webserverinstancetype
  key_name        = var.keyname
  user_data       = file("./lc/web.sh")
  security_groups = [var.outwebserverrubriccloudapp]


}


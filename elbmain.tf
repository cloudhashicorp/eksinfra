resource "aws_elb" "rubriccloudappelb" {

  name            = var.webserverelbname
  internal        = var.webserverintelb
  security_groups = [var.outelbsgrubriccloudapp]
  subnets         = var.outrubriccloudapppubsub


  listener {

    instance_port     = var.webserverinstanceport1
    instance_protocol = var.webserverinstanceprotocol1
    lb_port           = var.webserverlbport1
    lb_protocol       = var.webserverlbprotocol1
  }

  health_check {
    healthy_threshold   = var.webserverhcthreshold
    unhealthy_threshold = var.webserverunthreshold
    timeout             = var.webserverhctimeout
    target              = var.webserverhctarget
    interval            = var.webserverhcinterval
  }


}
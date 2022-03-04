#Bastion
resource "aws_autoscaling_group" "bastionrubriccloudapp" {

  name                      = var.bastionasgname
  min_size                  = var.bastionminsize
  max_size                  = var.bastionmaxsize
  desired_capacity          = var.bastiondesiredcap
  launch_configuration      = var.outbastionrubriccloudapp
  vpc_zone_identifier       = var.outrubriccloudapppubsub
  health_check_type         = var.bastionhctype
  force_delete              = var.bastionforcedel
  health_check_grace_period = var.bastionhcgraceperiod
}

#WebServer
resource "aws_autoscaling_group" "webserverrubriccloudapp" {

  name                      = var.webserverasgname
  min_size                  = var.webservernminsize
  max_size                  = var.webservermaxsize
  desired_capacity          = var.webserverdesiredcap
  launch_configuration      = var.outwebserverrubriccloudapp
  vpc_zone_identifier       = var.outrubriccloudappprisub
  health_check_type         = var.webserverhctype
  force_delete              = var.webserverforcedel
  health_check_grace_period = var.webserverhcgraceperiod
}

resource "aws_autoscaling_attachment" "webserver_asg_elb_attachment" {

  autoscaling_group_name = aws_autoscaling_group.webserverrubriccloudapp.id
  elb                    = var.outrubriccloudappelb
}


resource "aws_autoscaling_policy" "example" {

  name                   = "webserver-auto-scaling"
  autoscaling_group_name = aws_autoscaling_group.webserverrubriccloudapp.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40
  }


}
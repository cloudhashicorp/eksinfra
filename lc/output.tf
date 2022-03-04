output "outbastionrubriccloudapp" {

  value = aws_launch_configuration.bastionrubriccloudapp.id
}

output "outwebserverrubriccloudapp" {

  value = aws_launch_configuration.webserverrubriccloudapp.id
}


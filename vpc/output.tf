
output "outbastionrubriccloudapp" {

  value = aws_security_group.bastionrubriccloudapp.id
}

output "outrubriccloudapppubsub" {

  value = aws_subnet.rubriccloudapppubsub.*.id
}

output "outwebserverrubriccloudapp" {

  value = aws_security_group.webserverrubriccloudapp.id
}

output "outrubriccloudappprisub" {

  value = aws_subnet.rubriccloudappprisub.*.id
}

output "outelbsgrubriccloudapp" {

  value = aws_security_group.elbsgrubriccloudapp.id
}


output "outrdsrubriccloudapp" {

  value = aws_security_group.rdsrubriccloudapp.id
}


output "outrdssubnetgroup" {

  value = aws_db_subnet_group.rdssubnetgroup.id
}


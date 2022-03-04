
resource "aws_vpc" "vpcrubriccloudapp" {

  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igwrubriccloudapp" {

  vpc_id = aws_vpc.vpcrubriccloudapp.id

  tags = {
    Name = var.igw_name
  }
}

#Public Subnets
resource "aws_subnet" "rubriccloudapppubsub" {

  count             = length(var.pubsub)
  vpc_id            = aws_vpc.vpcrubriccloudapp.id
  cidr_block        = var.pubsub[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  #check needs to be done in this line for tagging
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tagspubsub,
  )
}


#Public Route
resource "aws_route_table" "rubriccloudapppubroute" {

  vpc_id = aws_vpc.vpcrubriccloudapp.id

  tags = {

    Name = var.pubroutename
  }
}

resource "aws_route" "rubriccloudappigwassoc" {

  route_table_id         = aws_route_table.rubriccloudapppubroute.id
  destination_cidr_block = var.wideopensub
  gateway_id             = aws_internet_gateway.igwrubriccloudapp.id
}

resource "aws_route_table_association" "rubriccloudapppubsubassoc" {

  count          = length(var.pubsub)
  subnet_id      = element(aws_subnet.rubriccloudapppubsub.*.id, count.index)
  route_table_id = aws_route_table.rubriccloudapppubroute.id
}

#Private Subnets
resource "aws_subnet" "rubriccloudappprisub" {

  count             = length(var.prisub)
  vpc_id            = aws_vpc.vpcrubriccloudapp.id
  cidr_block        = var.prisub[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tagsprisub,
  )

}

#Private Route
resource "aws_route_table" "rubriccloudapppriroute" {

  vpc_id = aws_vpc.vpcrubriccloudapp.id

  tags = {

    Name = var.priroutename
  }
}

resource "aws_eip" "nateip" {
  vpc = true
}

resource "aws_nat_gateway" "natrubriccloudapp" {

  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.rubriccloudapppubsub.0.id
  depends_on    = [aws_internet_gateway.igwrubriccloudapp]
}

resource "aws_route" "rubriccloudappnatassoc" {

  route_table_id         = aws_route_table.rubriccloudapppriroute.id
  destination_cidr_block = var.wideopensub
  nat_gateway_id         = aws_nat_gateway.natrubriccloudapp.id
}

resource "aws_route_table_association" "rubriccloudappprisubassoc" {

  count          = length(var.prisub)
  subnet_id      = element(aws_subnet.rubriccloudappprisub.*.id, count.index)
  route_table_id = aws_route_table.rubriccloudapppriroute.id
}

###########NACL

resource "aws_network_acl" "rubriccloudappnacl" {

  vpc_id     = aws_vpc.vpcrubriccloudapp.id
  subnet_ids = aws_subnet.rubriccloudapppubsub.*.id

  egress {

    protocol   = var.naclprotocol_egress
    rule_no    = var.naclruleno_egress
    action     = var.naclaction_egress
    cidr_block = var.wideopensub
    from_port  = var.naclfrom_port_egress
    to_port    = var.naclto_port_egress

  }

  ingress {

    protocol   = var.naclprotocol_ingress
    rule_no    = var.naclruleno_ingress
    action     = var.naclaction_ingress
    cidr_block = var.wideopensub
    from_port  = var.naclfrom_port_ingress
    to_port    = var.naclto_port_ingress

  }

}


#####Security Groups

#BastionSG
resource "aws_security_group" "bastionrubriccloudapp" {

  name        = "BastionSG"
  description = "Security Group for SSH to Bastion"
  vpc_id      = aws_vpc.vpcrubriccloudapp.id

  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.wideopensub]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.wideopensub]

  }

}



#LoadBalancerSG
resource "aws_security_group" "elbsgrubriccloudapp" {

  name        = "LoadBalancerSG"
  description = "Security Group for ELB"
  vpc_id      = aws_vpc.vpcrubriccloudapp.id


  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.wideopensub]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.wideopensub]

  }

}

#WebServerSG
resource "aws_security_group" "webserverrubriccloudapp" {

  name        = "WebServerSG"
  description = "Security Group for WebServer"
  vpc_id      = aws_vpc.vpcrubriccloudapp.id

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.wideopensub]

  }

}

resource "aws_security_group_rule" "webserverrule" {

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.elbsgrubriccloudapp.id
  security_group_id        = aws_security_group.webserverrubriccloudapp.id
}

resource "aws_security_group_rule" "bastionwebserverrule" {

  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastionrubriccloudapp.id
  security_group_id        = aws_security_group.webserverrubriccloudapp.id
}


#################################################################
//EKS 

resource "aws_subnet" "rdssubnet" {

  count             = length(var.prirdssub)
  vpc_id            = aws_vpc.vpcrubriccloudapp.id
  cidr_block        = var.prirdssub[count.index]
  availability_zone = var.azs[count.index]

}

resource "aws_db_subnet_group" "rdssubnetgroup" {

  name       = "rdssubnetgroupforeks"
  subnet_ids = [aws_subnet.rdssubnet.0.id, aws_subnet.rdssubnet.1.id]

}

#EKS RDS Security Group
resource "aws_security_group" "rdsrubriccloudapp" {

  name        = "RDSekssg"
  description = "Security Group for RDS"
  vpc_id      = aws_vpc.vpcrubriccloudapp.id


  ingress {

    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "MySQL access from within VPC"
    cidr_blocks = [var.wideopensub]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.wideopensub]

  }

}









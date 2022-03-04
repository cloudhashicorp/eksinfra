############################################################
#Author   : Darwin Panela                                  #
#LinkedIn : https://www.linkedin.com/in/darwinpanelacloud/ #
#github   : https://github.com/cloudhashicorp              #
############################################################


#####
#VPC#
#####

module "vpcmod" {
  source     = "./vpc"
  name       = "rubriccloudProj Public Subnet"
  priname    = "rubriccloudProj Private Subnet"
  cidr_block = "10.0.0.0/16"
  azs        = ["us-east-1a", "us-east-1b", "us-east-1c"]

  pubsub    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  prisub    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  prirdssub = ["10.0.14.0/24", "10.0.15.0/24", "10.0.16.0/24"]

  pubroutename       = "rubriccloud Public Route"
  priroutename       = "rubriccloud Private Route"
  wideopensub        = "0.0.0.0/0"
  nameinternallbtest = "allow_all_internal"
  descinternallbtest = "Allow Traffic from All"

  protocol_ingress    = "tcp"
  sgfrom_port_ingress = 80
  sgto_port_ingress   = 80
  protocol_egress     = "-1"
  sgfrom_port_egress  = 0
  sgto_port_egress    = 0

  naclprotocol_egress  = "-1"
  naclruleno_egress    = 200
  naclaction_egress    = "allow"
  naclfrom_port_egress = 0
  naclto_port_egress   = 0

  naclprotocol_ingress  = "-1"
  naclruleno_ingress    = 100
  naclaction_ingress    = "allow"
  naclfrom_port_ingress = 0
  naclto_port_ingress   = 0

  #outrubriccloudappprisub = module.vpcmod.outrubriccloudappprisub




  tagspubsub = {
    Owner       = "rubriccloudapp"
    Environment = "Production"
    Name        = "Public Subnet"

  }

  tagsprisub = {
    Owner       = "rubriccloudapp"
    Environment = "Production"
    Name        = "Private Subnet"

  }

}

#Launch Configuration
module "lcmod" {
  source = "./lc"

  bastionname              = "bastion_lc"
  bastioninstancetype      = "t2.medium"
  keyname                  = module.keypairmod.outmyec2key
  outmyec2key              = module.keypairmod.outmyec2key
  asspubip                 = true
  outbastionrubriccloudapp = module.vpcmod.outbastionrubriccloudapp

  webserverame               = "webserver_lc"
  webserverinstancetype      = "t2.medium"
  outwebserverrubriccloudapp = module.vpcmod.outwebserverrubriccloudapp


  depends_on = [module.keypairmod.outmyec2key]
}

#AutoScaling Group

module "asgmod" {
  source = "./asg"

  bastionasgname           = "bastion-asg-rubriccloudapp"
  bastionminsize           = 1
  bastionmaxsize           = 1
  bastiondesiredcap        = 1
  outbastionrubriccloudapp = module.lcmod.outbastionrubriccloudapp
  outrubriccloudapppubsub  = module.vpcmod.outrubriccloudapppubsub
  bastionhctype            = "EC2"
  bastionforcedel          = true
  bastionhcgraceperiod     = 300


  webserverasgname           = "webserver-asg-rubriccloudapp"
  webservernminsize          = 0
  webservermaxsize           = 0
  webserverdesiredcap        = 0
  outwebserverrubriccloudapp = module.lcmod.outwebserverrubriccloudapp
  outrubriccloudappprisub    = module.vpcmod.outrubriccloudappprisub
  webserverhctype            = "EC2"
  webserverforcedel          = true
  webserverhcgraceperiod     = 300

  outrubriccloudappelb = module.elbmod.outrubriccloudappelb

}

#ELB 

module "elbmod" {

  source = "./elb"

  webserverelbname        = "web-rubriccloudapp-elb"
  webserverintelb         = false
  outelbsgrubriccloudapp  = module.vpcmod.outelbsgrubriccloudapp
  outrubriccloudapppubsub = module.vpcmod.outrubriccloudapppubsub

  webserverinstanceport1     = 80
  webserverinstanceprotocol1 = "http"
  webserverlbport1           = 80
  webserverlbprotocol1       = "http"

  webserverhcthreshold = 10
  webserverunthreshold = 2
  webserverhctimeout   = 2
  webserverhctarget    = "HTTP:80/index.html"
  webserverhcinterval  = 5
}

#Keypair
module "keypairmod" {

  source = "./keypair"

}


#EKS
module "eksmod" {

  source = "./eks"

  outrubriccloudappprisub = module.vpcmod.outrubriccloudappprisub
  outmyec2key             = module.keypairmod.outmyec2key
  outrubriccloudapppubsub = module.vpcmod.outrubriccloudapppubsub

}

#RDS
module "rdsmod" {

  source = "./rds"

  outrdsrubriccloudapp = module.vpcmod.outrdsrubriccloudapp
  outrdssubnetgroup = module.vpcmod.outrdssubnetgroup
  azsrds        = "us-east-1a"


}




#terraform {
# backend "s3" {
#  bucket     = "myrubriccloudbucket"
# region     = "us-east-1"
#key        = "terraform.tfstate"
#access_key = "AKIA6EGNWL7QMRINKRCL"
#secret_key = "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"
#}
#}







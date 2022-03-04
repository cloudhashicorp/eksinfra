#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
echo “Hello World from $(hostname -f)” > /var/www/html/index.html
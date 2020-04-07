#!/bin/bash

yum -y update
yum -y install epel-release
sudo yum -y install git mlocat
echo "Script working" | sudo tee -a /home/centos/hello.txt

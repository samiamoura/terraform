resource "aws_key_pair" "admin" {
   key_name   = "admin"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9IMCNwoUjeypA5VfK6HX6xseM7PS5eZNnc1WQxwyJByFP+2Jms7eXydARGkpkdLA3IBkNHrNYvf9UKoHFlJrN+meC8GfGE1nbY9523clft4qlL4hR3nXWvakGSGZd1TdEOMDzjCjUA+Ju2XKNkIdUPXyjw95KV2o2N9Em90L2B8w5KWt+PxNIxMYBbs0gm/ylYrMHBYlYwGjnR1JipOVzlyaY/6JBDIWPi/RsP0cldQ31mORM7jS3Xhs03u5OChdgrJoSvivKuqBAoyCdwjJOvWxxg65ObFIqr0a/DL5i+zXPNT4Z2PVCZ4ajB0XjAidAvIWCACXzqBz6H7m78VcJ root@ip-172-31-85-168.ec2.internal"
 }
 resource "aws_instance" "server1" {
   ami           = "ami-0083662ba17882949"
   instance_type = "t2.micro"
   key_name      = "admin"
 }

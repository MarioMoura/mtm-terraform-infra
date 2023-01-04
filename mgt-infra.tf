# __  __ _____ __  __           ____
#|  \/  |_   _|  \/  | ___  ___|___ \
#| |\/| | | | | |\/| |/ _ \/ __| __) |
#| |  | | | | | |  | |  __/ (__ / __/
#|_|  |_| |_| |_|  |_|\___|\___|_____|
#        _        __
#       (_)_ __  / _|_ __ __ _
#       | | '_ \| |_| '__/ _` |
#       | | | | |  _| | | (_| |
#       |_|_| |_|_| |_|  \__,_|


# aws-cli config
provider "aws" {
  region  = "us-west-2"
}

# ec2.metaltoad.net Route 53 Hosted zone
resource "aws_route53_zone" "ec2" {
  #id = "Z5MHJW80DKWLT"
  name = "ec2.metaltoad.net"
  comment = ""
}

#==================== VPN01 ================================
resource "aws_instance" "vpn01" {
  ami                     = "ami-0b7237d6459a73a69"
  subnet_id               = "subnet-0c7c142262a36a911"
  instance_type           = "t2.medium"
  #source_dest_check = false
  tags                    = {
        "Backup"          = ""
        "Name"            = "vpn01-mtm"
  }
  lifecycle {
    ignore_changes        = [user_data,user_data_replace_on_change]
  }
}
#==================== Mgt02 ================================
resource "aws_instance" "mgt02" {
  ami                     = "ami-e699f3d6"
  subnet_id               = "subnet-208b7f57"
  instance_type           = "m3.large"
  source_dest_check       = false
  tags                    = {
    "Backup"              = ""
    "Client"              = "mtm-int"
    "Name"                = "mgt02-mtm"
    "SystemManager"       = "ManagedServices"
    "cloudfix:finderIds"  = "InstallSSMAgentLinuxMac"
    "project"             = "test"
  }
  user_data               = "mgt02-mtm"
}
#==================== Mgt03 ================================
resource "aws_instance" "mgt03" {
  ami                     = "ami-05336235"
  subnet_id               = "subnet-208b7f57"
  instance_type           = "t2.medium"
  tags                    = {
     "Backup"             = ""
     "Client"             = "mtm-int"
     "Name"               = "mgt03-mtm"
     "SystemManager"      = "ManagedServices"
     "cloudfix:finderIds" = "InstallSSMAgentLinuxMac"
  }
  user_data               = "hostname=mgt03-mtm"
}
#==================== Mgt04 ================================
resource "aws_instance" "mgt04" {
  ami                     = "ami-03e737ff90d808f02"
  subnet_id               = "subnet-208b7f57"
  instance_type           = "m4.large"
  tags                    = {
    "Backup"              = ""
    "Name"                = "mgt04-mtm"
    "SystemManager"       = "ManagedServices"
    "cloudfix:finderIds"  = "InstallSSMAgentLinuxMac"
  }
  user_data               = ""
}
#==================== Mgt05 ================================
resource "aws_key_pair" "mtm-mgt05" {
  key_name   = "mtm-mgt05"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRDED9sl0qkx+ORUK7PAIhLX0e0hK6SRJhTz3u6zqSbFbNsAeffyxPF1CxIN09eRjW1s1o3yuiS5xmhq69FD7gmyr6T3tB+k+4pQMcDitgSw4+Ov1KaFTQAnLpAyUCSEMCPNDabpfTMYUH8mjhLRVaNSwynsmK03Ompxtel53QP2ujgYbMmXowYvTn2tNn2nXOjw5EcvFTjbUHoww94q9gw4EQ9nqCbRMs4YjXHZzrfj1Ycl767l9lRNGFb79gmEF/sGpCqQMvhNqpxElhG1357TXUpCNl+TVCTGdsanGWcpIh0qfIVzqh9dKy03eBHX0mPvPsQA/mmvP2zY2qD79X"
}
resource "aws_instance" "mgt05" {
  ami                     = "ami-0c09c7eb16d3e8e70"
  subnet_id               = "subnet-208b7f57"
  instance_type           = "m3.large"
  tags                    = { Name  = "mgt05-mtm"
     "cloudfix:finderIds" = "InstallSSMAgentLinuxMac"
  }
  user_data               = ""
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [ "sg-0ce61f4196acd2274",
    "sg-1971f07c",
    "sg-02168c73f3f67b0d6",]
  key_name                    = "mtm-mgt05"
}
resource "aws_route53_record" "mgt05_dns" {
  zone_id                 = aws_route53_zone.ec2.zone_id
  name                    = "mgt05-mtm.${aws_route53_zone.ec2.name}"
  type                    = "CNAME"
  ttl                     = "300"
  records                 = ["${aws_instance.mgt05.public_dns}"]
}

#==================== Mgt06 ================================
resource "aws_key_pair" "mtm-mgt06" {
  key_name   = "mtm-mgt06"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDA9C5oOcNB3pcN1rI7pAWk6WSeXsHWtJwCMlxNv6P/giNo6vDi8cGUuVdy98C2wapdrlRmnsjElN0baVWy2Hrfs1Dl5Pa8Cn2Nk54GkfkbBhPYHFfB77ssw1PLWmjpYr4jrHdv9eMqCTfugqNeM9StOdCBK0lE6M3xNYnkPrhAxkuoFXnDzM24620VAA4IOFBJS8V45VqoDnuz/3utnecPa0CDRvvmY6qLfGm6CqYRJGlMeCWgH3nPh9QlSy0qqv9eCfnWZuN417bGcigtfPcUcYnRceIp069vOGMGwMJITbfbtqfFXbYzSFmf4a4O2XaJ3LvUWc4Apzc6l47fnxym+a6rxFn7Enujsdlt+AdAroh7SwCUARPtd+q5UR26gQilnLqPUhTto+PZfURBQ8a7xbxPbcDORfQQ4HVez2BPxmPcUSPyG/M7Hn48LJVLvMwx5+mZPzbGKc2e6TfXpLuVOQPXHte6lBbSGjKvvRMe3CVC8plZ4GQMOykYH3xWbm0= mario@mmoura"
}
resource "aws_instance" "mgt06" {
  ami                         = "ami-0c09c7eb16d3e8e70"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-208b7f57"
  vpc_security_group_ids      = [ "sg-0ce61f4196acd2274",
    "sg-1971f07c",
    "sg-02168c73f3f67b0d6",]
  key_name                    = "mtm-mgt06"
  tags = { Name               = "mgt06-mtm"
  }
  associate_public_ip_address = "true"
  user_data = ""
}
resource "aws_route53_record" "mgt06_dns" {
  zone_id = aws_route53_zone.ec2.zone_id
  name    = "mgt06-mtm.${aws_route53_zone.ec2.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_instance.mgt06.public_dns}"]
}


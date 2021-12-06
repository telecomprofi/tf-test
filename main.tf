provider "aws" {
  region = var.region
}

#-------------------------------------------------------------------------------
# Datasources
#-------------------------------------------------------------------------------


data "aws_availability_zones" "available" {
}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}


data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "aws_ami" "latest_windows_2016" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }

}

// How to use
/*
resource "aws_instance" "my_webserver_with_latest_ubuntu_ami" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t3.micro"
}
*/

output "aws_availability_zones_available_az1" {
  value = data.aws_availability_zones.available.names[0]
}

output "aws_availability_zones_available_az2" {
  value = data.aws_availability_zones.available.names[1]
}

output "latest_windows_2016_ami_name" {
  value = data.aws_ami.latest_windows_2016.name
}


output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.latest_amazon_linux.name
}


output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}

output "latest_ubuntu_ami_name" {
  value = data.aws_ami.latest_ubuntu.name
}



# name_prefix = "${var.deployment_name}"
# description = "resource for ${var.deployment_name} deployment."


#resource "aws_instance" "instance" {
#  count = "${var.instance_count}"
#  tags = {
#    Name = "${var.deployment_name}-ecs-${count.index}"
#  }
#}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Default subnet for az1 in ${var.region}"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Default subnet for az2 in ${var.region}"
  }
}

#--------------------------------------------------------------
resource "aws_security_group" "nlb-web" {
  name   = "Dynamic Security Group"
  vpc_id = var.vpc_nlb

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "nlb-ec2-instances-sg"
    Deployment = "${var.deployment_name}"

  }
}

#-------------------------------------------------------------------------------
# aws EC2 instances for NLB target group attachment
#-------------------------------------------------------------------------------
resource "aws_instance" "nlb-ec2-01" {
  ami             = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.instance_type
  subnet_id       = "subnet-0e478f75ccc8a0afd"
  security_groups = [aws_security_group.nlb-web.id]
  user_data       = file("user_data_01.sh")
  key_name        = "example-nlb-key-pair-for-ec2-instance"
  tags            = merge(var.common_tags, { Name = "${var.common_tags["Env"]}-${var.deployment_name}-ec2-01" })
  metadata_options {

    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_instance" "nlb-ec2-02" {
  ami             = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.instance_type
  subnet_id       = "subnet-09d02d930b3cb0c37" # !!!!! remove hardcoded subnet-id in az2
  security_groups = [aws_security_group.nlb-web.id]
  user_data       = file("user_data_02.sh")
  key_name        = "example-nlb-key-pair-for-ec2-instance"
  #  key_name = "EC2-01"  name of the public key imported into every region as described below:
  # https://aws.amazon.com/premiumsupport/knowledge-center/ec2-ssh-key-pair-regions
  tags = merge(var.common_tags, { Name = "${var.common_tags["Env"]}-${var.deployment_name}-ec2-02" })
  metadata_options {

    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

#-------------------------------------------------------------------------------
#  nlb resource
#-------------------------------------------------------------------------------


resource "aws_lb" "nlb" {
  name_prefix        = "nlb-"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-0e478f75ccc8a0afd", "subnet-09d02d930b3cb0c37"] # !!!! Hardcoded for 1st test

  # subnet_mapping {
  #    subnet_id     = aws_subnet.example1.id
  #    allocation_id = aws_eip.example1.id
  #  }

  #  subnet_mapping {
  #    subnet_id     = aws_subnet.example2.id
  #    allocation_id = aws_eip.example2.id
  #  }

  enable_deletion_protection = false
  tags                       = merge(var.common_tags, { Name = "${var.common_tags["Env"]}-${var.deployment_name}-nlb" })

}

resource "aws_lb_target_group" "nlb-tg" {
  name     = "nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_nlb
}

resource "aws_lb_target_group_attachment" "nlb-tg-att-01" {
  target_group_arn = aws_lb_target_group.nlb-tg.arn
  target_id        = aws_instance.nlb-ec2-01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nlb-tg-att-02" {
  target_group_arn = aws_lb_target_group.nlb-tg.arn
  target_id        = aws_instance.nlb-ec2-02.id
  port             = 80
}


resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"  #"443"
  protocol          = "TCP" # "TLS"
  #  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  # alpn_policy = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-tg.arn
  }
}
#
# resource "aws_vpc" "nlb_vpc" {
#  cidr_block = "10.0.0.0/16"     # !!!! remove hardcoded NLB VPC ID
# }

output "default_vpc_id" {
  value = aws_default_subnet.default_az1.vpc_id
}

output "ec2_instance_01_public_ip" {
  value = aws_instance.nlb-ec2-01.public_ip

}

output "ec2_instance_01_public_dns" {
  value = aws_instance.nlb-ec2-01.public_dns

}


output "ec2_instance_02_public_ip" {
  value = aws_instance.nlb-ec2-02.public_ip

}

output "ec2_instance_02_public_dns" {
  value = aws_instance.nlb-ec2-02.public_dns

}
output "aws_nlb_url" {
  value = aws_lb.nlb.dns_name
}

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

output "aws_availability_zones_available" {
  value = data.aws_availability_zones.available.names
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
    Name = "Default subnet for ${var.region}"
  }
}


resource "aws_instance" "example" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_type
  tags          = merge(var.common_tags, { Name = "${var.common_tags["Env"]}-${var.deployment_name}-ec2-01" })
  metadata_options {

    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

output "default_vpc_id" {
  value = aws_default_subnet.default_az1.vpc_id
}

output "ec2_instance_public_ip" {
  value = aws_instance.example.public_ip

}

output "ec2_instance_public_dns" {
  value = aws_instance.example.public_dns

}

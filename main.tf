provider "aws" {
  region = var.region
}

#-------------------------------------------------------------------------------
# Datasources
#-------------------------------------------------------------------------------


data "aws_availability_zones" "available" {
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#-------------------------------------------------------------------------------
# resourcres
#-------------------------------------------------------------------------------

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

resource "aws_security_group" "nlb-web" {
  name   = "nlb web security group"
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
  name_prefix                = "nlb-"
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = ["subnet-0e478f75ccc8a0afd", "subnet-09d02d930b3cb0c37"] # !!!! Hardcoded for 1st test
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
  port              = "443" #"80"  #"443"
  protocol          = "TLS" #"TCP" # "TLS"
  certificate_arn   = "arn:aws:acm:us-east-1:612971418332:certificate/aea72a5f-c3c1-435e-b2a2-e7e24a134bdc"
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-tg.arn
  }
}

resource "aws_route53_record" "www" {
  zone_id = "Z092355622GPYS5PIU7EY" #aws_route53_zone.primary.zone_id
  name    = "www.telecomprofi.net"
  type    = "A"
  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = true
  }

}

#-------------------------------------------------------------------------------
# Outputs
#-------------------------------------------------------------------------------


output "ec2_01_public_ip" {
  value = aws_instance.nlb-ec2-01.public_ip
}

output "ec2_02_public_ip" {
  value = aws_instance.nlb-ec2-02.public_ip
}


output "aws_nlb_url" {
  value = aws_lb.nlb.dns_name
}


output "aws_route53_a_record_fqdn" {
  value = aws_route53_record.www.fqdn
}

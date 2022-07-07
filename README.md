<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.
<tba>

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_subnet.default_az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet) | resource |
| [aws_default_subnet.default_az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet) | resource |
| [aws_instance.nlb-ec2-01](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.nlb-ec2-02](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.nlb-tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.nlb-tg-att-01](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.nlb-tg-att-02](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.nlb-web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.latest_amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Enter common tags that wil be applied to all resources created by module. | `map(any)` | <pre>{<br>  "CostCenter": "2345",<br>  "Env": "Dev",<br>  "Owner": "Vasya Pupkin",<br>  "Project": "MissionImpossible"<br>}</pre> | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Enter the name for current deployment. It will be used to prefix names of the components | `string` | `"XXX"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Enter EC2 Instance type, default is t2.micro | `string` | `"t2.micro"` | no |
| <a name="input_list"></a> [list](#input\_list) | List of | `list(string)` | <pre>[<br>  "item1",<br>  "item2"<br>]</pre> | no |
| <a name="input_nlb_listeners"></a> [nlb\_listeners](#input\_nlb\_listeners) | One or more NLB listeners with their respective Protocol and Port | <pre>list(object({<br>    protocol = string<br>    port     = number<br>  }))</pre> | <pre>[<br>  {<br>    "port": 443,<br>    "protocol": "tcp"<br>  }<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | Enter the AWS region to spin resources in | `string` | `"us-east-1"` | no |
| <a name="input_vpc_nlb"></a> [vpc\_nlb](#input\_vpc\_nlb) | Enter VPC Id in which nlb and instances has to be created | `string` | `"vpc-09b1d251ab7e0b54c"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_nlb_url"></a> [aws\_nlb\_url](#output\_aws\_nlb\_url) | n/a |
| <a name="output_aws_route53_a_record_fqdn"></a> [aws\_route53\_a\_record\_fqdn](#output\_aws\_route53\_a\_record\_fqdn) | n/a |
| <a name="output_ec2_01_public_ip"></a> [ec2\_01\_public\_ip](#output\_ec2\_01\_public\_ip) | n/a |
| <a name="output_ec2_02_public_ip"></a> [ec2\_02\_public\_ip](#output\_ec2\_02\_public\_ip) | n/a |
<!-- END_TF_DOCS -->

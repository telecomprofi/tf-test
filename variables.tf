variable "region" {
  description = "Enter the AWS region to spin resources in"
  type        = string
  default     = "us-east-1"
}

variable "deployment_name" {
  description = "Enter the name for current deployment. It will be used to prefix names of the components"
  #default     = "nlb_example"
  # usage in tf code:
  # resource "aws_iam_role" "instance" {
  #   name_prefix = "${var.deployment_name}"
  #   description = "NLB for the ${var.deployment_name} deployment."
}

variable "instance_type" {
  description = "Enter EC2 Instance type, default is t2.micro"
  type        = string
  default     = "t2.micro"


}
variable "common_tags" {
  description = "Enter common tags that wil be applied to all resources created by module."
  type        = map(any)
  default = {
    Owner      = "Vasya Pupkin"
    Project    = "MissionImpossible"
    CostCenter = "2345"
    Env        = "Dev"
  }
}



variable "list" {
  description = "List of"
  type        = list(string)
  default     = ["item1", "item2"]
}

variable "nlb_listeners" {
  description = "One or more NLB listeners with their respective Protocol and Port"
  type = list(object({
    protocol = string
    port     = number
  }))
  default = [
    {
      protocol = "tcp"
      port     = 443

    }
  ]
}

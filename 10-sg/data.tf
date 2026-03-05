data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project}/${var.environment}/vpc_id"  # takes this name from ssm parameter of parameters.tf in 00-vpc
}
resource "aws_ssm_parameter" "sg_id" {
  count = length(var.sg_names)
  name  = "/${var.project}/${var.environment}/${var.sg_names[count.index]}_sg_id"  # ssm parameter name
  type  = "String"
  value = module.sg[count.index].sg_id # from otputs.tf in module terraform-aws-sg we will take this value
}
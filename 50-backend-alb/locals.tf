locals {
  backend_alb_sg_id = data.aws_ssm_parameter.backend_alb_sg_id.value
  private_subnet_ids = [for s in split(",", data.aws_ssm_parameter.private_subnet_ids.value) : trimspace(s)]
  common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
}
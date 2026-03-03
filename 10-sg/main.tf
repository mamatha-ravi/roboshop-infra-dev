module "sg" {
    source = "../../terraform-aws-sg"
    project = var.project
    environment = var.environment
    component = "mongodb"
    vpc_id = local.vpc_id
}
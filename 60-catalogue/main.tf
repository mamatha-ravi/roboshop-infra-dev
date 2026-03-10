resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.private_subnet_id
  vpc_security_group_ids = [local.catalogue_sg_id]

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh" # Local file path
    destination = "/tmp/bootstrap.sh"    # Destination path on the remote machine
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh catalogue dev"
    ]
  }
}
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on = [ terraform_data.catalogue ]
}
resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.project}-${var.environment}-catalogue" 
  source_instance_id = aws_instance.catalogue.id
 depends_on = [ aws_ec2_instance_state.catalogue ]

  tags =  merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc.id
 deregistration_delay = 60

  health_check {
    healthy_threshold = 2  
    interval = 10
    matcher = "200-299"
    path = "/health"
    port = 8080
    protocol = "HTTP"
    timeout = 2
    unhealthy_threshold = 3
  }
}

resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
   image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate"
    instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]

  # each time we apply terraform this version will be updated as default
  update_default_version = true
  
  # tags for instances created by launch template through autoscaling
  tag_specifications {
    resource_type = "instance"

    tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
  }
  # tags for volumes created by instances
  tag_specifications {
    resource_type = "volume"

    tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
  }
  # tags for launch template
  tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
}

# resource "aws_autoscaling_group" "catalogue" {
#    name = "${var.project}-${var.environment}-catalogue"
 
#   desired_capacity   = 1
#   max_size           = 10
#   min_size           = 1
#   health_check_grace_period = 120
#   health_check_type         = "ELB"
#   force_delete              = false
  

#   launch_template {
#     id      = aws_launch_template.catalogue
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "${var.project}-${var.environment}-catalogue"
#     propagate_at_launch = true
#   }

  
# }
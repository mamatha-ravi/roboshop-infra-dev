# resource "aws_instance" "database" {
#   for_each = local.databases
#   ami           = local.ami_id
#   instance_type = "t3.micro"
#   subnet_id = local.database_subnet_id
#   vpc_security_group_ids = [each.value]
  
#   tags = merge(
#     {
#         Name = "${var.project}-${var.environment}-${each.key}"
#     },
#     local.common_tags
#   )
# }

# resource "terraform_data" "bootstrap" {
#   for_each = aws_instance.database
#   triggers_replace = [
#     each.value.id,
#       ]
#  connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     password = local.ssh_password
#     host     = each.value.private_ip
#   }
#    provisioner "file" {
#     source      = "bootstrap.sh"  # Local file path
#     destination = "/tmp/bootstrap.sh"   # Remote file path
#    }
#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/bootstrap.sh",
#       "sudo sh /tmp/bootstrap.sh ${each.key} ${var.environment}"
#     ]
#   }
# }


#without using for_each loop

resource "aws_instance" "mongodb" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.database_subnet_id
  vpc_security_group_ids = [local.mongodb_sg_id]
  
  tags = merge(
    {
        Name = "${var.project}-${var.environment}-mongodb"
    },
    local.common_tags
  )
}

resource "terraform_data" "bootstrap" {
  triggers_replace = [
    aws_instance.mongodb.id,
      ]
 connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ssh_password
    host     = aws_instance.mongodb.private_ip
  }
   provisioner "file" {
    source      = "bootstrap.sh"  # Local file path
    destination = "/tmp/bootstrap.sh"   # Remote file path
   }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb ${var.environment}"
    ]
  }
}

resource "aws_instance" "redis" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.database_subnet_id
  vpc_security_group_ids = [local.redis_sg_id]

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-redis"
    },
    local.common_tags
  )
}

resource "terraform_data" "bootstrap_redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ssh_password
    host     = aws_instance.redis.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh" # Local file path
    destination = "/tmp/bootstrap.sh"    # Destination path on the remote machine
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh redis ${var.environment}"
    ]
  }
}

resource "aws_instance" "mysql" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.database_subnet_id
  vpc_security_group_ids = [local.mysql_sg_id]
  iam_instance_profile = aws_iam_instance_profile.mysql.name
  tags = merge(
    {
        Name = "${var.project}-${var.environment}-mysql"
    },
    local.common_tags
  )
}

resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id,
      ]
 connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ssh_password
    host     = aws_instance.mysql.private_ip
   
  }
   provisioner "file" {
    source      = "bootstrap.sh"  # Local file path
    destination = "/tmp/bootstrap.sh"   # Remote file path
   }
  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh mysql ${var.environment}"
    ]
  }
}

resource "aws_instance" "rabbitmq" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.database_subnet_id
  vpc_security_group_ids = [local.rabbitmq_sg_id]

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-rabbitmq"
    },
    local.common_tags
  )
}

resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = local.ssh_password
    host     = aws_instance.rabbitmq.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh" # Local file path
    destination = "/tmp/bootstrap.sh"    # Destination path on the remote machine
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh rabbitmq dev"
    ]
  }
}
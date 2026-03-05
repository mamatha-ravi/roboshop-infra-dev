variable "project"{
    type = string
    default = "roboshop"
}

variable "environment"{
    type = string
    default = "dev"
}

variable "sg_names"{
    type = list
    default = [
        # Databases
        "mongodb", "redis", "mysql", "rabbitmq",
        # Backend
        "catalogue", "user", "cart", "shipping", "payment",
        # Backend ALB
        "backend_alb",
        # Frontend
        "frontend",
        # Frontend ALB
        "frontend_alb",
        # Bastion
        "bastion"
    ]
}
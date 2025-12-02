locals {
    network_count = var.connection_type == "internal_dns" || var.connection_type == "vpc_link" ? 1 : 0
    
    load_balancers = var.connection_type == "internal_dns" || var.connection_type == "vpc_link" ? [{
        target_group_arn = module.network[0].target_group_arn
        container_name   = var.service_name
        container_port   = var.container_port
    }] : []
}
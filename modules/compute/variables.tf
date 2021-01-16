variable "location"{
    type        = string
    description = "Location"
}

variable "resource_group_name"{
    type        = string
    description = "Resource Group"
}

variable "vnet_subnet_id"{   
    type        = string
    description = "Subnet Id"
}

variable "custom_data"{   
    
        description = "Custom cloud-init Data"
}

variable "backend_address_pool"{   
    type        = string
    description = "Backend_address_pool"
}


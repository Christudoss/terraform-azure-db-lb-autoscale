output "subnet" {
    value = module.network.subnet
    description = "Subnet"
}

output "vnet" {
    value = module.network.vnet
    description = "Vnet"
}

output "backend_address_pool" {
    value = module.lb.backend_address_pool
}
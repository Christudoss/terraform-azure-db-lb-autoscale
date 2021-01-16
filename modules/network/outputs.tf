output "subnet" {
    value = azurerm_subnet.neudesic1.id
    description = "Subnet"
}

output "vnet" {
    value = azurerm_virtual_network.neudesic.id
    description = "Vnet"
}
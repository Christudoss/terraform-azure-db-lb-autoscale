terraform {
  required_version = ">= 0.12" 
}

resource "azurerm_network_security_group" "neudesic" {
  name                = "ndsicTestSecurityGroup1"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_ddos_protection_plan" "neudesic" {
  name                = "ndsicddospplan1"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "neudesic" {
 name                = "ndsic-vnet1"
 resource_group_name = var.resource_group_name
 location            = var.location
 address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "neudesic1" {
 name                 = "ndsic-subnet1"
 resource_group_name  = var.resource_group_name
 virtual_network_name = azurerm_virtual_network.neudesic.name
 address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "neudesic2" {
 name                 = "ndsic-subnet2"
 resource_group_name  = var.resource_group_name
 virtual_network_name = azurerm_virtual_network.neudesic.name
 address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "neudesic" {
 name                         = "ndsic-public-ip"
 location                     = var.location
 resource_group_name          = var.resource_group_name
 allocation_method            = "Static"
}


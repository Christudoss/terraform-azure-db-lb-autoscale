terraform {
  required_version = ">= 0.12" 
}

resource "azurerm_public_ip" "neudesic" {
 name                         = "ndsic-public-ip"
 location                     = var.location
 resource_group_name          = var.resource_group_name
 allocation_method            = "Static"
}

resource "azurerm_lb" "neudesic" {
 name                = "ndsic-lb"
 location            = var.location
 resource_group_name = var.resource_group_name

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.neudesic.id
 }

}

resource "azurerm_lb_backend_address_pool" "neudesic" {
 resource_group_name = var.resource_group_name
 loadbalancer_id     = azurerm_lb.neudesic.id
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "neudesic" {
 resource_group_name = var.resource_group_name
 loadbalancer_id     = azurerm_lb.neudesic.id
 name                = "ssh-running-probe"
 port                = var.application_port
}

resource "azurerm_lb_rule" "neudesic" {
   resource_group_name            = var.resource_group_name
   loadbalancer_id                = azurerm_lb.neudesic.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = var.application_port
   backend_port                   = var.application_port
   backend_address_pool_id        = azurerm_lb_backend_address_pool.neudesic.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.neudesic.id
}
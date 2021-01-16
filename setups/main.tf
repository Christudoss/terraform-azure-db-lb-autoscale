terraform {
  required_version = ">= 0.12" 
  backend "azurerm" {
    resource_group_name   = "tfstate"
    storage_account_name  = var.storage_name
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}

data "template_file" "cloud_config" {
  template = file("${path.cwd}/test.yaml")
} 

resource "azurerm_resource_group" "neudesic" {
  name     = "neudesic-resources"
  location = var.location
}


module "database" {
  source              = "../modules/database"
  resource_group_name = azurerm_resource_group.neudesic.name
  location            = var.location

}

module "compute" {
  source              = "../modules/compute"
  resource_group_name = azurerm_resource_group.neudesic.name
  location            = var.location
  vnet_subnet_id      = module.network.subnet
  custom_data         = data.template_file.cloud_config.rendered
  backend_address_pool = module.lb.backend_address_pool


}

module "lb" {
  source              = "../modules/lb"
  resource_group_name = azurerm_resource_group.neudesic.name
  location            = var.location
  application_port    = "80"


}

module "network" {
  source              = "../modules/network"
  resource_group_name = azurerm_resource_group.neudesic.name
  location            = var.location

}



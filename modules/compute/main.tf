terraform {
  required_version = ">= 0.12" 
}

# data "template_file" "cloud_config" {
#   template = file("${path.cwd}/test.yaml")
# } 

resource "azurerm_linux_virtual_machine_scale_set" "neudesic" {
  name                = "neudesic-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_B1S"
  instances           = 1
  admin_username      = "adminuser"
  #custom_data         = base64encode(data.template_file.cloud_config.rendered) # cloud-init
  custom_data         = base64encode("${var.custom_data}")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.vnet_subnet_id
      load_balancer_backend_address_pool_ids = ["${var.backend_address_pool}"]
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "neudesic" {
  name                = "myAutoscaleSetting"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.neudesic.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.neudesic.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.neudesic.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["admin@neudesic.com"]
    }
  }
}

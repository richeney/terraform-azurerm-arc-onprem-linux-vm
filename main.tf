terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.51.0"
    }
  }
}

locals {
  # prefix the resource names is the variable has been specified
  name = try(length(var.resource_prefix), 0) > 0 ? "${var.resource_prefix}-${var.name}" : var.name

  # Accept either admin_ssh_public_key or use a file
  admin_ssh_public_key = length(var.admin_ssh_public_key) > 0 ? var.admin_ssh_public_key : file(var.admin_ssh_public_key_file)

  # Set a boolean for the connect if the arc object has been set
  azcmagent_connect = var.arc == null ? false : true

  // And then force azcmagent_download to true
  azcmagent_download = local.azcmagent_connect ? true : var.azcmagent

  // If connecting then convert map of tags to string of comma delimited key=value pairs and merge back into the arc object

  arc_tags_string = local.azcmagent_connect && try(length(var.arc.tags), 0) > 0 ? (
    join(",", [for key, value in var.arc.tags :
      # "${key}=${replace(value, " ", "_")}"])
      # "${key}=\\\"${value}\\\""])
    "${key}=${value}"])
    ) : (
    null
  )

  arc = local.azcmagent_connect ? merge(var.arc, { tags = local.arc_tags_string }) : null

  // Construct the input steps for the cloud init based on the booleans.

  cloud_init_agent_imds = [{
    "name"    = "remove_azure_agent_block_imds"
    "content" = templatefile("${path.module}/cloud_init/azure_agent_imds.tpl", { hostname = var.name })
  }]

  cloud_init_download = local.azcmagent_download ? [{
    "name"    = "azcmagent_download"
    "content" = file("${path.module}/cloud_init/azcmagent_install.yaml")
  }] : []

  cloud_init_connect = local.azcmagent_connect ? [{
    "name"    = "azcmagent_connect"
    "content" = templatefile("${path.module}/cloud_init/azcmagent_connect.tpl", local.arc)
  }] : []

  //  cloud_init_azure_cli = [{
  //      "name"    = "install_azure_cli"
  //      "content" = file("${path.module}/cloud_init/azure_cli.yaml")
  //    }]
  //

  cloud_init = concat(local.cloud_init_agent_imds, local.cloud_init_download, local.cloud_init_connect)

  cloud_init_steps = {
    for n in range(length(local.cloud_init)) :
    format("step%02d", n + 1) => local.cloud_init[n]
  }
}



data "template_cloudinit_config" "multipart" {
  gzip          = false
  base64_encode = false

  dynamic "part" {
    for_each = local.cloud_init_steps

    content {
      filename     = part.value.name
      content_type = "text/cloud-config"
      content      = part.value.content
    }
  }
}

resource "azurerm_public_ip" "onprem" {
  for_each            = toset(var.public_ip ? ["pip"] : [])
  name                = "${local.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  domain_name_label = var.dns_label
}

resource "azurerm_network_interface" "onprem" {
  name                = "${local.name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.onprem["pip"].id : null
  }
}

resource "azurerm_network_interface_application_security_group_association" "onprem" {
  network_interface_id          = azurerm_network_interface.onprem.id
  application_security_group_id = var.asg_id
}

resource "azurerm_linux_virtual_machine" "onprem" {
  name                = local.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  computer_name                   = var.name
  admin_username                  = var.admin_username
  disable_password_authentication = true
  size                            = var.size

  network_interface_ids = [azurerm_network_interface.onprem.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${local.name}-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  // custom_data = filebase64("${path.module}/example_cloud_init")
  // custom_data = base64encode(templatefile("${path.module}/azure_arc_cloud_init.tpl", { hostname = var.name }))
  custom_data = base64encode(data.template_cloudinit_config.multipart.rendered)

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.admin_ssh_public_key
  }
}

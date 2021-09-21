variable "name" {
  description = "Hostname for the VM."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID for a subnet."
  type        = string
}

variable "asg_id" {
  description = "Optional resource ID for an application security group"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name for the resource group. Required."
  type        = string
  default     = "onprem_servers"
}

//=============================================================

variable "size" {
  description = "Azure virtual machine size."
  default     = "Standard_A1_v2"
}

variable "location" {
  description = "Azure region for the on prem VM."
  default     = "UK South"
}

variable "tags" {
  description = "Map of tags for the resources created by this module. Use arc.tags for the Arc Connected Server tags if onboarding."
  type        = map(string)
  default     = {}
}

//=============================================================

variable "azcmagent" {
  description = "Set to true to download the azcmagent. Is automatically set to true if the arc object is set."
  type        = bool
  default     = false
}

variable "arc" {
  description = "Object desribing the service principal and resource group for the Azure Arc connected machines. Requires azcmagent = true."
  type = object({
    tenant_id                = string
    subscription_id          = string
    service_principal_appid  = string
    service_principal_secret = string
    resource_group_name      = string
    location                 = string
    tags                     = map(string)
  })

  default = null
}


//=============================================================

variable "admin_username" {
  description = "VM admin username."
  default     = "onpremadmin"
}

variable "admin_ssh_public_key_file" {
  description = "Public key file to use."
  default     = "~/.ssh/id_rsa.pub"
}

variable "admin_ssh_public_key" {
  description = "SSH public key. Has priority over the admin_ssh_public_key_file variable"
  type        = string
  default     = ""
}

variable "public_ip" {
  description = "Boolean to control public IP creation."
  type        = bool
  default     = false
}

variable "dns_label" {
  description = "Shortname for the public IP's FQDN. Public IP will not be created if unset,"
  type        = string
  default     = null
}

variable "resource_prefix" {
  description = "Optional prefix for the VM resources."
  type        = string
  default     = ""
}

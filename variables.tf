variable "resource_group_location" {
  type        = string
  default     = "eastasia"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "machine_prefix" {
  type        = string
  description = "The prefix which should be used for all resources in this example"
  default     = "ubuntu-vm"
}

variable "machine_name" {
  default = ["master", "worker"]
}


variable "vm_count" {
  type        = number
  description = "The number of virtual machines to create"
  default     = 2
}

variable "admin_password" {
  type        = string
  description = "The password for the virtual machine"
  default     = "/Rc3P}Hmu)sF"
}

variable "dns_label_prefix" {
  type        = string
  description = "The DNS label prefix for the public IP addresses"
  default     = "mrtux"
}
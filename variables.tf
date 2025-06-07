# variables.tf
variable "resource_group_name" {
  description = "Name of the resource group"
  type    	= string
  default 	= "vm-rg"
}

variable "location" {
  description = "Azure region for resources"
  type    	= string
  default 	= "East US"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type    	= string
  default 	= "vm-vnet"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type    	= string
  default 	= "vm-subnet"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type    	= string
  default 	= "demo-vm"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type    	= string
  default 	= "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type    	= string
  default 	= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC54RUFP3yT04Y0ZMBYqitof4i0TVGcGNkTqGN8ZjtnIT+BpSvlmaQ+mCXpffdGPEUweEyBVBKjwXXOOT+YHq/y2c+kH6pMcreS7LBazz5wRxZVOOF4EwsREbWRGIN4/iso2zRWyqx1IcIE964OTKtu92PMy5i4eq0b957SfgA8PSbQZGfswY7/r3WP2Eq/RMuMHLzhWmla231aDvOidInptR9t9FxBkYAbVU6k2FFLx6PYNbgNhG6FTJPMoYfjVbwAUgHEoufvqY1/npYoK5mV8XIqBRjDbT0sHTAwvhiz4ol9cClsWnN8SUOToaZErbyXyMG0gE/RnlWM7JjuZPmb shuvamdevkota-ubuntu@4095e-ubuntu"
  # Replace with your actual SSH public key
}

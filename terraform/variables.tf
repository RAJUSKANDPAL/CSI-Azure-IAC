variable "environment" {
  description = "Deployment environment (dev, uact, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "vm_count" {
  description = "Number of VMs"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the Virtual Machines"
  type        = string
  default     = "Standard_B1s"
}

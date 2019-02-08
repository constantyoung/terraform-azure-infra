# Optional Variables
variable "location" {
  type = "string"
  description = "(Optional) Azure Datacenter location"
  default = "eastus"
}

variable "tags" {
  type = "map"
  description = "(Optional) Map that contains Azure Tags"
  default = {}
}


# Required Variables
variable "rg" {
  type        = "string"
  description = "(Required) Name of the resource group"
}

# Local Variables

locals {
  
}




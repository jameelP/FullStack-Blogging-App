variable "location" {
  description = "The azure location to deploy to"
  default     = "East US"
  type        = string
}

variable "resource_group" {
  description = "The name of the resource group"
  default     = "devops-resource-group"
  type        = string
}


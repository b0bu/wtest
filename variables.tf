variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "docker_registry_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "docker_registry_username" {
  type    = string
  default = null
}

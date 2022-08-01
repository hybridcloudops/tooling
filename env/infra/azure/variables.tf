variable "resource_group_name" {
  description = "Name of the resource group to deploy to"
}

variable "region" {
  description = "The region to deploy to"
}

variable "k8_name" {
  description = "The name of the cluster"
}

variable "k8_dns_prefix" {
  description = "The dns prefix to use for the cluster"
}

variable "arm_subscription_id" {
  description = "Azure subscirption id"
}

variable "arm_tenant_id" {
  description = "Azure tenant id"
}

variable "arm_client_id" {
  description = "Azure client id"
}

variable "arm_client_secret" {
  description = "Azure client secret"
}



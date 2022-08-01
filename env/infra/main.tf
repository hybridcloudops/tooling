module "azure_eus" {
  source              = "./azure"
  resource_group_name = "bsc-public-cloud"
  region              = "East US 2"
  k8_name             = "bsc-aks"
  k8_dns_prefix       = "bscaks"
  arm_client_id       = var.arm_client_id
  arm_client_secret   = var.arm_client_secret
  arm_subscription_id = var.arm_subscription_id
  arm_tenant_id       = var.arm_tenant_id
}

variable "arm_subscription_id" {
  description = "Azure subscirption id set through TF_VAR_arm_client_id"
}

variable "arm_tenant_id" {
  description = "Azure tenant id set through TF_VAR_arm_tenant_id"
}

variable "arm_client_id" {
  description = "Azure client id set through TF_VAR_arm_client_id"
}

variable "arm_client_secret" {
  description = "Azure client secret set through TF_VAR_arm_client_secret"
}

output "azure_eus_cert" {
  value = module.azure_eus.client_certificate
}

output "azure_eus_cnf" {
  value = module.azure_eus.kube_config
}


variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-gitlab-project"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_name" {
  description = "Name of the GitLab VM"
  type        = string
  default     = "vm-gitlab"
}

variable "admin_username" {
  description = "Administrator username for the Linux VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_allowed_ip" {
  description = "Source CIDR allowed to reach SSH (22). Use * for anywhere."
  type        = string
  default     = "*"
}

variable "web_allowed_ip" {
  description = "Source CIDR allowed to reach GitLab (80), GitLab SSH (2222) and the app (8501). Use * for anywhere."
  type        = string
  default     = "*"
}
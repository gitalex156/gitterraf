variable "yc_service_account_key_file" {
  description = "Path to the Yandex Cloud service account key file"
  type        = string
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to the SSH private key"
  type        = string
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
}

variable "instance_cores" {
  description = "Количество vCPU для экземпляра"
  type        = number
}

variable "instance_memory" {
  description = "Объем памяти (RAM) для экземпляра"
  type        = number
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU"
  type        = number
}

variable "disk_size" {
  description = "Размер диска в ГБ"
  type        = number
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
}

variable "docker_password" {
  description = "Docker Hub password"
  type        = string
  sensitive   = true
}

variable "docker_image_name" {
  description = "Name of the Docker image to run on the instance"
  type        = string
}

variable "ci_registry_image" {
  description = "GitLab CI registry image name"
  type        = string
  default     = "registry.gitlab.com/lesson9324950/terraformgitlab"
}

variable "docker_registry_url" {
  description = "URL of the Docker registry"
  type        = string
}

variable "config_file_path" {
  description = "Path to the config file"
  type        = string
  default     = "config.yml"
}

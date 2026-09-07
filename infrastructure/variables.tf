variable "proxmox_endpoint" {
  type = string
  default = "https://192.168.122.150:8006/"
}

variable "proxmox_api_token" {
  type = string
  sensitive = true
  default = "root@pam!tokenid=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

variable "proxmox_ssh_username" {
  type = string
  sensitive = true
  default = "root"
}

variable "proxmox_ssh_password" {
  type = string
  sensitive = true
  default = "a-strong-password"
}

variable "public_ssh_key" {
  type    = string
  default = "~/.ssh/keys/homelab.key.pub"
}

variable "network_gateway" {
  type = string
  default = "192.168.122.1"
}

variable "network_docker_ip" {
  type = string
  default = "192.168.122.200/24"
}

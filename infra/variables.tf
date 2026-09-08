variable "proxmox_ip" {
  type = string
  default = "192.168.0.2"
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

variable "network_cidr" {
  type = string
  default = "10.0.0.0/24"
}

variable "network_gateway" {
  type = string
  default = "10.0.0.1"
}

variable "network_ts_ip" {
  type = string
  default = "10.0.0.2/24"
}

variable "network_docker_ip" {
  type = string
  default = "10.0.0.3/24"
}

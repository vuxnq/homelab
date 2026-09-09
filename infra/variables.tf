variable "pve_ip" {
  type    = string
  default = "192.168.0.2"
}

variable "pve_user" {
  type      = string
  default   = "root"
}

variable "pve_password" {
  type      = string
  sensitive = true
  default   = "a-strong-password"
}

variable "homelab_ssh_key_path" {
  type    = string
  default = "~/.ssh/keys/homelab.key.pub"
}

variable "net_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "net_gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "net_ts_ip" {
  type    = string
  default = "10.0.0.2/24"
}

variable "net_apps_ip" {
  type    = string
  default = "10.0.0.3/24"
}

variable "pve_ip" {
  type    = string
  default = "192.168.0.2"
}

variable "pve_user" {
  type    = string
  default = "root"
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

variable "disk_name" {
  type    = string
  default = "local-lvm"
}

variable "disk_data_name" {
  type    = string
  default = "hdd-storage"
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

variable "net_pihole_ip" {
  type    = string
  default = "10.0.0.3/24"
}

variable "net_apps_ip" {
  type    = string
  default = "10.0.0.4/24"
}

variable "mem_apps_max" {
  type    = number
  default = 12288
}

variable "mem_apps_min" {
  type    = number
  default = 4096
}

variable "cpu_apps_cores" {
  type    = number
  default = 4
}

variable "disk_apps_size" {
  type    = number
  default = 64
}

variable "disk_data_apps_size" {
  type    = number
  default = 512
}

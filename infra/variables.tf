variable "debian_lxc_url" {
  type    = string
  default = "http://download.proxmox.com/images/system/debian-13-standard_13.6-1_amd64.tar.zst"
}

variable "debian_cloud_url" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

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

variable "disk_backup_name" {
  type    = string
  default = "hdd-storage"
  # default = "hdd-backup" # TODO: dedicated backup disk
}

variable "net_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "net_gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "ts_router_ip" {
  type    = string
  default = "10.0.0.2/24"
}

variable "pihole_ip" {
  type    = string
  default = "10.0.0.3/24"
}

variable "apps_host_ip" {
  type    = string
  default = "10.0.0.4/24"
}

variable "apps_host_mem_min" {
  type    = number
  default = 4096
}

variable "apps_host_mem_max" {
  type    = number
  default = 12288
}

variable "apps_host_cpu_cores" {
  type    = number
  default = 4
}

variable "apps_host_disk_size" {
  type    = number
  default = 64
}

variable "apps_host_disk_data_size" {
  type    = number
  default = 512
}

variable "apps_host_disk_backup_size" {
  type    = number
  default = 256
}

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.112.0"
    }
  }
  backend "local" {
    path = ".state/terraform.tfstate"
  }
}

provider "proxmox" {
  endpoint = local.pve_endpoint
  username = "root@pam" # must be here bc of ts_router device_passthrough
  password = var.pve_password
  insecure = true

  ssh {
    agent    = false
    username = var.pve_user
    password = var.pve_password
  }
}

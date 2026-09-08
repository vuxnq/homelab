terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.112.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = "root@pam" # must be here bc of tailscale_router device_passthrough
  password = var.proxmox_ssh_password
  # api_token = var.proxmox_api_token # no more needed thanks to credentials
  insecure = true # TODO

  ssh {
    agent = false
    username = var.proxmox_ssh_username
    password = var.proxmox_ssh_password
  }
}

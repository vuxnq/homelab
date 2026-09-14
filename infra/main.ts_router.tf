resource "proxmox_virtual_environment_container" "ts_router" {
  node_name    = local.root_node
  description  = "tailscale subnet router / exit node"
  unprivileged = true

  features { nesting = true }

  initialization {
    hostname = "ts-router"

    ip_config {
      ipv4 {
        address = var.ts_router_ip
        gateway = var.net_gateway
      }
    }
    user_account { keys = [local.homelab_ssh_key] }
  }

  memory { dedicated = 512 }

  device_passthrough { path = "/dev/net/tun" }

  network_interface {
    name   = "eth0"
    bridge = proxmox_sdn_vnet.vnet_internal.id
  }

  disk {
    datastore_id = var.disk_name
    size         = 2
  }

  operating_system {
    template_file_id = proxmox_download_file.debian_lxc_template.id
    type             = "debian"
  }

  depends_on = [
    proxmox_sdn_applier.subnet_applier,
    terraform_data.pve_authorized_key
  ]
}

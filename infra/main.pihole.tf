# resource "proxmox_download_file" "debian_lxc_template" {
#   content_type = "vztmpl"
#   datastore_id = "local"
#   node_name    = local.root_node
#   url          = "http://download.proxmox.com/images/system/debian-13-standard_13.6-1_amd64.tar.zst"
#   file_name    = "debian-13-standard_13.6-1_amd64.tar.zst"
# }

resource "proxmox_virtual_environment_container" "pihole" {
  node_name    = local.root_node
  description  = "pihole dns"
  unprivileged = true

  features { nesting = true }

  initialization {
    hostname = "pihole"

    ip_config {
      ipv4 {
        address = var.net_pihole_ip
        gateway = var.net_gateway
      }
    }
    user_account { keys = [local.homelab_ssh_key] }
  }

  memory { dedicated = 512 }

  network_interface {
    name   = "eth0"
    bridge = proxmox_sdn_vnet.vnet_internal.id
  }

  disk {
    datastore_id = var.disk_name
    size         = 4
  }

  operating_system {
    template_file_id = proxmox_download_file.debian_lxc_template.id
    type             = "debian"
  }

  depends_on = [proxmox_sdn_applier.subnet_applier]
}

resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = local.root_node
  url          = "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name    = "debian-13-cloud.img"
}

resource "proxmox_virtual_environment_vm" "apps_host" {
  name        = "apps-host"
  description = "this used to be sheol" # TODO
  node_name   = local.root_node

  cpu { cores = 2 }
  memory { dedicated = 2048 }

  network_device {
    bridge = proxmox_sdn_vnet.vnet_internal.id
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_download_file.debian_cloud_image.id
    interface    = "virtio0"
    size         = 8 # default 8
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.net_apps_ip
        gateway = var.net_gateway
      }
    }
    user_account {
      username = "test"
      keys     = [local.homelab_ssh_key]
    }
  }

  depends_on = [proxmox_sdn_applier.subnet_applier]
}

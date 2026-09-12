resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = local.root_node
  url          = "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name    = "debian-13-cloud.img"
}

resource "proxmox_virtual_environment_vm" "apps_host" {
  name        = "apps-host"
  description = "this used to be sheol"
  node_name   = local.root_node

  agent {
    enabled = true

    wait_for_ip {
      disabled = true # without it, it halted on creating
    }
  }

  cpu {
    cores = var.cpu_apps_cores 
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.mem_apps_max
    floating  = var.mem_apps_min
  }

  network_device {
    bridge = proxmox_sdn_vnet.vnet_internal.id
  }

  disk {
    datastore_id = var.disk_name
    file_id      = proxmox_download_file.debian_cloud_image.id
    interface    = "virtio0"
    size         = var.disk_apps_size
  }

  disk {
    datastore_id = var.disk_data_name
    interface    = "virtio1"
    file_format  = "raw"
    size         = var.disk_data_apps_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.net_apps_ip
        gateway = var.net_gateway
      }
    }
    user_account { keys = [local.homelab_ssh_key] }
  }

  depends_on = [proxmox_sdn_applier.subnet_applier]
}

resource "proxmox_download_file" "debian_lxc_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name = local.root_node
  url = "http://download.proxmox.com/images/system/debian-13-standard_13.6-1_amd64.tar.zst"
  file_name = "debian-13-standard_13.6-1_amd64.tar.zst"
}

resource "proxmox_virtual_environment_container" "tailscale_router" {
  node_name   = local.root_node
  description = "tailscale subnet router / exit node"
  unprivileged = true

  features { nesting = true }
  initialization {
    hostname = "ts-router"

    ip_config {
      ipv4 {
        address = var.network_ts_ip
        gateway = var.network_gateway
      }
    }
    user_account { keys = [local.my_public_key] }
  }

  device_passthrough { path = "/dev/net/tun" }
  network_interface { name = "eth0" }

  disk {
    datastore_id = "local-lvm"
    size = 4 # default 4
  }

  operating_system {
    template_file_id = proxmox_download_file.debian_lxc_template.id
    type = "debian"
  }
}

resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name = local.root_node
  url = "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name = "debian-13-cloud.img"
}

resource "proxmox_virtual_environment_vm" "docker_vm" {
  name = "docker-host"
  description = "this used to be sheol" # TODO
  node_name = local.root_node

  cpu { cores = 2 }
  memory { dedicated = 2048 }

  network_device { bridge = "vmbr0" }

  disk {
    datastore_id = "local-lvm"
    file_id = proxmox_download_file.debian_cloud_image.id
    interface = "virtio0"
    size = 8 # default 8
  }
  
  initialization {
    ip_config {
      ipv4 {
        address = var.network_docker_ip
        gateway = var.network_gateway
      }
    }
    user_account {
      username = "test"
      keys = [local.my_public_key]
    }
  }
}

resource "proxmox_virtual_environment_vm" "apps_host" {
  name        = "apps-host"
  description = "host for docker containers"
  node_name   = local.root_node

  agent {
    enabled = true

    wait_for_ip {
      disabled = true # without it, it halts on creating
    }
  }

  cpu {
    cores = var.apps_host_cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.apps_host_mem_max
    floating  = var.apps_host_mem_min
  }

  network_device {
    bridge = proxmox_sdn_vnet.vnet_internal.id
  }

  disk {
    datastore_id = var.disk_name
    file_id      = proxmox_download_file.debian_cloud_image.id
    interface    = "virtio0"
    size         = var.apps_host_disk_size
  }

  disk {
    datastore_id = var.disk_data_name
    interface    = "virtio1"
    file_format  = "raw"
    size         = var.apps_host_disk_data_size
  }

  disk {
    datastore_id = var.disk_backup_name
    interface    = "virtio2"
    file_format  = "raw"
    size         = var.apps_host_disk_backup_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.apps_host_ip
        gateway = var.net_gateway
      }
    }
    user_account { keys = [local.homelab_ssh_key] }
  }

  depends_on = [proxmox_sdn_applier.subnet_applier]
}

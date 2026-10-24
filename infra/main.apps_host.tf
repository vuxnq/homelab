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
    floating  = var.apps_host_gpu_passthrough ? 0 : var.apps_host_mem_min
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
    datastore_id      = proxmox_virtual_environment_vm.disk_holder.disk[0].datastore_id
    path_in_datastore = proxmox_virtual_environment_vm.disk_holder.disk[0].path_in_datastore
    interface         = "virtio2"
    file_format       = proxmox_virtual_environment_vm.disk_holder.disk[0].file_format
    size              = proxmox_virtual_environment_vm.disk_holder.disk[0].size
  }

  dynamic "usb" {
    for_each = var.audio_usb_id != "" ? [1] : []
    content {
      host = var.audio_usb_id
    }
  }

  dynamic "hostpci" {
    for_each = var.apps_host_gpu_passthrough ? [1] : []
    content {
      device = "hostpci0"
      id     = var.gpu_pci_id
    }
  }

  dynamic "vga" {
    for_each = var.apps_host_gpu_passthrough ? [1] : []
    content {
      type = "none"
    }
  }

  dynamic "serial_device" {
    for_each = var.apps_host_gpu_passthrough ? [1] : []
    content {
      device = "socket"
    }
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

  lifecycle {
    ignore_changes  = [disk[0].file_id]
    prevent_destroy = true
  }

  depends_on = [proxmox_sdn_applier.subnet_applier]
}

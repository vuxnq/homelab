# ensure ssh key is authorized
resource "terraform_data" "proxmox_authorized_key" {
  triggers_replace = local.my_public_key
  
  connection {
    type = "ssh"
    user = var.proxmox_ssh_username
    password = var.proxmox_ssh_password
    host = var.proxmox_ip
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "chmod 700 ~/.ssh",
      "grep -q -F '${local.my_public_key}' ~/.ssh/authorized_keys 2>/dev/null || echo '${local.my_public_key}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys"
    ]
  }
}

# internal subnet
resource "proxmox_sdn_zone_simple" "internal" {
  id = "internal"
  ipam = "pve"

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_vnet" "vnet_internal" {
  id = "vnet0"
  zone = proxmox_sdn_zone_simple.internal.id

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_subnet" "subnet_internal" {
  cidr = var.network_cidr
  vnet = proxmox_sdn_vnet.vnet_internal.id
  gateway = var.network_gateway
  snat = true

  depends_on = [proxmox_sdn_applier.finalizer]
}

resource "proxmox_sdn_applier" "subnet_applier" {
  depends_on = [
    proxmox_sdn_zone_simple.internal,
    proxmox_sdn_vnet.vnet_internal,
    proxmox_sdn_subnet.subnet_internal
  ]
}

resource "proxmox_sdn_applier" "finalizer" { }

# tailscale router
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

  network_interface { 
    name = "eth0"
    bridge = proxmox_sdn_vnet.vnet_internal.id
  }

  disk {
    datastore_id = "local-lvm"
    size = 4 # default 4
  }

  operating_system {
    template_file_id = proxmox_download_file.debian_lxc_template.id
    type = "debian"
  }

  depends_on = [
    proxmox_sdn_applier.subnet_applier,
    terraform_data.proxmox_authorized_key
  ]
}

# debian virtual machine
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

  network_device {
    bridge = proxmox_sdn_vnet.vnet_internal.id
  }

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

  depends_on = [proxmox_sdn_applier.subnet_applier]
}

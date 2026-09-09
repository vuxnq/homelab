resource "proxmox_sdn_zone_simple" "internal" {
  id   = "internal"
  ipam = "pve"
}

resource "proxmox_sdn_vnet" "vnet_internal" {
  id   = "vnet0"
  zone = proxmox_sdn_zone_simple.internal.id
}

resource "proxmox_sdn_subnet" "subnet_internal" {
  cidr    = var.net_cidr
  vnet    = proxmox_sdn_vnet.vnet_internal.id
  gateway = var.net_gateway
  snat    = true
}

resource "proxmox_sdn_applier" "subnet_applier" {
  depends_on = [
    proxmox_sdn_zone_simple.internal,
    proxmox_sdn_vnet.vnet_internal,
    proxmox_sdn_subnet.subnet_internal
  ]
}

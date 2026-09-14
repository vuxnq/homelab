locals {
  homelab_ssh_key = trimspace(file(pathexpand(var.homelab_ssh_key_path)))
  root_node       = data.proxmox_virtual_environment_nodes.available_nodes.names[0]
  pve_endpoint    = "https://${var.pve_ip}:8006/"

  debian_lxc_filename   = basename(var.debian_lxc_url)
  debian_cloud_filename = basename(var.debian_cloud_url)
}

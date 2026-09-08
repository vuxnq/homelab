locals {
  my_public_key = trimspace(file(pathexpand(var.public_ssh_key)))
  root_node = data.proxmox_virtual_environment_nodes.available_nodes.names[0]
}

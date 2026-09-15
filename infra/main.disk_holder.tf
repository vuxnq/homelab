resource "proxmox_virtual_environment_vm" "disk_holder" {
  name      = "disk-holder"
  node_name = local.root_node
  started   = false
  on_boot   = false

  # backup disk - used by apps_host
  disk {
    datastore_id = var.disk_backup_name
    interface    = "virtio0"
    file_format  = "raw"
    size         = var.apps_host_disk_backup_size
  }

  lifecycle { prevent_destroy = true }
}

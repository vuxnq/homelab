resource "proxmox_download_file" "debian_lxc_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = local.root_node
  url          = var.debian_lxc_url
  file_name    = local.debian_lxc_filename
  overwrite    = false
}

resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = local.root_node
  url          = var.debian_cloud_url
  file_name    = local.debian_cloud_filename
  overwrite    = false
}

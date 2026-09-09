resource "terraform_data" "pve_authorized_key" {
  triggers_replace = local.homelab_ssh_key

  connection {
    type     = "ssh"
    user     = var.pve_user
    password = var.pve_password
    host     = var.pve_ip
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "chmod 700 ~/.ssh",
      "grep -q -F '${local.homelab_ssh_key}' ~/.ssh/authorized_keys 2>/dev/null || echo '${local.homelab_ssh_key}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys"
    ]
  }
}

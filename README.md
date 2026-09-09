# homelab
[proxmox server](https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso)

## requirements
### tools
```sh
# install opentofu, ansible
sudo dnf install opentofu ansible
```

## prerequisites
### generate ssh key
```sh
mkdir -p ~/.ssh/keys
ssh-keygen -t ed25519 -C "homelab" -f ~/.ssh/keys/homelab.key
```

```sh
git clone https://github.com/vuxnq/homelab.git
cd homelab
```

### configure secrets
```sh
# opentofu - create new file infra/secret.auto.tfvars and set variables
nvim infra/secrets.auto.tfvars
```

```tfvars
# homelab/infra/secrets.auto.tfvars

# example - configuring password
# variables are in inra/variables.tf
pve_password = "fuckass-password"
```

```sh
# ansible - create new file config/group_vars/all/99-secret.yml
nvim config/group_vars/all/99-secrets.yml
```


```yaml
# homelab/config/group_vars/all/99-secrets.yml

#configuring tailscale_authkey
# variables are in config/group_vars/all/00-vars.yml
tailscale_authkey: "tskey-auth-xxxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## usage
```sh
# 1. deploy infrastructure
cd infra/
tofu init
tofu plan
tofu apply
cd ..

# 2. configure servers
cd config/
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml --check --diff
ansible-playbook site.yml
cd ..
```

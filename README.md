# homelab
[proxmox server](https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso)

## requirements
- porkbun domain, tailscale, 2+ disks, backblaze b2 bucket

### tools
```sh
# install opentofu, ansible
sudo dnf install opentofu ansible rsync
```

## prerequisites
### configure proxmox
- select pve node
- go to disks. find hdd and wipe
- disks -> lvm-thin
- create: thinpool
    - disk: select hdd
    - name: `hdd-storage`

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
ansible-playbook site.yml # if restoring backup add `--skip-tags app_start`
cd ..
```

### post deployment
- go to tailscale and approve subnet routes and exit node request
- go to porkbun and set dns:
    - A record: sheol.vuxnq.me -> 10.0.0.4 (apps_host)
    - CNAME record: *.sheol.vuxnq.me -> sheol.vuxnq.me

### backup restoration
```sh
# TODO
# place restic repo inside /backup/restic-repo
# (or whatever your backup_repo inside 00-vars.yml is bruh)
# after that apply config and skip deploying containers
ansible-playbook site.yml --skip-tags apps_start

ssh debian@10.0.0.4
sudo rm -rf /backup/restic-repo # remove init
chown 1000:1000 /backup

# rsync repo to backup
rsync -avz /path/to/restic-repo debian@10.0.0.4:/backup/

# back on server
chown 0:0 -R /backup

sudo resticprofile -c /etc/resticprofile/profiles.yaml -n local restore latest --target /
# restore immich_postgres dump
sudo docker compose -f /opt/apps/immich/compose.yaml up -d database
cat /mnt/data/immich/postgres-dump.sql | sudo docker exec -i immich_postgres psql -U ${DB_USERNAME} # in 99-secrets.yml

ansible-playbook site.yml --tags apps_start
```

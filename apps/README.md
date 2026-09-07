# sheol
[fedora server](https://fedoraproject.org/server/)

## requirements

### tailscale
```sh
# install and start tailscale
sudo dnf install tailscale
sudo systemctl enable --now tailscaled

# advertise as exit-node
sudo tailscale set --advertise-exit-node

# connect to the network
sudo tailscale up
```

### git(hub)
```sh
# install
sudo dnf install git gh

# set up git credentials
git config --global user.name <name>
git config --global user.email <email>

# login to github
gh auth login
```

### docker
```sh
# set up the docker repo
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# install docker
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# cap docker container log sizes
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "20m",
    "max-file": "3"
  }
}
EOF

# start docker
sudo systemctl enable --now docker

# add yourself to the docker group
sudo usermod -aG docker $USER
# relog to take effect
```

### cups
```sh
# cups, gutenprint
sudo dnf install cups gutenprint gutenprint-cups
sudo systemctl enable --now cups
sudo cupsctl --share-printers --remote-any --remote-admin
sudo systemctl restart cups

# firewall
sudo firewall-cmd --add-service=ipp --add-service=mdns --permanent
sudo firewall-cmd --reload

# edit config
sudo nvim /etc/cups/cupsd.conf
# add these 2 lines
# ServerAlias *
# DefaultEncryption Never
```

### misc
```sh
# install
sudo dnf install restic nvim stow

# setting up nvim
git clone https://github.com/vuxnq/nvim.git ~/.config/nvim
```

### post install
```sh
# create and activate swapfile
sudo dd if=/dev/zero of=/swapfile bs=1M count=6144 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab

# expand root volume to use all free space
sudo lvextend --extents +100%FREE /dev/mapper/fedora_sheol-root
sudo xfs_growfs /dev/mapper/fedora_sheol-root

# kernel panic auto reboot
echo "kernel.panic = 10" | sudo tee /etc/sysctl.d/99-panic-reboot.conf
sudo sysctl --system

# automatic security patches
sudo dnf install -y dnf5-plugin-automatic
sudo cp /usr/share/dnf5/dnf5-plugins/automatic.conf /etc/dnf/automatic.conf
sudo sed -i 's/upgrade_type = default/upgrade_type = security/' /etc/dnf/automatic.conf
sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
sudo systemctl enable --now dnf5-automatic.timer

# disable wifi power save
sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-off.conf <<EOF
[connection]
wifi.powersave = 2
EOF
sudo systemctl restart NetworkManager

# cap journald log sizes
sudo mkdir -p /etc/systemd/journald.conf.d/
sudo tee /etc/systemd/journald.conf.d/size-limit.conf << 'EOF'
[Journal]
SystemMaxUse=500M
EOF
sudo systemctl restart systemd-journald

# disable lid switch
sudo tee /etc/systemd/logind.conf << EOF > /dev/null
[Login]
HandleLidSwitch=ignore
EOF
sudo restorecon -F -R /etc/systemd
sudo systemctl restart systemd-logind.service

# disable systemd-resolved port 53 - https://docs.pi-hole.net/docker/tips-and-tricks/
sudo sh -c 'mkdir -p /etc/systemd/resolved.conf.d && printf "[Resolve]\nDNSStubListener=no\n" | tee /etc/systemd/resolved.conf.d/no-stub.conf'
sudo sh -c 'rm -f /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
systemctl restart systemd-resolved
```

## usage
```sh
git clone https://github.com/vuxnq/sheol.git ~/sheol
cd ~/sheol
```

```sh
# docker compose actions
./compose.sh [up|down|update|build|pull|restart]
```

```sh
# backup restoration
# all docker containers must be down
# move backups to ~/backups
./restore.sh
```


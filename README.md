# sheol
[fedora server](https://fedoraproject.org/server/)

## requirements

### tailscale
```sh
# install and start tailscale
sudo dnf install tailscale
sudo systemctl enable --now tailscaled

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

# start docker
sudo systemctl enable --now docker

# add yourself to the docker group
sudo usermod -aG docker $USER
# relog to take effect
```

### misc
```sh
# install
sudo dnf install restic nvim stow

# setting up nvim
git clone https://github.com/vuxnq/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow nvim
```

### post install
```sh
# expand root volume to use all free space
sudo lvextend --extents +100%FREE /dev/mapper/fedora_sheol-root
sudo xfs_growfs /dev/mapper/fedora_sheol-root

# disable lid switch
sudo tee /etc/systemd/logind.conf << EOF > /dev/null
[Login]
HandleLidSwitch=ignore
EOF
sudo restorecon -F -R /etc/systemd
sudo systemctl restart systemd-logind.service
```

## usage
```sh
git clone https://github.com/vuxnq/sheol.git ~/sheol
cd ~/sheol
```

```sh
# docker compose actions
./compose.sh [up|down|pull|restart]
```

```sh
# backup management
# move backups to ~/backups if available
./compose.sh down
./backup.sh [backup|restore]
./compose.sh up
```


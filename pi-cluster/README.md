# pi-cluster

## Shared Steps

Create Disk

* [Install Etcher](https://www.balena.io/etcher)
* [Download Raspbian](https://downloads.raspberrypi.org/raspbian_lite_latest)
* Flash SD with Etcher
* `touch /media/$(whoami)/boot/ssh`

Bootstrap PI

```bash
# enable and start ssh
sudo systemctl enable ssh
sudo systemctl start ssh

# Add authorized key
curl https://github.com/charlieegan3.keys > /home/pi/.ssh/authorized_keys

# Disable password auth
sudo su -c 'echo "PasswordAuthentication no" >> /etc/ssh/sshd_config'
service ssh restart

# set a new password
passwd

# install k3s script
sudo su -c 'curl -sfL https://get.k3s.io > /usr/local/bin/k3s-install.sh'
sudo chmod +x /usr/local/bin/k3s-install.sh
```

## Master Steps

```bash
# install k3s
export $HOSTNAME=master
sudo hostnamectl set-hostname $HOSTNAME
sudo su -c 'echo "127.0.1.1       $HOSTNAME" >> /etc/hosts'
export INSTALL_K3S_EXEC="--no-deploy=traefik,servicelb,local-storage"
k3s-install.sh

# save kube config
mkdir -p /home/pi/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/pi/.kube/config
export KUBECONFIG=/home/pi/.kube/config
sudo chown pi $KUBECONFIG
```

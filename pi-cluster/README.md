# pi-cluster

## Shared Steps

Create Disk

* [Install Etcher](https://www.balena.io/etcher)
* [Download Raspbian](https://downloads.raspberrypi.org/raspbian_lite_latest)
* Flash SD with Etcher
* Mount the boot disk
* `touch /media/$(whoami)/boot/ssh`

Bootstrap PI

```bash
# set a new password
passwd

# set the hostname var
export HOSTNAME=... # worker-n, master
```

Then

```
# enable and start ssh
sudo systemctl enable ssh
sudo systemctl start ssh

# Add authorized key
mkdir /home/pi/.ssh
curl https://github.com/charlieegan3.keys > /home/pi/.ssh/authorized_keys

# Disable password auth
sudo su -c 'echo "PasswordAuthentication no" >> /etc/ssh/sshd_config'
sudo service ssh restart

# install k3s script
sudo su -c 'curl -sfL https://get.k3s.io > /usr/local/bin/k3s-install.sh'
sudo chmod +x /usr/local/bin/k3s-install.sh

# set hostname
sudo hostnamectl set-hostname $HOSTNAME
sudo su -c 'echo "127.0.1.1       $HOSTNAME" >> /etc/hosts'

# enable cgroups
echo 'cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory' | sudo tee -a /boot/cmdline.txt

# show the mac address for router lease
ifconfig -a | grep eth0 -a3 | tail -n 1 | awk '{ print $2}'
```

Configure the router lease, then:

```
sudo shutdown -r now
```

## Master Steps

```bash
# install k3s
export TOKEN=...
export INSTALL_K3S_VERSION=v1.18.10+k3s1
export INSTALL_K3S_EXEC="--no-deploy=traefik,servicelb,local-storage --token=$TOKEN"
k3s-install.sh

# taint
kubectl taint nodes master master=true:NoSchedule

# save kube config
mkdir -p /home/pi/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/pi/.kube/config
export KUBECONFIG=/home/pi/.kube/config
sudo chown pi $KUBECONFIG
```

## Worker Steps

```bash
export INSTALL_K3S_VERSION=v1.17.4+k3s1
export K3S_URL=https://192.168.1.200:6443
export K3S_TOKEN=...
k3s-install.sh
```

## Master Upgrade Steps

```
sudo su -c 'curl -sfL https://get.k3s.io > /usr/local/bin/k3s-install.sh'
sudo chmod +x /usr/local/bin/k3s-install.sh

export INSTALL_K3S_VERSION=v1.18.10+k3s1
k3s-install.sh
```

k3s-install.sh
## Node Upgrade Steps

```
sudo su -c 'curl -sfL https://get.k3s.io > /usr/local/bin/k3s-install.sh'
sudo chmod +x /usr/local/bin/k3s-install.sh

export INSTALL_K3S_VERSION=v1.18.10+k3s1
export K3S_URL=https://192.168.1.200:6443
export K3S_TOKEN=...
k3s-install.sh
```

## About this repo
This repo is a fork from [techiescamp/vagrant-kubeadm-kubernetes](https://github.com/techiescamp/vagrant-kubeadm-kubernetes)
In which we made same tweaks to replace the virtualbox provider with vagrant-libvirt, enable persistence volumes, the addition of a nfs-server VM, nfs-subdir-external-provisioner on the k8s cluster

Refer this link for nfs-subdir-external-provisioner documentation: https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

## Prerequisites

1. Working Vagrant setup
  Arch Linux users, refer the above links for documentation: 
  https://computingforgeeks.com/install-kvm-qemu-virt-manager-arch-manjar/
  https://www.adaltas.com/en/2018/09/19/kvm-vagrant-archlinux/

2. 8 Gig + RAM workstation as the Vms use 3 vCPUS and 4+ GB RAM

## Bring Up the Cluster

To provision the cluster, execute the following commands.

```shell
git clone https://github.com/gregpaes/vagrant-libvirt-kubeadm-kubernetes-nfs.git
cd vagrant-libvirt-kubeadm-kubernetes-nfs
vagrant up --provider=libvirt --no-parallel
```
## Install Kubernetes Dashboard

The dashboard is automatically installed by default, but it can be skipped by commenting out the dashboard version in _settings.yaml_ before running `vagrant up`.

If you skip the dashboard installation, you can deploy it later by enabling it in _settings.yaml_ and running the following:
```shell
vagrant ssh -c "/vagrant/scripts/dashboard.sh" master
```

## Kubernetes Dashboard Access

To get the login token, copy it from the terminal output, after the first vagrant up or run the following command:
```shell
kubectl -n kubernetes-dashboard get secret/admin-user -o go-template="{{.data.token | base64decode}}"
```

Proxy the dashboard:
```shell
kubectl proxy
```

Open the site in your browser:
```shell
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=kubernetes-dashboard
```

## To shutdown the cluster,

```shell
vagrant halt
```

## To restart the cluster,

```shell
vagrant up
```

## To destroy the cluster,

```shell
vagrant destroy -f
```


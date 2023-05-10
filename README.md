
# Vagrantfile and Scripts to Automate Kubernetes Setup using Kubeadm [Practice Environment for CKA/CKAD and CKS Exams]

## Documentation

Current k8s version for CKA, CKAD and CKS exam: 1.26

Refer this link for documentation: https://devopscube.com/kubernetes-cluster-vagrant/

## About this repo
This repo is a fork from https://github.com/gregpaes/vagrant-kubeadm-kubernetes-nfs
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
vagrant up
```
## Set Kubeconfig file variable

```shell
cd vagrant-libvirt-kubeadm-kubernetes-nfs
cd configs
export KUBECONFIG=$(pwd)/config
```

or you can copy the config file to .kube directory.

```shell
cp config ~/.kube/
```

## Install Kubernetes Dashboard

The dashboard is automatically installed by default, but it can be skipped by commenting out the dashboard version in _settings.yaml_ before running `vagrant up`.

If you skip the dashboard installation, you can deploy it later by enabling it in _settings.yaml_ and running the following:
```shell
vagrant ssh -c "/vagrant/scripts/dashboard.sh" master
```

## Kubernetes Dashboard Access

To get the login token, copy it from _config/token_ or run the following command:
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


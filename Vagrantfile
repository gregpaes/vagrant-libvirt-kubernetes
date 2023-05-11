ENV['VAGRANT_NO_PARALLEL'] = 'yes'
VAGRANTFILE_API_VERSION = "2"

require "yaml"
settings = YAML.load_file "settings.yaml"

IP_SECTIONS = settings["network"]["control_ip"].match(/^([0-9.]+\.)([^.]+)$/)
# First 3 octets including the trailing dot:
IP_NW = IP_SECTIONS.captures[0]
# Last octet excluding all dots:
IP_START = Integer(IP_SECTIONS.captures[1])
NUM_WORKER_NODES = settings["nodes"]["workers"]["count"]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provision "shell", env: { "IP_NW" => IP_NW, "IP_START" => IP_START, "NUM_WORKER_NODES" => NUM_WORKER_NODES }, inline: <<-SHELL
    apt-get update -y
    echo "$IP_NW$((IP_START)) master-node" >> /etc/hosts
    for i in `seq 1 ${NUM_WORKER_NODES}`; do
      echo "$IP_NW$((IP_START+i)) worker-node0${i}" >> /etc/hosts
    done
  SHELL

  config.vm.box = settings["software"]["box"]
  config.vm.box_check_update = true
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

#
  config.vm.define "master" do |master|
    master.vm.hostname = "master-node"
    master.vm.network :private_network, ip: settings["network"]["control_ip"]
    master.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    master.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 4, nfs_udp: false, disabled: true
    if settings["shared_folders"]
      settings["shared_folders"].each do |shared_folder|
        master.vm.synced_folder shared_folder["host_path"], shared_folder["vm_path"], type: "nfs", nfs_version: 4, nfs_udp: false
      end
    end
    master.vm.provider "libvirt" do |lb|
      lb.qemu_use_session = false
      lb.uri = "qemu:///system"
      lb.host = "master-node"
      lb.cpus = settings["nodes"]["control"]["cpu"]
      lb.memory = settings["nodes"]["control"]["memory"]
    end
    master.vm.provision "shell",
      env: {
        "DNS_SERVERS" => settings["network"]["dns_servers"].join(" "),
        "ENVIRONMENT" => settings["environment"],
        "KUBERNETES_VERSION" => settings["software"]["kubernetes"],
        "OS" => settings["software"]["os"]
      },
      path: "scripts/common.sh"
    master.vm.provision "shell",
      env: {
        "CALICO_VERSION" => settings["software"]["calico"],
        "CONTROL_IP" => settings["network"]["control_ip"],
        "POD_CIDR" => settings["network"]["pod_cidr"],
        "SERVICE_CIDR" => settings["network"]["service_cidr"]
      },
      path: "scripts/master.sh"
    master.vm.provision "shell",
      env: {
        "DNS_SERVERS" => settings["network"]["dns_servers"].join(" "),
      },
      path: "scripts/nfs.sh"
  end

  (1..NUM_WORKER_NODES).each do |i|

    config.vm.define "node0#{i}" do |node|
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network :private_network, ip: IP_NW + "#{IP_START + i}"
      node.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
      node.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 4, nfs_udp: false, disabled: true
      if settings["shared_folders"]
        settings["shared_folders"].each do |shared_folder|
          node.vm.synced_folder shared_folder["host_path"], shared_folder["vm_path"], type: "nfs", nfs_version: 4, nfs_udp: false
        end
      end
      node.vm.provider "libvirt" do |lb|
        lb.qemu_use_session = false
        lb.uri = "qemu:///system"
        lb.host = "worker-node0#{i}"
        lb.cpus = settings["nodes"]["workers"]["cpu"]
        lb.memory = settings["nodes"]["workers"]["memory"]
      end
      node.vm.provision "shell",
        env: {
          "DNS_SERVERS" => settings["network"]["dns_servers"].join(" "),
          "ENVIRONMENT" => settings["environment"],
          "KUBERNETES_VERSION" => settings["software"]["kubernetes"],
          "OS" => settings["software"]["os"]
        },
        path: "scripts/common.sh"
      node.vm.provision "shell", path: "scripts/node.sh"

      # Only install the dashboard after provisioning the last worker (and when enabled).
      if i == NUM_WORKER_NODES and settings["software"]["dashboard"] and settings["software"]["dashboard"] != ""
        node.vm.provision "file", source: "settings.yaml", destination: "/vagrant/settings.yaml"
        node.vm.provision "shell", path: "scripts/dashboard.sh"
      end
    end
  end
end 

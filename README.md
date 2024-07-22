# Notes from install 20240612

installing on RHel 8
headnode is 192.168.250.14
user is curtis with sudo





# stop all
```
for i in hpe-pldl325g10p-{1..6}; then do ssh root@i "/opt/gpudb/core/bin/gpudb stop all"; done
```

## stop with pdsh
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo su gpudb /opt/gpudb/core/bin/gpudb stop all"
```

# See what is installed
yum list | grep gpudb

# Stop kagent-ui
sudo systemctl stop kagent_ui

# remove the installed gpudb binary
```
dnf remove gpudb-intel-license.x86_64
```

##with pdsh
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo dnf remove -y gpudb-intel-license.x86_64"
```
# on the headnode
rm -rf /opt/gpudb

## remove files with pdsh
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo rm -rf /opt/gpudb"
```

## remove user accounts
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo userdel --remove gpudb; sudo usredel --remove gpudb_proc; sudo groupdel gpudb"
```

# Install GPUDB
## Install repo
sudo dnf config-manager --add-repo https://repo.kinetica.com/yum/7.2/CentOS/8/x86_64/kinetica-7.2.repo
sudo dnf config-manager --set-enabled Kinetica-7.2-repo


# Install kagent
dnf install kagent -y

# change port for tomcat in kagent if there is a port conflict in bringing up Tomcat / kagent-ui
cd /opt/gpudb/kagent/bin
vi kagnet-ui
change the port  8081 -> something else, like 18081
```
export KAGENT_TOMCAT_HTTP_PORT="${KAGENT_TOMCAT_HTTP_PORT:-8081}" <-- alter the port number
```


## restart the service
systemctl restart kagent_ui

## Access kagent_ui
http://192.168.250.14:18081/kagent/#/manage

Tunnel config, if needed
```

```
then host at: http://localhost:18081/kagent/#/manage


# downloading rpms for offline install
```
dnf install --refresh --downloadonly --forcearch x86_64 --downloaddir /root/rpms gpudb-intel-license-7.2.0.8*
```

# Install using kagent (No UI)
Aid built in this project.

# Modifying GPUDB.conf
/opt/gpudb/core/etc/gpudb.conf file is found on the head node.  Modify this file to tune the cluster.
Read:  https://docs.kinetica.com/7.1/install/package/?search-highlight=numa#id-7b11aae8-0073-53ed-b31a-8950572cc572

## Restart gpudb processes after gpudb.conf updated
./kagent cluster control test restart all_gpudb


# Pdsh Aid
                                                                                                                   
## Install PDSH

Aid with PDSH
Source: 
Arch Linux - openssl-1.1 1.1.1.w-1 (x86_64)

~/configure --enable-static-modules --without-rsh --with-ssh --without-ssh-connect-timeout-option –with-genders
Make
Make install


https://www.rittmanmead.com/blog/2014/12/linux-cluster-sysadmin-parallel-command-execution-with-pdsh/
https://www.rittmanmead.com/blog/2014/12/linux-cluster-sysadmin-ssh-keys/


openssl rsa -in ~/.ssh/id_rsa -outform pem > id_rsa.pem
chmod 700 id_rsa.pem

## pdsh mods to bash_profile
export LD_LIBRARY_PATH=/usr/local/lib/pdsh:$LD_LIBRARY_PATH
export PDSH_RCMD_TYPE=ssh
export PDSH_SSH_ARGS_APPEND="-l root"

## j2cli to aid with property file management
As we can see, at this point, I should probably start using Ansible.  Kinetic install, however, is already in Ansible.  
We can acheive some aid in modifying gpudb.conf using j2cli, or we can overwrite the gpudb.conf with a desired copy.

```
sudo pip3 install j2cli
```

# Installing docker / Containerd
-> https://stackoverflow.com/questions/57221919/install-docker-ce-on-redhat-8

```
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install container-selinux
dnf module disable container-tools
dnf install docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
```

```
groupadd docker
usermod -aG docker <user>
```

## Using KIND to pull images into temp k8s cluster

 [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
  400  ls
  401  mv kind ~/bin
  402  chmod u+x bin/kind 

# Create the cluster and configure with basic features
# this also creates ~/.kube/config

helm repo add kinetica-operators https://kineticadb.github.io/charts/latest
# create kind cluster using config from kinetica charts project
kind create cluster --name kinetica --config kind.yaml
  404  kind get cluster
  405  kind get clusters

##get kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

mv kubectl ~/bin
chmod u+x kubectl

## storageclass mock
default is rancher.io/local-path

#sho repos
helm repo list

# show charts
helm search repo <repo name>

# Installing k8s

## Install repo
vi /etc/yum.repos.d/kubernetes.repo
```
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
```

## kernel mods
vi /etc/modules-load.d/k8s.conf
```
overlay
br_netfilter
```

```
sudo modprobe overlay
sudo modprobe br_netfilter
```

## /etc/sysctl.d/99-k8s.conf
```
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
```
```
sysctl --system
```

## Enable containerd sock
https://github.com/containerd/containerd/issues/8139

invert the comments on the default /etc/containerd/config.toml to look like the following:
```
#disabled_plugins = ["cri"]

root = "/var/lib/containerd"
state = "/run/containerd"
subreaper = true
oom_score = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  uid = 0
  gid = 0
```

## disable swap
also, do this permanently... vi /etc/fstab and comment out swap
```
sudo swapoff -a
```


## disable selinux
also, do this permenantly...
```
sudo setenforce 0
```

## Install the k8s binaries
```
sudo dnf install -y kubelet kubadm kubectl --disableexcludes=kubernetes
sudo system enable --now kubelet 

```

## Install k8s control-plane
Note the CNI you will install.  Configure the pod CIDR to match, for example 192.168.0.0/16 for Calico.
```
sudo kubeadm init --config kubeadmin-config.yaml 
```
Copy the join token and take note of copying the admin.conf for your kube/config
```
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $USER: ~/.kube/config
```
### Check cluster
```
kubectl get pods -A
```
Notice that coredns is pending.  Need to install the CNI.


## remove master node taint
list node taints
```
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints --no-headers
or
kubectl get nodes -o json | jq '.items[].spec.taints'
```


kubectl taint node <node> node-role.kubernetes.io/control-plane:NoSchedule-


## CNI install doc
We are installing Calico in default / BGP mode
https://vincent0426.medium.com/setting-up-a-kubernetes-cluster-with-calico-cni-and-applying-network-policies-c196b4f25687
```
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/custom-resources.yaml

kubectl get pods -n calico-system

```




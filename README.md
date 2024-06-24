# Notes from install 20240612

installing on RHel 8
headnode is 192.168.250.14
user is curtis with sudo


# stop all
for i in hpe-pldl325g10p-{1..6}; then do ssh root@i "/opt/gpudb/core/bin/gpudb stop all"; done

# See what is installed
yum list | grep gpudb

# remove the installed gpudb binary
dnf remove gpudb-intel-license.x86_64

# on the headnode
rm -rf /opt/gpudb

# Install repo
dnf config-manager --add-repo https://repo.kinetica.com/yum/7.2/CentOS/8/x86_64/kinetica-7.2.repo

# Install kagent
dnf install kagent

# change port for tomcat in kagent
cd /opt/gpudb/kagent/ui/conf

egrep -rwn -e "KAGENT_TOMCAT_HTTP_PORT"

vi /opt/gpudb/kagent/bin/kagent-ui


## change the port  8081 -> something else
vi logs ../logs/






## restart the service
systemctl restart kagent_ui
---------
# Notes from install 20240612

installing on RHel 8
headnode is 192.168.250.14
user is curtis with sudo

# Uninstall

## stop all
for i in hpe-pldl325g10p-{1..6}; then do ssh root@i "/opt/gpudb/core/bin/gpudb stop all"; done

with pdsh
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo su gpudb /opt/gpudb/core/bin/gpudb stop all"
```

## See what is installed
yum list | grep gpudb

## remove the installed gpudb binary
dnf remove gpudb-intel-license.x86_64

with pdsh
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo dnf remove -y gpudb-intel-license.x86_64" 
```

## remove files
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo rm -rf /opt/gpudb"
```

## remove user accounts
```
pdsh -w hpe-pldl325g10p-[1-6] "sudo userdel --remove gpudb; sudo usredel --remove gpudb_proc; sudo groupdel gpudb"
```

# Install GPUDB
## Install repo
dnf config-manager --add-repo https://repo.kinetica.com/yum/7.2/CentOS/8/x86_64/kinetica-7.2.repo

# Install kagent
dnf install kagent

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

# Configure a cluster
1. click add New or Existing Cluster
2.


# downloading rpms
```
dnf install --refresh --downloadonly --forcearch x86_64 --downloaddir /root/rpms gpudb-intel-license-7.2.0.8*
```
                                                                                                                     


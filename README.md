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




                                                                                                                     
# Install PDSH

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

# pdsh
export LD_LIBRARY_PATH=/usr/local/lib/pdsh:$LD_LIBRARY_PATH
export PDSH_RCMD_TYPE=ssh
export PDSH_SSH_ARGS_APPEND="-l root"


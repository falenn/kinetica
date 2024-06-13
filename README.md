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
vi server.xml
## change the port  8081 -> something else
vi logs ../logs/

## restart the service
systemctl restart kagent_ui



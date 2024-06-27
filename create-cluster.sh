#!/usr/bin/env bash


GPUDB_DIR=/opt/gpudb
KAGENT_DIR=$GPUDB_DIR/kagent/bin
CLUSTER_NAME=test
GPUDB_ADMIN_PASSWORD="GPUdb123!"
GPUDB_RING=default
GPUDB_CORE_INSTALLER=/tmp/rpms/gpudb-intel-license-7.2.0.8.20240610164423.ga-0.el8.x86_64.rpm
GPUDB_CORE_NAME=gpudb-intel-license
GPUDB_LICENSE_KEY="mINVc+nGq36n-NEc6cwnBYCqL-b/LVKG8dK+yI-nvlFF3XyL0Wy-mOaw4bVpxDHpNkYEnKLEXJGsZVRsuJhO"
# User to install as who can sudo 
SSH_USER=cbates
# Path to the ssh key to use
SSH_KEY_PATH=/tmp/gpudb/.ssh/id_ecdsa

# list of nodes to install the cluster on
GPUDB_NODE_LIST=~/test-nodelist.csv
hosts=""

GPUDB_CMD="sudo -u gpudb $KAGENT_DIR/kagent"

#set -e

# Create list of hosts
# load nodes from csv file
while IFS="," read -r rec_node rec_alias rec_role rec_publicip rec_privateip
do
	if [ "$hosts" == "" ]; then
		hosts="$rec_node"
	else
		hosts="${hosts},$rec_node"
	fi
done < <(tail -n +2 $GPUDB_NODE_LIST)
echo "hosts for pdsh: ${hosts}"

# stop the cluster
echo "Stopping the $CLUSTER_NAME cluster"
$GPUDB_CMD cluster control $CLUSTER_NAME stop all

# reset cluster
echo "Removing cluster $CLUSTER_NAME"
$GPUDB_CMD cluster remove $CLUSTER_NAME

#clean up temp
pdsh -w $hosts "sudo rm -rf /tmp/kagent-*"
pdsh -w $hosts "sudo dnf remove -y $GPUDB_CORE_NAME"

# install
# copy the rpm over
echo "Copying over installer rpm $GPU_CORE_INSTALLER"
pdcp -w $hosts $GPUDB_CORE_INSTALLER /tmp/gpudb.rpm
pdsh -w $hosts "chmod 444 /tmp/gpudb.rpm"

# install the rpm
echo "Installing rpm"
pdsh -w $hosts "sudo dnf install -y /tmp/gpudb.rpm"


# stage ssh-key
mkdir -p /tmp/gpudb/.ssh
#sudo chown -R gpudb: /tmp/gpudb/.ssh
sudo cp /home/cbates/.ssh/id_ecdsa /tmp/gpudb/.ssh/id_ecdsa
sudo chown -R gpudb: /tmp/gpudb/.ssh

# create cluster
echo "Creating cluster $CLUSTER_NAME"
$GPUDB_CMD \
	--verbose \
	cluster init $CLUSTER_NAME \
	--infrastructure-provider=onprem \
	--no-root=no \
	--admin-pass=$GPUDB_ADMIN_PASSWORD \
	--ssh-user=$SSH_USER \
	--ring=$GPUDB_RING \
	--connect-via=public_ip_addr \
	--ssh-key=$SSH_KEY_PATH \
	--lic-key=$GPUDB_LICENSE_KEY

# confirm that the cluster was initialized
$GPUDB_CMD cluster list 


# configure nodes from csv file
while IFS="," read -r rec_node rec_alias rec_role rec_publicip rec_privateip
do
	echo "Initializing $rec_node"
	$GPUDB_CMD --verbose \
		node init $rec_alias $rec_privateip $CLUSTER_NAME \
		--roles=$rec_role \
		--public-ip-addr=$rec_publicip

done < <(tail -n +2 $GPUDB_NODE_LIST)

# verify the cluster
$GPUDB_CMD --verbose cluster verify $CLUSTER_NAME

# install
# view here: /opt/gpudb/kagent/python3/lib/python3.10/site-packages/kagent/cli/controllers/cluster.py
#
# Options
#
# --offline-core-installer: sets offline mode and directs the cluster to be installed on the named cluster 
#
# other options exist to configure for k8s install
#
$GPUDB_CMD --verbose cluster install $CLUSTER_NAME \
	--cuda=no \
	--offline-core-installer=$GPUDB_CORE_INSTALLER \
	--open-firewall-ports=yes \
	--nvidia=no \
	--auto-config=yes

# Verify the cluster
$GPUDB_CMD --verbose cluster verify $CLUSTER_NAME

# restart cluster
$GPUDB_CMD --verbose cluster control $CLUSTER_NAME restart all

#!/bin/bash

#Timer
start_time=$(date +%s)

# echo '<username> <password>' > ~/.rhsm
# Define Red Hat secrets
if ! [[ -r ~/.rhsm ]]; then
echo Create secrets file ~/.rhsm containing <redhat-username> <redhat-password>
echo Exiting...
exit 1  # Missing Red Hat credentials
fi
RHSM_USER=$(cut -f1 -d' ' ~/.rhsm)
RHSM_PASS=$(cut -f2 -d' ' ~/.rhsm)

# register VM with Redhat
sudo subscription-manager register --username ${RHSM_USER} --password ${RHSM_PASS}

# Update server and install necessary packages
sudo dnf update -y
sudo dnf install -y wget git rsync ansible-core-2.12*

# create user aap and make him a sudoer
# sudo useradd aap
# echo aap | sudo passwd aap --stdin
# echo 'aap ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/aap

# Extract tar archive and cd into it
cd
tar xf ansible-automation-platform-setup-bundle-2.2.0-7.tar.gz
cd ansible-automation-platform-setup-bundle-2.2.0-7

# set FQDN hostname
echo '10.0.2.15 aap.igwegbu.tech aap' | sudo tee -a /etc/hosts
sudo hostnamectl hostname aap.igwegbu.tech

# Create ansible config file
cat <<-EOF > ./ansible.cfg
[defaults]
inventory=./inventory
remote_user=aap
ask_pass=false
become=true
become_method=sudo
become_user=root
become_ask_pass=false
EOF

# Create the invetory file
cat <<-EOF > ./inventory
[automationcontroller]
aap.igwegbu.tech

[database]

[all:vars]
admin_password='redhat'

pg_host=''
pg_port=''

pg_database='awx'
pg_username='awx'
pg_password='redhat'

registry_url='registry.redhat.io'
registry_username='ecigwegbu'
registry_password='yt76D2itE'
EOF

# Run the installer script with priviledge escallation
./setup.sh -- -b

# Timer
end_time=$(date +%s)
duration=$((end_time - start_time))
echo Finished in "$((${duration}/60)) minutes, $((${duration}%60)) seconds"

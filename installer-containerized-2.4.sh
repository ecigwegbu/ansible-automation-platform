#!/bin/bash

# Ansible Automation Platform AAP version 2.4
#
# Installer for single node option (containerized)
#
# usage: ./<this-script.sh> <tarball.tar.gz> <manifest.zip> [<post-install-repo-url> | false]
#
# Note that <post-install-repo-url> is only required if using Config-As-Code postinstall feature
# If not provided, a default post-install-repo-url is used: 'https://github.com/ecigwegbu/aap-cac'
# To disable this behaviour pass 'false' as the argument in its place instead
#
# Minimum system requirements: 6CPUs, 6 GB RAM, 40 GB storage, RHEL9.2+
# For added security relace all demonstration passwords 'redhat' in this script with your own
cd
start_time=$(date +%s)

# Check for at least 6 CPUs
cpu_count=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
echo "CPU(s): $cpu_count"
if (( cpu_count < 6 )); then
  echo "Insufficient CPU"
  exit 1  # Insufficient CPU
fi

# Check for at least 8GB RAM
mem_total=$(free -g | awk '/^Mem:/ {print $2}')
echo "RAM: $mem_total"
if (( mem_total < 6 )); then
  echo "Insufficient RAM"
  echo $mem_total
  exit 2  # Insufficient RAM
fi

# Check for at least 40GB storage in /
storage_avail=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
echo "Storage: $storage_avail"
if (( storage_avail < 40 )); then
  echo "Insufficient Storage"
  exit 3  # Insufficient Storage
fi

# Before running this script, first ensure you create a Red Hat secrets file ~/.rhsm
# which should contain one line in the format:
# <red-hat-username> <red-hat-password>

# Check that this script has been properly called
if [[ -z "${1%.tar.gz}" ]] || [[ -z "${2%.zip}" ]]; then
  echo "Invalid command."
  echo "Usage: ./<this-script.sh> <tarball.tar.gz> <manifest.zip> [<post-install-repo-url>]"
  echo "Exiting...Invalid command usage"
  exit 2  # Invalid command usage
fi

# First verify Red Hat Subscription secrets file ~/.rhsm exists
if ! [[ -f ~/.rhsm ]]; then
  echo "Missing Red Hat subscription secrets"
  echo "Create a secrets file ~/.rhsm for your RHSM username and password"
  echo "The file ~/.rhsm should contain a single line in the format:"
  echo "<red-hat-username> <red-hat-password>"
  echo
  echo "Exiting...Missing Red Hat registry authorization"
  exit 1  # Missing Red Hat Registry authorisation
fi

# Initialise variables
RHSM_USER=$(cut -f1 -d' ' ~/.rhsm)
RHSM_PASS=$(cut -f2 -d' ' ~/.rhsm)
INI_DIR=${PWD}
TARBALL=$1
AAP_MANIFEST=$2
WORKDIR=${INI_DIR}/${TARBALL%.tar.gz}
HOST=$(hostname -f)
if [[ -n $3 ]] && [[ $3 != false ]]; then
  # Argument is defined and not 'false'
  POSTINSTALL=true
  POSTINSTALL_REPO_URL=$3
elif [[ $3 == false ]]; then
  # Argument is exactly 'false'
  POSTINSTALL=false
  POSTINSTALL_REPO_URL=''
else
  # Argument is empty
  POSTINSTALL=true
  POSTINSTALL_REPO_URL='https://github.com/ecigwegbu/aap-cac'
fi

# register this server, if not already done
sudo subscription-manager register --username ${RHSM_USER} --password ${RHSM_PASS} 2>/dev/null

# Install required packages
echo -e "\n---\nInstalling required packages..."
sudo dnf update -y && sudo dnf install -y ansible-core wget git rsync container-tools

# Extract the tarball
tar xf ${TARBALL}

# Switch to the installer directory
cd ${WORKDIR}

# Create the inventory file
cat <<-EOF > ${WORKDIR}/inventory
  [automationcontroller]
  ${HOST} ansible_connection=local

  [automationhub]

  [automationeda]

  [execution_nodes]

  [database]
  ${HOST} ansible_connection=local

  [all:vars]

  postgresql_admin_username=postgres
  postgresql_admin_password=redhat
  registry_username="{{ lookup('env', 'RHSM_USER') }}"
  registry_password="{{ lookup('env', 'RHSM_PASS') }}"

  controller_admin_password=redhat
  controller_pg_host=${HOST}
  controller_pg_password=redhat

  controller_postinstall=${POSTINSTALL}
  controller_license_file=${INI_DIR}/${AAP_MANIFEST}
  controller_postinstall_dir=${INI_DIR}/aap-containerized
  controller_postinstall_repo_url='${POSTINSTALL_REPO_URL}'
  controller_postinstall_repo_ref=main

  hub_admin_password=redhat
  hub_pg_host=${HOST}
  hub_pg_password=redhat

  eda_admin_password=redhat
  eda_pg_host=${HOST}
  eda_pg_password=redhat
EOF

# Optionally Update the ansible.cfg file

# Run the playbook
ansible-playbook -i inventory ansible.containerized_installer.install

# Timer
end_time=$(date +%s)
duration=$((end_time - start_time))
echo Finished in "$((${duration}/60)) minutes, $((${duration}%60)) seconds"

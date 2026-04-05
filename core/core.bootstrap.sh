#!/bin/bash

set -euo pipefail

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

# Execute script relatively where script is
cd "$(dirname "$0")"

# Apply system update before anything
dnf upgrade -y && dnf autoremove -y && dnf clean all -y &&
  # Ensure linux format of core stuff & system & user execution
  find ./ -type f -exec dos2unix {} \; && chmod 755 -R ./ &&
  # Init system & os configuration
  bash ./init/system/main.install.sh && bash ./init/system/os.config.sh &&
  # Ensure proper users rights & copy to real home folder before running scripts as user
  chown ${NVIL_USER}:${NVIL_USER} -R ./ && cp -ar ./init/res/home/. /home/${NVIL_USER} &&
  # Make /home/linuxbrew writable for Homebrew installation for NVIL_USER
  mkdir -p /home/linuxbrew/ && chown ${NVIL_USER}:${NVIL_USER} /home/linuxbrew/
  # Init user install & config
  runuser -u ${NVIL_USER} -- bash -c "./init/system/user.install.sh" &&
  runuser -u ${NVIL_USER} -- bash -c "./init/system/user.config.sh" &&
  # Install required features as user
  runuser -u ${NVIL_USER} -- bash -c "./init/feats/required.install.sh" &&
  # Drop init folder
  rm -rf ./init

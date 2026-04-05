#!/bin/bash

set -euo pipefail

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

### Assert Envs Properly set ###
: "${NVIL_USER:?Environment variable NVIL_USER is not set}"
: "${NVIL_WORKSPACE_DIR:?Environment variable NVIL_WORKSPACE_DIR is not set}"

# Create the main user
useradd -m -d /home/${NVIL_USER} -s /bin/zsh -G wheel ${NVIL_USER}

# Add workspace dir
mkdir -p ${NVIL_WORKSPACE_DIR}
chown -R ${NVIL_USER}:${NVIL_USER} ${NVIL_WORKSPACE_DIR}

# Delete user password & allow to execute sudo without a password
passwd -d ${NVIL_USER}
echo "${NVIL_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NVIL_USER}
chmod 0440 /etc/sudoers.d/${NVIL_USER}

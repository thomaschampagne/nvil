#!/bin/bash

set -eo pipefail

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

### Assert Envs Properly set ###
: "${NVIL_USER:?Environment variable NVIL_USER is not set}"
: "${NVIL_WORKSPACE_DIR:?Environment variable NVIL_WORKSPACE_DIR is not set}"

# Create the main user
useradd -m -d /home/${NVIL_USER} -s /bin/zsh -G wheel ${NVIL_USER}
# Also configure default bashrc when user will use it
cp /etc/skel/.bashrc /home/${NVIL_USER}/
chown ${NVIL_USER}:${NVIL_USER} /home/${NVIL_USER}/.bashrc

# Add workspace dir
mkdir -p ${NVIL_WORKSPACE_DIR}
chown -R ${NVIL_USER}:${NVIL_USER} ${NVIL_WORKSPACE_DIR}

# Create runtime dir for user-specific non-essential runtime files and objects
USER_XDG_RUNTIME_DIR="/run/user/${NVIL_USER}"
mkdir -p "$USER_XDG_RUNTIME_DIR"
chmod 0700 "$USER_XDG_RUNTIME_DIR"
chown -R ${NVIL_USER}:${NVIL_USER} ${USER_XDG_RUNTIME_DIR}

# Delete user password & allow to execute sudo without a password
passwd -d ${NVIL_USER}
echo "${NVIL_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NVIL_USER}
chmod 0440 /etc/sudoers.d/${NVIL_USER}

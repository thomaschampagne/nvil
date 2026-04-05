#!/bin/bash

set -euo pipefail

echo "============================================================"
echo "exec \"$(realpath "$0")\" as \"$(whoami)\" user"
echo "============================================================"

### Apply core installs ###
echo "Install base packages"

dnf install -y --setopt=install_weak_deps=False \
  sudo \
  hostname \
  coreutils \
  ncurses \
  libicu \
  util-linux \
  shadow-utils \
  strace \
  xclip \
  xsel \
  wl-clipboard \
  gettext \
  dos2unix \
  less \
  tree \
  which \
  findutils \
  procps-ng \
  psmisc \
  bind-utils \
  iproute \
  iputils \
  traceroute \
  jetbrains-mono-fonts \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  zsh \
  gcc \
  git \
  openssl \
  ca-certificates \
  nano \
  vim \
  curl \
  wget \
  nmap \
  netcat \
  file \
  tcpdump \
  rsync \
  xz \
  tar \
  gzip \
  unzip \
  jq \
  yq \
  btop \
  fastfetch

echo "Removing unnecessary packages..."
dnf autoremove -y

echo "Cleaning up..."
dnf clean all -y

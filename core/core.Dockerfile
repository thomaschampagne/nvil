# Overridden from build-args.default.conf through CI & nvil.img.make.sh
ARG NVIL_FEDORA_BASE_VERSION=latest
ARG NVIL_USER="smith"
ARG NVIL_WORKSPACE_DIR="/workspace"

# OCI Args
ARG OCI_BASE_IMAGE=registry.fedoraproject.org/fedora-minimal:${NVIL_FEDORA_BASE_VERSION}
ARG OCI_BASE_IMAGE_URL=https://hub.docker.com/_/fedora
ARG OCI_TITLE=oci-nvil-image
ARG OCI_REPO_URL=https://github.com/thomaschampagne/nvil
ARG OCI_DESCRIPTION="A portable Fedora terminal-driven development forge"
ARG OCI_MAINTAINER="Thomas Champagne"

FROM ${OCI_BASE_IMAGE}

ARG OCI_BASE_IMAGE
ARG OCI_BASE_IMAGE_URL
ARG OCI_TITLE
ARG OCI_DESCRIPTION
ARG OCI_VERSION
ARG OCI_MAINTAINER
ARG OCI_REPO_URL
ARG OCI_BUILD_DATE
ARG NVIL_USER
ARG NVIL_WORKSPACE_DIR
ARG NVIL_FLAVOR="nvil-core"
ARG NVIL_GIT_USER_NAME="Smith Black"
ARG NVIL_GIT_USER_EMAIL="smith@nvil.dev"
ARG NVIL_OMP_THEME="spaceship" # Can be overloaded at build w/ ARG or runtime with ENV with any theme from https://ohmyposh.dev/docs/themes

# Envs From Args build
ENV NVIL_USER=${NVIL_USER} \
  NVIL_WORKSPACE_DIR=${NVIL_WORKSPACE_DIR} \
  NVIL_GIT_USER_NAME=${NVIL_GIT_USER_NAME} \
  NVIL_GIT_USER_EMAIL=${NVIL_GIT_USER_EMAIL} \
  NVIL_DEFAULT_EDITOR="nvim" \
  NVIL_VERSION=${OCI_VERSION} \
  NVIL_FLAVOR=${NVIL_FLAVOR} \
  NVIL_OMP_THEME=${NVIL_OMP_THEME} \
  TZ="Europe/Paris" \
  TERM="xterm-256color" \
  COLORTERM="truecolor"

LABEL name=${NVIL_FLAVOR} \
  version=${OCI_VERSION} \
  maintainer=${OCI_MAINTAINER} \
  description=${OCI_DESCRIPTION} \
  url=${OCI_REPO_URL} \
  base-image=${OCI_BASE_IMAGE} \
  base-image-url=${OCI_BASE_IMAGE_URL} \
  org.opencontainers.image.name=${NVIL_FLAVOR} \
  org.opencontainers.image.title=${OCI_TITLE} \
  org.opencontainers.image.description=${OCI_DESCRIPTION} \
  org.opencontainers.image.version=${OCI_VERSION} \
  org.opencontainers.image.created=${OCI_BUILD_DATE} \
  org.opencontainers.image.authors=${OCI_MAINTAINER} \
  org.opencontainers.image.url=${OCI_REPO_URL} \
  org.opencontainers.image.base.name=${OCI_BASE_IMAGE} \
  org.opencontainers.image.base.url=${OCI_BASE_IMAGE_URL}

# Switch to setup workspace for init & config
WORKDIR /nvil

# ---- Core Init ---- 
COPY ./core/ ./core/
RUN echo "Creating NVIL image from ${OCI_BASE_IMAGE}..." && \
  # And core system package to continue
  dnf install -y dos2unix tini && \
  # Run core bootstrap
  dos2unix ./core/core.bootstrap.sh && bash ./core/core.bootstrap.sh && \
  # Ensure proper rights on /nvil folder for user
  chown ${NVIL_USER}:${NVIL_USER} /nvil

# Switch to default workspace directory
WORKDIR ${NVIL_WORKSPACE_DIR}

# Force default user instead of root
USER ${NVIL_USER}

ENTRYPOINT ["/sbin/tini", "--", "/nvil/core/cmd/entrypoint.sh"]


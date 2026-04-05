ARG NVIL_CORE_IMAGE
FROM ${NVIL_CORE_IMAGE}

ARG NVIL_FLAVOR="nvil-full"

LABEL name=${NVIL_FLAVOR} \
  org.opencontainers.image.name=${NVIL_FLAVOR}
ENV NVIL_FLAVOR=${NVIL_FLAVOR}

# Applying system update temporary as root
USER root
RUN /nvil/core/cmd/nvil --update
# Force default user instead of root
USER ${NVIL_USER}

# ================================ START - CHOOSE YOUR FEATURES BELOW  ================================ #

# Install cli tools
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/tools/ /nvil/.tmp/

# Javascript/Typescript support with eslint
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/languages/js-ts /nvil/.tmp/

# Add bun Javascript Runtime
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/runtimes/bun /nvil/.tmp/

# Go Language
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/languages/golang /nvil/.tmp/

# # Dockerfile
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/languages/dockerfile /nvil/.tmp/

# ================================ END - CHOOSE YOUR FEATURES ABOVE ================================ #

# Bulk apply feats
RUN tree /nvil/.tmp/ && \
  bash /nvil/core/utils/feats.install.sh --features-folder /nvil/.tmp

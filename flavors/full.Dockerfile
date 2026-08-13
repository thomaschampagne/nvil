ARG NVIL_CORE_IMAGE
FROM ${NVIL_CORE_IMAGE}

ARG NVIL_FLAVOR="nvil-full"

LABEL name=${NVIL_FLAVOR} \
  org.opencontainers.image.name=${NVIL_FLAVOR}
ENV NVIL_FLAVOR=${NVIL_FLAVOR}

# Applying system update temporary as root
USER root
RUN --mount=type=secret,id=GITHUB_TOKEN,required=true,mode=0444 \
  export GITHUB_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" && \
  export HOMEBREW_GITHUB_API_TOKEN="$GITHUB_TOKEN" && \
  /nvil/core/cmd/nvil --update
# Force default user instead of root
USER ${NVIL_USER}

# ================================ START - CHOOSE YOUR FEATURES BELOW  ================================ #

# Install cli tools
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/tools/ /nvil/.tmp/

# Javascript/Typescript support with eslint
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/languages/web /nvil/.tmp/

# Add bun Javascript Runtime
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/runtimes/bun /nvil/.tmp/

# Go Language
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/languages/golang /nvil/.tmp/

# Dockerfile
COPY --parents --chown=${NVIL_USER}:${NVIL_USER} ./feats/languages/dockerfile /nvil/.tmp/

# ================================ END - CHOOSE YOUR FEATURES ABOVE ================================ #

# Bulk apply feats
# GITHUB_TOKEN mounted as secret and exported so mise/brew calls to GitHub API
# are authenticated (5000 req/hr) instead of anonymous (60 req/hr) - avoids
# rate-limit failures when many feats resolve tool versions/releases.
RUN --mount=type=secret,id=GITHUB_TOKEN,required=true,mode=0444 \
  export GITHUB_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" && \
  export HOMEBREW_GITHUB_API_TOKEN="$GITHUB_TOKEN" && \
  tree /nvil/.tmp/ && \
  bash /nvil/core/utils/feats.install.sh --features-folder /nvil/.tmp

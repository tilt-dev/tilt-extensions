FROM docker/tilt:latest

# Utils for our CI
RUN apt update \
    && apt install -y --no-install-recommends \
      apt-transport-https \
      build-essential \
      ca-certificates \
      git \
      jq \
      netcat \
      software-properties-common \
      wget \
    && rm -rf /var/lib/apt/lists/*

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install Go toolchain
COPY --from=golang:1.19-bullseye /usr/local/go /usr/local/go
ENV PATH=/root/go/bin:/usr/local/go/bin:$PATH

# install Ko
RUN mkdir -p /root/go/bin && \
  curl -sSL https://github.com/google/ko/releases/download/v0.9.3/ko_0.9.3_Linux_x86_64.tar.gz | tar xzf - ko && \
  chmod +x ko && \
  mv ko /root/go/bin/ko && \
  which ko

# install kubectl build
ARG KUBECTL_BUILD_VERSION=0.1.6
RUN curl -sSL https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v${KUBECTL_BUILD_VERSION}/kubectl-buildkit_${KUBECTL_BUILD_VERSION}_amd64.deb -o kubectl-buildkit.deb && \
  dpkg -i kubectl-buildkit.deb

# install buildpack CLI
ARG PACK_VERSION=v0.27.0
RUN curl -sSL "https://github.com/buildpacks/pack/releases/download/${PACK_VERSION}/pack-${PACK_VERSION}-linux.tgz" | \
  tar -C /usr/local/bin/ --no-same-owner -xzv pack

# install nodejs + yarn
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt install -y -q --no-install-recommends \
      default-jdk \
      nodejs \
      yarn \
    && rm -rf /var/lib/apt/lists/*

# install Pulumi CLI
RUN curl -fsSL https://get.pulumi.com | sh
ENV PATH=/root/.pulumi/bin:$PATH

# install earthly
ARG EARTHLY_VERSION=v0.6.28
RUN wget https://github.com/earthly/earthly/releases/download/${EARTHLY_VERSION}/earthly-linux-amd64 -O /usr/local/bin/earthly

# ensure any dependencies from manual dpkg installs are ok
RUN apt update \
  && apt install -f \
  && rm -rf /var/lib/apt/lists/*

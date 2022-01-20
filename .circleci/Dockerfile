FROM tiltdev/tilt:latest

# Utils for our CI
RUN apt update && apt install -y git build-essential apt-transport-https software-properties-common ca-certificates wget jq netcat

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install Go toolchain
COPY --from=golang:1.17-buster /usr/local/go /usr/local/go
ENV PATH=/root/go/bin:/usr/local/go/bin:$PATH

# install Ko
RUN mkdir -p /root/go/bin && \
  curl -sSL https://github.com/google/ko/releases/download/v0.9.3/ko_0.9.3_Linux_x86_64.tar.gz | tar xzf - ko && \
  chmod +x ko && \
  mv ko /root/go/bin/ko && \
  which ko

# install kubectl build
RUN curl -sSL https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v0.1.4/kubectl-buildkit_0.1.4_amd64.deb > kubectl-buildkit.deb && \
  dpkg -i kubectl-buildkit.deb && \
  apt install -f

# install buildpack CLI
RUN curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.21.1/pack-v0.21.1-linux.tgz" | \
  tar -C /usr/local/bin/ --no-same-owner -xzv pack

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update && apt install -y yarn

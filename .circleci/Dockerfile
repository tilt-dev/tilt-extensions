FROM tiltdev/tilt:latest

# Utils for our CI
RUN apt update && apt install -y git build-essential
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
COPY --from=golang:1.15-buster /usr/local/go /usr/local/go
ENV PATH=/root/go/bin:/usr/local/go/bin:$PATH

RUN mkdir -p /root/go/bin
RUN curl -sSL https://github.com/google/ko/releases/download/v0.8.1/ko_0.8.1_Linux_x86_64.tar.gz | tar xzf - ko && \
  chmod +x ko && \
  mv ko /root/go/bin/ko && \
  which ko


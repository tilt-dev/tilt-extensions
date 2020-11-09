FROM tiltdev/tilt:latest

# Utils for our CI
RUN apt update && apt install -y git
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
COPY --from=golang:1.15-buster /usr/local/go /usr/local/go
ENV PATH=/root/go/bin:/usr/local/go/bin:$PATH
RUN GO111MODULE=on go get github.com/google/ko/cmd/ko && which ko


FROM alpine:3.7

WORKDIR /build
RUN mkdir /output

RUN apk add curl unzip

# install helm
ENV VERSION=2.14.0 CHECKSUM=b5f6a1e642971af1363cadbe1f7f37c029c11dd93813151b521c0dbeacfbdaa9
RUN curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v${VERSION}-linux-amd64.tar.gz && \
    echo "$CHECKSUM  helm-v$VERSION-linux-amd64.tar.gz" | sha256sum -c && \
    tar -zxvf helm-v${VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && \
    helm init --client-only

# fetch vault chart
ENV version 0.4.0
RUN curl -LO https://github.com/hashicorp/vault-helm/archive/v$version.zip
RUN unzip v$version.zip && mv vault-helm-$version/ chart

COPY values-secret.yaml ./values.yaml
COPY additional ./additional
RUN helm template chart \
  --name=vs \
  --namespace=vault \
  --values=values.yaml > /output/chart.yaml

RUN cp additional/* /output/

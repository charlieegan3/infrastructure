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
ENV version 7636ee6334edc4e0b9d1f08ffba015a55c1c876d
RUN curl -LO https://github.com/ricoberger/vault-secrets-operator/archive/$version.zip
RUN unzip $version.zip && mv vault-secrets-operator-$version/ operator && \
    mv operator/charts/vault-secrets-operator chart

RUN rm -r chart/templates/tests

COPY values.yaml ./
RUN helm template chart \
  --name=vs \
  --namespace=vault-secrets-operator \
  --values=values.yaml > /output/chart.yaml

COPY includes includes
RUN cp includes/* /output/

FROM alpine:3.7

WORKDIR /build
RUN mkdir /output

RUN apk add curl

# install helm
ENV VERSION=2.14.0 CHECKSUM=b5f6a1e642971af1363cadbe1f7f37c029c11dd93813151b521c0dbeacfbdaa9
RUN curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v${VERSION}-linux-amd64.tar.gz && \
    echo "$CHECKSUM  helm-v$VERSION-linux-amd64.tar.gz" | sha256sum -c && \
    tar -zxvf helm-v${VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && \
    helm init --client-only

# fetch prometheus chart
ENV CHART_VERSION=0.13.0
RUN helm fetch stable/oauth2-proxy --version=$CHART_VERSION && \
    tar -zxf oauth2-proxy-${CHART_VERSION}.tgz

COPY . .

# overwrite the deployment template to allow customiszations
RUN cp replacements/deployment.yaml oauth2-proxy/templates/deployment.yaml

# render proxy chart
RUN helm template --name=oauth2-proxy \
      --namespace=oauth2-proxy \
      --values=values/oauth2-proxy.yaml \
      oauth2-proxy >> /output/oauth2-proxy.yaml

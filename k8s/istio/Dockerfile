FROM alpine:3.7

WORKDIR /build

RUN apk add curl

# install helm
ENV VERSION=2.14.0 CHECKSUM=b5f6a1e642971af1363cadbe1f7f37c029c11dd93813151b521c0dbeacfbdaa9
RUN curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v${VERSION}-linux-amd64.tar.gz && \
    echo "$CHECKSUM  helm-v$VERSION-linux-amd64.tar.gz" | sha256sum -c && \
    tar -zxvf helm-v${VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && \
    helm init --client-only && \
	rm helm-v$VERSION-linux-amd64.tar.gz && \
	rm -r linux-amd64


# fetch prometheus chart
ENV ISTIO_VERSION=1.2.8
RUN curl -L https://github.com/istio/istio/archive/$ISTIO_VERSION.zip > istio.zip && \
    unzip istio.zip && \
	mv istio-$ISTIO_VERSION istio && \
	rm istio.zip

RUN mv istio/install/kubernetes/helm/istio-init chart-init
RUN mv istio/install/kubernetes/helm/istio chart-istio

RUN mkdir /output

COPY manifests/namespaces.yaml /output/init.yaml

RUN helm template chart-init \
    --name=init \
    --namespace=istio-system >> /output/init.yaml

COPY values.yaml values.yaml

RUN helm template chart-istio \
    --name=istio \
    --values=values.yaml \
    --namespace=istio-system >> /output/istio.yaml

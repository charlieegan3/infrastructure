FROM alpine:3.7

WORKDIR /build

RUN apk add --update alpine-sdk curl go
RUN go get github.com/brancz/gojsontoyaml && \
	mv /root/go/bin/gojsontoyaml /usr/local/bin && \
	chmod +x /usr/local/bin/gojsontoyaml
ENV JSONNET_VERSION=f1c0bb237dff9b228f0ea09d432a912204ec352b
RUN curl -L https://github.com/google/jsonnet/archive/$JSONNET_VERSION.zip > jsonnet.zip && \
	unzip jsonnet.zip && cd jsonnet-$JSONNET_VERSION && make && mv jsonnet /usr/bin/jsonnet && chmod +x /usr/bin/jsonnet

# install helm
ENV VERSION=2.14.0 CHECKSUM=b5f6a1e642971af1363cadbe1f7f37c029c11dd93813151b521c0dbeacfbdaa9
RUN curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v${VERSION}-linux-amd64.tar.gz && \
    echo "$CHECKSUM  helm-v$VERSION-linux-amd64.tar.gz" | sha256sum -c && \
    tar -zxvf helm-v${VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && \
    helm init --client-only

# fetch prometheus chart
ENV CHART_VERSION=8.3.3
RUN helm repo update && helm fetch stable/prometheus-operator --version=$CHART_VERSION && \
    tar -zxf prometheus-operator-${CHART_VERSION}.tgz

# fetch kube-state-metrics chart
ENV CHART_VERSION=2.4.0
RUN helm repo update && helm fetch stable/kube-state-metrics --version=$CHART_VERSION && \
    tar -zxf kube-state-metrics-${CHART_VERSION}.tgz

# fetch and extract grafana chart
ENV CHART_VERSION=3.11.1
RUN helm repo update && helm fetch stable/grafana --version=$CHART_VERSION && \
    tar -zxf grafana-${CHART_VERSION}.tgz

# fetch and extract stackdriver exporter chart
ENV CHART_VERSION=1.2.1
RUN helm repo update && helm fetch stable/stackdriver-exporter --version=$CHART_VERSION && \
    tar -zxf stackdriver-exporter-${CHART_VERSION}.tgz

RUN mkdir /output
COPY includes includes
COPY values values

RUN cat includes/namespace.yaml > /output/0-namespace.yaml

# render prometheus-operator
RUN helm template --name=po \
      --namespace=monitoring \
      --values=values/prometheus-operator.yaml \
      prometheus-operator > /output/prometheus.yaml
RUN cat includes/prometheus/*.yaml >> /output/prometheus.yaml

# render grafana chart
RUN rm -r grafana/templates/tests
RUN helm template --name=gf \
      --namespace=monitoring \
      --values=values/grafana.yaml \
      grafana > /output/grafana.yaml
RUN cat includes/grafana/*.yaml >> /output/grafana.yaml

# render kube-state-metrics
RUN helm template --name=ksm \
      --namespace=monitoring \
      --values=values/kube-state-metrics.yaml \
      kube-state-metrics > /output/kube-state-metrics.yaml
RUN cat includes/kube-state-metrics/*.yaml >> /output/kube-state-metrics.yaml

# render stackdriver-exporter
RUN helm template --name=stkexp \
      --namespace=monitoring \
      --values=values/stackdriver-exporter.yaml \
      stackdriver-exporter > /output/stackdriver-exporter.yaml

# 'render' cloud-billing-exporter
RUN cat includes/cloud-billing-exporter/*.yaml >> /output/cloud-billing-exporter.yaml

# render thanos deployment
COPY thanos thanos
RUN cd thanos && set -o pipefail && jsonnet -J vendor -m manifests thanos.jsonnet | \
	xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}
RUN cp thanos/manifests/*.yaml /output/

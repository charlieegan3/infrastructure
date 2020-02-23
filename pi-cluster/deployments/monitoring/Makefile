JSONNET_BIN := jsonnet
JB_BINARY := $(GOPATH)/bin/jb

.PHONY: vendor manifests

all: manifests

manifests:
	rm -rf manifests
	./scripts/build.sh main.jsonnet $(JSONNET_BIN)

concat: manifests
	cat manifests/*

update:
	jb update

vendor:
	rm -rf vendor
	$(JB_BINARY) install

apply: manifests
	kubectl apply -f ./manifests/

#!/usr/bin/env bash

set -e
set -x
set -o pipefail

# remove the old generated  files (if any)
rm -rf manifests && mkdir manifests

# generate the json files, convert to yamls, remove the json files
jsonnet -J vendor -m manifests thanos.jsonnet | \
	xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}

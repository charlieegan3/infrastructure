PROJECT := charlieegan3/istio
NAMESPACE := istio-system

image:
	docker build -t $(PROJECT) .

build: image
	rm -rf output
	mkdir output
	container=$$(docker create $(PROJECT) exit) && \
		docker cp $$container:/output/. output/all
	cat output/all/*.yaml > output/merged.yaml

apply: build
	kubectl config set-context --current --namespace=$(NAMESPACE)
	kubectl apply -f output/all

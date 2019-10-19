PROJECT := charlieegan3/oauth2-proxy

image:
	docker build -t $(PROJECT) .

build: image
	rm -rf output
	mkdir output
	container=$$(docker create $(PROJECT) exit) && \
		docker cp $$container:/output/. output/all
	cat output/all/*.yaml > output/merged.yaml

apply:
	kubectl config set-context --current --namespace=auth
	kubectl apply -f output/merged.yaml -n auth

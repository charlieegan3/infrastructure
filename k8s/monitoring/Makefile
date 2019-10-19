PROJECT := charlieegan3/monitoring

image:
	docker build -t $(PROJECT) .

build: image
	rm -rf output
	mkdir output
	container=$$(docker create $(PROJECT) exit) && \
		docker cp $$container:/output/. output/all
	cat output/all/*.yaml > output/merged.yaml

apply: build
	kubectl config set-context --current --namespace=monitoring
	kubectl apply -f output/all

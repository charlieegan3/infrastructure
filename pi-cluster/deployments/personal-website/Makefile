build:
	./build.sh

apply: build
	kubectl config set-context --current --namespace=personal-website
	kubectl apply -f manifests

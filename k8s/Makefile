bootstrap:
	kubectl apply -f 00-admin-cluster-role-binding.yaml

apply_helm:
	for project in *; do \
	if [ -d "$${project}" ]; then \
		if [ -f "$${project}/Chart.yaml" ]; then \
			echo "Applying $${project}..."; \
			echo "  using helm..."; \
			helm template $${project} | kubectl apply -f -; \
		fi; \
	fi \
	done

apply_all: bootstrap apply_helm
	for project in *; do \
	if [ -d "$${project}" ]; then \
		if [ ! -f "$${project}/Chart.yaml" ]; then \
			echo "Applying $${project}..."; \
			kubectl apply -f $${project}; \
		fi; \
	fi \
	done

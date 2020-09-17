IMAGE:=trailofbits/algo@sha256:dfddeb1d49532a76babad1045996b746477e40b8726a2db82d20c35ff1b17085
DATA_DIR:=data

# commands related to instance state
create: check
	docker run -it \
		-v $(CURDIR)/$(DATA_DIR):/data \
		-v $(CURDIR)/google.json:/etc/secrets/google.json \
		$(IMAGE)

update: check
	docker run -it \
		-v $(CURDIR)/$(DATA_DIR):/data \
		-v $(CURDIR)/google.json:/etc/secrets/google.json \
		-e "ALGO_ARGS=update-users" \
		$(IMAGE)

check:
	[ -f google.json ]
	[ -d $(DATA_DIR) ]

# commands related to processing local config
permissions:
	sudo find $(DATA_DIR) -type d -exec chmod 0755 {} \;
	sudo find $(DATA_DIR) -type f -exec chmod 0644 {} \;
	sudo find $(DATA_DIR) -type f -iname "*.sh" -exec chmod +x {} \;

zip: permissions
	zip -r data.zip $(DATA_DIR)

unzip:
	unzip data.zip
	rm data.zip

# commands related to configuring access for local machine
install_%: permissions
	instance=$(shell basename $$(find data/configs/* -maxdepth 0 -type d)) && \
	echo $$instance && \
	sudo install -o root -g root -m 600 $(DATA_DIR)/configs/$$instance/wireguard/$*.conf /etc/wireguard/wg0.conf

connect:
	sudo systemctl start wg-quick@wg0
	sudo systemctl status wg-quick@wg0
	sudo wg
	curl ipv4.icanhazip.com

disconnect:
	sudo systemctl stop wg-quick@wg0
	sudo wg
	curl ipv4.icanhazip.com

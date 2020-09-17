# vpn

Pre-requisites:
- `google.json` for VPN SA from bitwarden/terraform
- `data` containing config.cfg

Commands:
* `make create` to start a new instance or update config (maybe)
* `make update` to only update users
* `make zip` to create a data.zip for bitwarden
* `make install_desktop` to install the desktop config on the current machine
* `make connect/disconnect` to start or stop the wg connection

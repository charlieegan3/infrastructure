# charlieegan3-cluster vault config

This is how vault is configured.

**Note: the root token is in password store and needs to be set as VAULT_TOKEN
in .envrc** e.g.

```
export VAULT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx
export VAULT_ADDR=http://localhost:8200
export VAULT_SKIP_VERIFY="true"
```

## `make connect`

This will connect you to the running vault instance in Kubernetes and expose it
locally to run `make configure`.

## `make configure`

Runs the configure script to set the state in vault.

Secrets are not set in this script, these have been manually added and are
stored in `pass` for save keeping.

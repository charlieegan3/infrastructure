#!/usr/bin/env bash

if [ -n "$VAULT_TOKEN" ]; then
  echo "Found vault token in environment"
else
  echo "Missing VAULT_TOKEN var"
  exit
fi

export VAULT_ADDR=http://localhost:8200
export VAULT_SKIP_VERIFY="true"

kubernetes_enabled=$(vault auth list --format=json | jq -r '.["kubernetes/"]')
if [ "$kubernetes_enabled" != "null" ]; then
  echo "kubernetes auth already enabled"
else
  echo "enabling kubernetes auth"

  VAULT_SA_NAME=$(kubectl get sa vs-vault -o jsonpath="{.secrets[*]['name']}")
  SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
  SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

  vault auth enable kubernetes

  vault write auth/kubernetes/config \
    token_reviewer_jwt="$SA_JWT_TOKEN" \
    kubernetes_host="https://kubernetes.default:443" \
    kubernetes_ca_cert="$SA_CA_CRT"
fi

secrets_enabled=$(vault secrets list --format=json | jq -r '.["secret/"]')
if [ "$secrets_enabled" != "null" ]; then
  echo "secrets engine already enabled"
else
  echo "enabling secrets engine"
  vault secrets enable -version=1 -path=secret kv
fi

# configure k8s workloads
vault write auth/kubernetes/role/clockify \
  bound_service_account_names=default \
  bound_service_account_namespaces=clockify \
  policies=clockify \
  ttl=1h
vault policy write clockify policies/clockify.hcl

vault write auth/kubernetes/role/calendars \
  bound_service_account_names=default \
  bound_service_account_namespaces=calendars \
  policies=calendars \
  ttl=1h
vault policy write calendars policies/calendars.hcl

vault write auth/kubernetes/role/serializer \
  bound_service_account_names=default \
  bound_service_account_namespaces=serializer \
  policies=serializer \
  ttl=1h
vault policy write serializer policies/serializer.hcl

vault write auth/kubernetes/role/music \
  bound_service_account_names=default \
  bound_service_account_namespaces=music \
  policies=music \
  ttl=1h
vault policy write music policies/music.hcl

vault write auth/kubernetes/role/airtable-spaced-repetition \
  bound_service_account_names=default \
  bound_service_account_namespaces=airtable-spaced-repetition \
  policies=airtable-spaced-repetition \
  ttl=1h
vault policy write airtable-spaced-repetition policies/airtable-spaced-repetition.hcl

vault write auth/kubernetes/role/drive-backup \
  bound_service_account_names=default \
  bound_service_account_namespaces=drive-backup \
  policies=drive-backup \
  ttl=1h
vault policy write drive-backup policies/drive-backup.hcl

vault write auth/kubernetes/role/instagram-archive \
  bound_service_account_names=default  \
  bound_service_account_namespaces=instagram-archive \
  policies=instagram-archive \
  ttl=1h
vault policy write instagram-archive policies/instagram-archive.hcl

vault write auth/kubernetes/role/auth \
  bound_service_account_names=default \
  bound_service_account_namespaces=auth \
  policies=auth \
  ttl=1h
vault policy write auth policies/auth.hcl

vault write auth/kubernetes/role/finance \
  bound_service_account_names=config-map-creator \
  bound_service_account_namespaces=finance \
  policies=finance \
  ttl=1h
vault policy write finance policies/finance.hcl

vault write auth/kubernetes/role/monitoring \
  bound_service_account_names=alertmanager-config-creator \
  bound_service_account_namespaces=monitoring \
  policies=monitoring \
  ttl=1h
vault write auth/kubernetes/role/monitoring \
  bound_service_account_names=default \
  bound_service_account_namespaces=monitoring \
  policies=monitoring \
  ttl=1h
vault policy write monitoring policies/monitoring.hcl

vault write auth/kubernetes/role/personal-website \
  bound_service_account_names=default \
  bound_service_account_namespaces=personal-website \
  policies=personal-website \
  ttl=1h
vault policy write personal-website policies/personal-website.hcl

vault write auth/kubernetes/role/flashcards-api \
  bound_service_account_names=default \
  bound_service_account_namespaces=flashcards \
  policies=flashcards-api \
  ttl=1h
vault policy write flashcards-api policies/flashcards-api.hcl

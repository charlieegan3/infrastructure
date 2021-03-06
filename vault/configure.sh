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

  VAULT_SA_NAME=$(kubectl get sa -n vault vs-vault -o jsonpath="{.secrets[*]['name']}")
  SA_JWT_TOKEN=$(kubectl get secret -n vault $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
  SA_CA_CRT=$(kubectl get secret -n vault $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

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

vault write auth/kubernetes/role/photos \
  bound_service_account_names=archive \
  bound_service_account_namespaces=photos \
  policies=photos  \
  ttl=1h
vault policy write photos policies/photos.hcl

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
  bound_service_account_names=default,thanos-store,alertmanager-config-creator,po-promop-prometheus,thanos-config-creator,grafana-config-creator \
  bound_service_account_namespaces=monitoring \
  policies=monitoring \
  ttl=1h
vault policy write monitoring policies/monitoring.hcl

vault write auth/kubernetes/role/personal-website \
  bound_service_account_names=default,config-map-creator \
  bound_service_account_namespaces=personal-website \
  policies=personal-website \
  ttl=1h
vault policy write personal-website policies/personal-website.hcl

vault write auth/kubernetes/role/edgemax-exporter \
  bound_service_account_names=default \
  bound_service_account_namespaces=edgemax-exporter \
  policies=edgemax-exporter \
  ttl=1h
vault policy write edgemax-exporter policies/edgemax-exporter.hcl

vault write auth/kubernetes/role/simple-proxy \
  bound_service_account_names=default \
  bound_service_account_namespaces=simple-proxy \
  policies=simple-proxy \
  ttl=1h
vault policy write simple-proxy policies/simple-proxy.hcl

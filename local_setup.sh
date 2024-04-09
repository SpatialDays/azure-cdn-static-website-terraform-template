#!/bin/bash
set -a;
source .env;
set +a;
envsubst < provider_secrets_template > provider_secrets
terraform init --backend-config=provider_secrets
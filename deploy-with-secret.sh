#!/bin/bash
set -e

cd /home/ssm-user/app

SECRET_ARN=$(grep '^DB_SECRET_ARN=' .env | cut -d'=' -f2-)
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text)

DB_USER=$(echo "$SECRET_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['username'])")
DB_PASSWORD=$(echo "$SECRET_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])")

echo "DB_USER=$DB_USER" >> .env
echo "DB_PASSWORD=$DB_PASSWORD" >> .env

export TAG=nosecrets
docker compose pull
docker compose up -d --force-recreate api

sed -i '/^DB_USER=/d; /^DB_PASSWORD=/d' .env

echo "Deployment complete. .env has been cleaned of secret values."
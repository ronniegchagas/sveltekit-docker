#!/bin/sh
set -e

CERT_DIR=/certs
CN=frontend.local

mkdir -p "$CERT_DIR"

openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout "$CERT_DIR/frontend.local-key.pem" \
  -out "$CERT_DIR/frontend.local.pem" \
  -subj "/CN=$CN" \
  -addext "subjectAltName = DNS:$CN,IP:127.0.0.1"

chmod 644 "$CERT_DIR/frontend.local.pem"
chmod 600 "$CERT_DIR/frontend.local-key.pem"

echo "Generated certificate for $CN"
exit 0

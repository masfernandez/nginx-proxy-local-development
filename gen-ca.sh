#!/bin/bash

# default data
password=masfernandez
country=ES
state=Madrid
locality=Madrid
organization=masfernandez
organizational_unit=IT
common_name=masfernandezCA
email=fictional@email.com

echo "----------------------------"
echo "Create private key"
openssl genrsa \
        -des3 \
        -passout pass:$password \
        -out ca/masfernandez.key \
        2048 \
        -noout

echo "----------------------------"
echo "Removing passphrase from key"
openssl rsa \
        -in ca/masfernandez.key \
        -passin pass:$password \
        -out ca/masfernandez.key

echo "----------------------------"
echo "Create root certificate"
openssl req -x509 -new -nodes \
        -key ca/masfernandez.key \
        -sha256 -days 1024 \
        -out ca/masfernandez.crt \
        -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizational_unit/CN=$common_name/emailAddress=$email"

echo "----------------------------"
echo "Installing root certificate"
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ca/masfernandez.crt
#!/bin/bash

if [ -z "$1" ]
then
    echo "[ERROR] Argument not present"
    echo "Examples of usage:"
    echo "$0 my-new-site.127.0.0.1.xip.io"
    echo "$0 wildcard.127.0.0.1.xip.io"
    echo -e "\t ... generates wildcard cert as *.127.0.0.1.xip.io"
    echo "$0 wildcard.127.0.0.1.xip.io"
    echo -e "\t ... generates wildcard cert as *.xip.io"
    echo "$0 wildcard.xip.io  -> generates wildcard cert *.xip.io"
    exit 99
fi

folder=$1
domain=$(echo $folder | sed "s#wildcard#\*#")
common_name=$domain

echo $folder
echo $domain
echo $common_name


# OPTIONAL: Change here to your company details
country=
state=
locality=
organization=
organizational_unit=
email=fictional@email.com
password=masfernandez

mkdir certs/$folder

# KEY
echo "----------------------------"
echo "Generating key request for $domain"
openssl genrsa -des3 \
        -passout pass:$password \
        -out certs/$folder/privkey.key \
        2048 \
        -noout

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "----------------------------"
echo "Removing passphrase from key"
openssl rsa \
        -in certs/$folder/privkey.key \
        -passin pass:$password \
        -out certs/$folder/privkey.key \

# CSR
echo "----------------------------"
echo "Creating CSR"
openssl req \
        -new \
        -key certs/$folder/privkey.key \
        -out certs/$folder/csr.csr \
        -passin pass:$password \
        -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizational_unit/CN=$common_name/emailAddress=$email"

echo "----------------------------"
echo "Creating ext file"
cat > certs/$folder/ext.ext <<- EOM
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $domain
EOM

# CRT
echo "----------------------------"
echo "Signing cert"
openssl x509 -req \
        -in certs/$folder/csr.csr \
        -CA ca/masfernandez.crt \
        -CAkey ca/masfernandez.key \
        -passin pass:masfernandez \
        -out certs/$folder/cert.crt \
        -days 365 \
        -sha256 \
        -CAcreateserial \
        -extfile certs/$folder/ext.ext


openssl verify certs/$folder/cert.crt

echo "----------------------------"
echo "cat certs/$folder/cert.crt"
echo "cat certs/$folder/privkey.key"
echo "----------------------------"
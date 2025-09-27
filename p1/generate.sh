#!/bin/bash

ID=kocharminmd
G=627
EMAIL=xnpster@yandex.ru

rm -rf p1

mkdir p1
cd p1

# root
openssl genrsa -aes256 \
    -out ${ID}-${G}-ca.key \
    -passout pass:${ID} -quiet 4096

openssl req -x509 \
    -days 1096 \
    -new \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_1/CN=${ID} CA/emailAddress=${EMAIL}" \
    -addext basicConstraints=critical,CA:true \
    -addext keyUsage=critical,digitalSignature,cRLSign,keyCertSign \
    -key ${ID}-${G}-ca.key \
    -out ${ID}-${G}-ca.crt \
    -passin pass:${ID}

#intermidiate
openssl genrsa -aes256 \
    -out ${ID}-${G}-intr.key \
    -passout pass:${ID} -quiet 4096

openssl req -new \
    -key ${ID}-${G}-intr.key \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_1/CN=${ID} Intermediate CA/emailAddress=${EMAIL}" \
    -addext basicConstraints=critical,CA:true,pathlen:0 \
    -addext keyUsage=critical,digitalSignature,cRLSign,keyCertSign \
    -out intr.csr \
    -passin pass:${ID}

openssl x509 \
    -req \
    -days 365 \
    -CA ${ID}-${G}-ca.crt \
    -CAkey ${ID}-${G}-ca.key \
    -CAcreateserial -CAserial serial \
    -copy_extensions copyall \
    -in intr.csr \
    -out ${ID}-${G}-intr.crt \
    -passin pass:${ID}

#basic
openssl genrsa \
    -out ${ID}-${G}-basic.key \
    -passout pass:${ID} -quiet 2048

openssl req -new \
    -key ${ID}-${G}-basic.key \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_1/CN=${ID} Basic/emailAddress=${EMAIL}" \
    -addext basicConstraints=CA:false \
    -addext keyUsage=critical,digitalSignature \
    -addext extendedKeyUsage=critical,serverAuth,clientAuth \
    -addext subjectAltName=DNS.0:basic.${ID}.ru,DNS.1:basic.${ID}.com \
    -out basic.csr \
    -passin pass:${ID}

openssl x509 \
    -req \
    -days 90 \
    -CA ${ID}-${G}-intr.crt \
    -CAkey ${ID}-${G}-intr.key \
    -CAcreateserial -CAserial serial \
    -copy_extensions copyall \
    -in basic.csr \
    -out ${ID}-${G}-basic.crt \
    -passin pass:${ID}


zip ${ID}-${G}-p1_1.zip *.key *.crt
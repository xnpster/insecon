#!/bin/bash

ID=kocharminmd
G=627
EMAIL=xnpster@yandex.ru

rm -rf p3

mkdir p3
cd p3

# authorityInfoAccess =
# OCSP;URI:http://ocsp.ivanovii.ru:2560

#valid
openssl genrsa \
    -out ${ID}-${G}-ocsp-valid.key \
    -passout pass:${ID} -quiet 2048

openssl req -new \
    -key ${ID}-${G}-ocsp-valid.key \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_3/CN=${ID} OCSP Valid/emailAddress=${EMAIL}" \
    -addext basicConstraints=CA:false \
    -addext keyUsage=critical,digitalSignature \
    -addext extendedKeyUsage=critical,serverAuth,clientAuth \
    -addext subjectAltName=DNS:ocsp.valid.${ID}.ru \
    -addext "authorityInfoAccess=OCSP;URI:http://ocsp.${ID}.ru" \
    -out ocsp-valid.csr \
    -passin pass:${ID}

openssl x509 \
    -req \
    -days 90 \
    -CA ../p1/${ID}-${G}-intr.crt \
    -CAkey ../p1/${ID}-${G}-intr.key \
    -CAcreateserial -CAserial serial \
    -copy_extensions copyall \
    -in ocsp-valid.csr \
    -out ${ID}-${G}-ocsp-valid.crt \
    -passin pass:${ID}

#revoked
openssl genrsa \
    -out ${ID}-${G}-ocsp-revoked.key \
    -passout pass:${ID} -quiet 2048

openssl req -new \
    -key ${ID}-${G}-ocsp-revoked.key \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_3/CN=${ID} OCSP Revoked/emailAddress=${EMAIL}" \
    -addext basicConstraints=CA:false \
    -addext keyUsage=critical,digitalSignature \
    -addext extendedKeyUsage=critical,serverAuth,clientAuth \
    -addext subjectAltName=DNS:ocsp.revoked.${ID}.ru \
    -addext "authorityInfoAccess=OCSP;URI:http://ocsp.${ID}.ru" \
    -out ocsp-revoked.csr \
    -passin pass:${ID}

openssl x509 \
    -req \
    -days 90 \
    -CA ../p1/${ID}-${G}-intr.crt \
    -CAkey ../p1/${ID}-${G}-intr.key \
    -CAcreateserial -CAserial serial \
    -copy_extensions copyall \
    -in ocsp-revoked.csr \
    -out ${ID}-${G}-ocsp-revoked.crt \
    -passin pass:${ID}

# OCSP cert
openssl genrsa \
    -out ${ID}-${G}-ocsp-resp.key \
    -passout pass:${ID} -quiet 2048

openssl req -new \
    -key ${ID}-${G}-ocsp-resp.key \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_3/CN=${ID} OCSP Responder/emailAddress=${EMAIL}" \
    -addext basicConstraints=CA:false \
    -addext keyUsage=critical,digitalSignature \
    -addext extendedKeyUsage=OCSPSigning \
    -out ocsp-resp.csr \
    -passin pass:${ID}

openssl x509 \
    -req \
    -days 365 \
    -CA ../p1/${ID}-${G}-intr.crt \
    -CAkey ../p1/${ID}-${G}-intr.key \
    -CAcreateserial -CAserial serial \
    -copy_extensions copyall \
    -in ocsp-resp.csr \
    -out ${ID}-${G}-ocsp-resp.crt \
    -passin pass:${ID}

touch index.txt

openssl ca \
    -config ../p3.cnf \
    -cert ../p1/${ID}-${G}-intr.crt \
    -keyfile ../p1/${ID}-${G}-intr.key \
    -valid ${ID}-${G}-ocsp-valid.crt \
    -passin pass:${ID}

openssl ca \
    -config ../p3.cnf \
    -cert ../p1/${ID}-${G}-intr.crt \
    -keyfile ../p1/${ID}-${G}-intr.key \
    -revoke ${ID}-${G}-ocsp-revoked.crt \
    -passin pass:${ID}

cat ../p1/${ID}-${G}-{ca,intr}.crt > ${ID}-${G}-chain.crt
cat ${ID}-${G}-ocsp-revoked.crt ../p1/${ID}-${G}-intr.crt  > ${ID}-${G}-revoked-chain.crt
cat ${ID}-${G}-ocsp-valid.crt ../p1/${ID}-${G}-intr.crt  > ${ID}-${G}-valid-chain.crt

#!/bin/bash

ID=kocharminmd
G=627
EMAIL=xnpster@yandex.ru

rm -rf p2

mkdir p2
cd p2

#valid
openssl genrsa \
    -out ${ID}-${G}-crl-valid.key \
    -passout pass:${ID} -quiet 2048

openssl req -new \
    -key ${ID}-${G}-crl-valid.key \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_2/CN=${ID} CRL Valid/emailAddress=${EMAIL}" \
    -addext basicConstraints=CA:false \
    -addext keyUsage=critical,digitalSignature \
    -addext extendedKeyUsage=critical,serverAuth,clientAuth \
    -addext subjectAltName=DNS:crl.valid.${ID}.ru \
    -addext crlDistributionPoints=URI:http://crl.${ID}.ru \
    -out valid.csr \
    -passin pass:${ID}

openssl x509 \
    -req \
    -days 90 \
    -CA ../p1/${ID}-${G}-intr.crt \
    -CAkey ../p1/${ID}-${G}-intr.key \
    -CAcreateserial -CAserial serial \
    -copy_extensions copyall \
    -in valid.csr \
    -out ${ID}-${G}-crl-valid.crt \
    -passin pass:${ID}

#revoked
openssl genrsa \
    -out ${ID}-${G}-crl-revoked.key \
    -passout pass:${ID} -quiet 2048

openssl req -new \
    -key ${ID}-${G}-crl-revoked.key \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=${ID}/OU=${ID} P1_2/CN=${ID} CRL Revoked/emailAddress=${EMAIL}" \
    -addext basicConstraints=CA:false \
    -addext keyUsage=critical,digitalSignature \
    -addext extendedKeyUsage=critical,serverAuth,clientAuth \
    -addext subjectAltName=DNS:crl.revoked.${ID}.ru \
    -addext crlDistributionPoints=URI:http://crl.${ID}.ru \
    -out revoked.csr \
    -passin pass:${ID}

openssl x509 \
    -req \
    -days 90 \
    -CA ../p1/${ID}-${G}-intr.crt \
    -CAkey ../p1/${ID}-${G}-intr.key \
    -CAcreateserial -CAserial serial \
    -copy_extensions copyall \
    -in revoked.csr \
    -out ${ID}-${G}-crl-revoked.crt \
    -passin pass:${ID}

# list of revoked certificates

touch index.txt

openssl ca \
    -config ../p2.cnf \
    -cert ../p1/${ID}-${G}-intr.crt \
    -keyfile ../p1/${ID}-${G}-intr.key \
    -revoke ${ID}-${G}-crl-revoked.crt \
    -passin pass:${ID}

openssl ca \
    -gencrl \
    -config ../p2.cnf \
    -cert ../p1/${ID}-${G}-intr.crt \
    -keyfile ../p1/${ID}-${G}-intr.key \
    -out ${ID}-${G}.crl \
    -passin pass:${ID}

cat ../p1/${ID}-${G}-{ca,intr}.crt > ${ID}-${G}-chain.crt

echo ""
echo "Verification:"
openssl verify -crl_check \
    -CRLfile ${ID}-${G}.crl \
    -CAfile ${ID}-${G}-chain.crt \
    ${ID}-${G}-crl-revoked.crt ${ID}-${G}-crl-valid.crt
echo ""


zip ${ID}-${G}-p1_2.zip *.key *.crt *.crl
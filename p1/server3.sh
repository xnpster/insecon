#!/bin/bash

ID=kocharminmd
G=627
EMAIL=xnpster@yandex.ru

cd p3

sudo openssl ocsp \
    -port 2560 \
    -index index.txt \
    -CA ${ID}-${G}-chain.crt \
    -rkey ${ID}-${G}-ocsp-resp.key \
    -rsigner ${ID}-${G}-ocsp-resp.crt \
    -passin pass:${ID} 
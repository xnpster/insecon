#!/bin/bash

ID=kocharminmd
G=627
EMAIL=xnpster@yandex.ru

cp ../revoked.log ${ID}-${G}-ocsp-revoked.log
cp ../revoked_final.pcapng ${ID}-${G}-ocsp-revoked.pcapng
cp ../valid.log ${ID}-${G}-ocsp-valid.log
cp ../valid_final.pcapng ${ID}-${G}-ocsp-valid.pcapng

zip ${ID}-${G}-p1_3.zip *.key *.crt *.log *.pcapng
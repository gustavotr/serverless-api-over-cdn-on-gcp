#!/bin/bash

if [[ $# == 0 ]] ; then
    echo 'You must provide a password with a least 4 characters'
    exit
fi

pass=$1

openssl genrsa -des3 -passout pass:$pass -out keypair.key 2048
openssl rsa -passin pass:$pass -in keypair.key -out private.key
rm keypair.key
openssl req -new -key private.key -out request.csr
openssl x509 -req -days 365 \
  -in request.csr \
  -signkey private.key \
  -out cert.crt
rm request.csr
#!/usr/bin/env bash

[[ -n $1 ]] || { echo "usage: $0 [CUSTOMER]" ; exit 1 ; }

CUSTOMER=$1

export PUBKEY=$(< ~/.ssh/id_rsa.pub)

curl -X POST -d "$(envsubst < ${CUSTOMER}/config.yaml)" localhost:8080/api/config
#!/usr/bin/env bash

[[ -n $1 ]] || { echo "usage: $0 [CUSTOMER]" ; exit 1 ; }

CUSTOMER=$1

uploadTemplates() {
    cd ${CUSTOMER}
    for TEMPLATE in $(find api -type f) ; do
        curl -X POST -d "$(< ${TEMPLATE})" localhost:8080/${TEMPLATE}
    done
    cd ..
}

uploadConfig() {
    export GW=$(ip route | awk '/default/ { print $3 }')
    export IP=$(ip route | awk '/default/ { print $9 }')
    export PUBKEY=$(< ~/.ssh/id_rsa.pub)
    curl -X POST -d "$(envsubst < ${CUSTOMER}/config.yaml)" localhost:8080/api/config
}

uploadTemplates
uploadConfig
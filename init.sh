#!/usr/bin/env bash

[[ -n $1 ]] || { echo "usage: $0 [CUSTOMER] [update,start]" ; exit 1 ; }

CUSTOMER=${1}
MODE=${2:-start}

startApp() {
    export APPVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 appver < ${CUSTOMER}/config.yaml)
    export DNSVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 dnsver < ${CUSTOMER}/config.yaml)
    docker-compose up -d
}

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

uploadClusterConfig() {
    if [[ -f ${CUSTOMER}/cluster.json ]] ; then
        curl -X POST -d "$(< ${CUSTOMER}/cluster.json)" localhost:8080/api/cluster
    fi
}

if [[ "${MODE}" == "start" ]] ; then
    startApp
fi

uploadTemplates
uploadConfig
uploadClusterConfig
#!/usr/bin/env bash

[[ -n $1 ]] || { echo "usage: $0 [CUSTOMER] [update,start,keygen]" ; exit 1 ; }

CUSTOMER=${1}
MODE=${2:-start}
SSHDIR=${CUSTOMER}/.ssh

startApp() {
    export APPVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 appver < ${CUSTOMER}/config.yaml)
    export DNSVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 dnsver < ${CUSTOMER}/config.yaml)
    docker-compose up -d
}

keyGen() {
    if [[ -f ${CUSTOMER}/.ssh/id_rsa ]] ; then
        exit
    fi
    if ! [[ -d ${SSHDIR} ]] ; then
        mkdir -p ${SSHDIR}
        chmod 700 ${SSHDIR}
    fi
    ssh-keygen -t rsa -b 4096 -f ${SSHDIR}/id_rsa -P "" -C "" -q
    exit
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
    export PUBKEY=$(< ${SSHDIR}/id_rsa.pub)
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

if [[ "${MODE}" == "keygen" ]]; then
    keyGen
else
    uploadTemplates
    uploadConfig
    uploadClusterConfig
fi

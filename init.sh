#!/usr/bin/env bash

# check if parameters are set
[[ $# -eq 0 ]] && { echo "usage: $0 [init,start,update,keygen] [CUSTOMER]" ; exit 1 ; }

MODE=${1}
CUSTOMER=${2}
SELF_DIR=$(git rev-parse --show-toplevel)
SSHDIR=${SELF_DIR}/${CUSTOMER}/.ssh

runInit() {
    [[ -d ${SELF_DIR}/../file-permission-hooks ]] && return
    git clone https://github.com/300481/file-permission-hooks.git ${SELF_DIR}/../file-permission-hooks
    for HOOK in $(find ${SELF_DIR}/../file-permission-hooks/ -maxdepth 1 -executable -type f) ; do
        ln -s ${HOOK} ${SELF_DIR}/.git/hooks/${HOOK##*/}
    done
    exit
}

startApp() {
    export APPVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 appver < ${CUSTOMER}/config.yaml)
    export DNSVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 dnsver < ${CUSTOMER}/config.yaml)
    docker-compose up -d
    update
}

update() {
    uploadTemplates
    uploadConfig
    uploadClusterConfig
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

case ${MODE} in
    init)
        runInit
        ;;
    keygen)
        keyGen
        ;;
    start)
        startApp
        ;;
    update)
        update
        ;;
    *)
        exit
        ;;
esac

#!/usr/bin/env bash

[[ -n $1 ]] || { echo "usage: $0 [CUSTOMER]" ; exit 1 ; }

CUSTOMER=$1

# get apps version for this customer config
APPVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 appver < ${CUSTOMER}/config.yaml)

# clone app and start
git clone --branch ${APPVER} https://github.com/300481/3141.git app
app/3141.sh

# wait for app
for x in $(seq 10) ; do
    APPSTATUS=$(docker inspect -f '{{ .State.Status }}' 3141)
    DNSSTATUS=$(docker inspect -f '{{ .State.Status }}' dnsmasq)
    [[ "${APPSTATUS}" == "running" ]] && [[ "${DNSSTATUS}" == "running" ]] && break
    [[ ${x} -eq 10 ]] && echo "app not running" && exit 1
    sleep 2
done
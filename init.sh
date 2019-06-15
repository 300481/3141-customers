#!/usr/bin/env bash

[[ -n $1 ]] || { echo "usage: $0 [CUSTOMER]" ; exit 1 ; }

CUSTOMER=$1

APPVER=$(docker run -i --rm --name yq 300481/yq:v2.4.0 appver < ${CUSTOMER}/config.yaml)

git clone --branch ${APPVER} git@github.com:300481/3141.git app
app/3141.sh
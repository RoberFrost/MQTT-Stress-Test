#!/bin/bash -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function delete(){
    pushd $SCRIPT_DIR > /dev/null
    kubectl delete ns influxdb
    popd > /dev/null
}

function create(){
    pushd $SCRIPT_DIR > /dev/null
    kubectl create ns influxdb
    helm upgrade --install influxdb  oci://registry-1.docker.io/bitnamicharts/influxdb -f values.yml -n influxdb
    popd > /dev/null
}

case $1 in
    rm)
        delete
    ;;
    *)
        create
    ;;
esac
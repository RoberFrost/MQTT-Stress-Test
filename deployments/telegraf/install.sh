#!/bin/bash -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function delete(){
    pushd $SCRIPT_DIR > /dev/null
    kubectl delete ns telegraf
    popd > /dev/null
}

function create(){
    pushd $SCRIPT_DIR > /dev/null
    kubectl create ns telegraf
    helm repo add influxdata https://helm.influxdata.com/ 
    
    helm upgrade  --install telegraf  influxdata/telegraf-ds -f values.yml -n telegraf
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
#!/bin/bash -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function delete(){
    pushd $SCRIPT_DIR > /dev/null
    kubectl delete -f manifest.yml -n mosquitto
    kubectl delete ns mosquitto
    popd > /dev/null
}

function create(){
    pushd $SCRIPT_DIR > /dev/null
    kubectl create ns mosquitto
    kubectl apply -f manifest.yml -n mosquitto
    popd > /dev/null
}

function get_node_port(){
    kubectl -n mosquitto get service mosquitto -o=jsonpath='{.spec.ports[0].nodePort}{"\n"}' 
}

case $1 in
    rm)
        delete
    ;;
    nodeport)
        get_node_port
    ;;
    *)
        create
    ;;
esac
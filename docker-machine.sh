#!/bin/sh

function node_create {
    docker-machine create ${DOCKER_MACHINE_CREATE_OPTS} $1
}

function node_exec {
    NODE=$1
    shift
    docker-machine ssh $NODE -- $*
}

function node_ip {
    docker-machine ip $1
}

function node_remove {
    docker-machine rm -y -f $1
}

function node_restart {
    docker-machine restart $1
}

function node_start {
    docker-machine start $1
}

function node_stop {
    docker-machine stop $1
}

function node_upgrade {
    docker-machine upgrade $1
}


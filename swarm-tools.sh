#!/bin/sh

#
# Define the swarm size
#
MANAGER_COUNT=3
WORKER_COUNT=3


#
# Define the node names
#
MANAGER_NAME=swarm-manager
WORKER_NAME=swarm-worker


#
# All nodes
#
MANAGER_LIST=""
WORKER_LIST=""
NODE_LIST=""


source './utils.sh'
source './docker-machine-kvm.sh'


for i in `seq 1 $MANAGER_COUNT`;
do
    MANAGER_LIST="$MANAGER_LIST $MANAGER_NAME-$i"
done

for i in `seq 1 $WORKER_COUNT`;
do
    WORKER_LIST="$WORKER_LIST $WORKER_NAME-$i"
done

NODE_LIST="$MANAGER_LIST $WORKER_LIST"


function is_worker {
    if $( contains $1 "$WORKER_LIST" )
    then
        echo true
        return
    fi
    echo false
}

function is_manager {
    if $( contains $1 "$MANAGER_LIST" )
    then
        echo true
        return
    fi
    echo false
}


function node_foreach {
    for node in $2
    do
        $1 $node
    done
}

function node_foreach_async {
    PIDS=""
    for node in $2
    do
        $1 $node &
        PIDS="$PIDS $!"
    done

    for pid in $PIDS
    do
        wait $pid
    done
}

function node_do {
    node_foreach_async $1 "$NODE_LIST"
}

function manager_do {
    node_foreach_async $1 "$MANAGER_LIST"
}

function worker_do {
    node_foreach_async $1 "$WORKER_LIST"
}

function node_create_all {
    node_do node_create
}

function node_remove_all {
    node_do node_remove
}

function get_swarm_worker_token {
    node_exec $MANAGER_NAME-1 docker swarm join-token -q worker
}

function get_swarm_manager_token {
    node_exec $MANAGER_NAME-1 docker swarm join-token -q manager
}

function swarm_join {
    if [ "$1" == "$MANAGER_NAME-1" ]; then
        return
    fi

    ip=`node_ip $MANAGER_NAME-1`

    if `is_manager $1`
    then
        token=`get_swarm_manager_token`
    fi

    if `is_worker $1`
    then
        token=`get_swarm_worker_token`
    fi

    node_exec $1 docker swarm join --token $token $ip:2377
}

function swarm_join_all {
    node_do swarm_join
}

function swarm_create {
    manager_ip=`node_ip $MANAGER_NAME-1`
    node_exec $MANAGER_NAME-1 docker swarm init --advertise-addr $manager_ip
    swarm_join_all
}


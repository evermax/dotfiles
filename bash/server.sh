#!/bin/bash

createServerVM() {
    docker-machine create -d virtualbox \
        --virtualbox-hostonly-cidr "192.168.97.1/24" \
        --virtualbox-cpu-count "1" \
        --virtualbox-disk-size "10000" \
        --virtualbox-memory "1024" server

    setDockerVM server
    docker pull busybox
}

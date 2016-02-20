#!/bin/bash

# Docker playground
# Start or set the env variables on docker.
function setDockerVM() {
    echo "Docker machine $1 status:"
    state=$(docker-machine status $1)
    if [[ $state =~ (Stopped) ]]; then
        printf "Stopped, starting it...\n"
        docker-machine start $1
        printf "Started\n"
    elif [[ $state =~ (Running) ]]; then
        printf "Running\n"
    fi
    eval "$(docker-machine env $1)"
    printf "Env variables set, ready to go!\n"
}

dcleanup(){
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
}

dockerCopy() {
    if [ "$#" -ne 3 ]; then
        echo "Expect 3 arguments:\nthe name for the docker machine from which to copy,\nthe name for the image\nand the name for the docker machine to copy the image to"
    else
        docker $(docker-machine config $1) save $2 | docker $(docker-machine config $3) load
    fi
}

del_stopped(){
    local name=$1
    local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

    if [[ "$state" == "false" ]]; then
        docker rm $name
    fi
}

usesocat() {
    socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
}

relies_on(){
    local containers=$@

    for container in $containers; do
        local state=$(docker inspect --format "{{.State.Running}}" $container 2>/dev/null)

        if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
            echo "$container is not running, starting it for you."
            $container
        fi
    done
}

tor() {
    setDockerVM graphical
    del_stopped tor-browser
    docker run -it \
        -e DISPLAY=192.168.99.1:0 \
        --name tor-browser \
        jess/tor-browser
}

#!/bin/bash

createJavaVM() {
    docker-machine create -d virtualbox \
        --virtualbox-hostonly-cidr "192.168.98.1/24" \
        --virtualbox-cpu-count "2" \
        --virtualbox-disk-size "10000" \
        --virtualbox-memory "4096" java

    maven_data
}

#replace maven command line by a containerized maven
mvn() {
    setDockerVM java
    docker run --rm \
      -v $(pwd):/project \
      -m 1024m \
      --volumes-from maven_data \
      dirichlet/maven $*

  growlnotify --image "$HOME/Pictures/fourreTout/photocircle512.png" \
    -t "Maven" -m "Build finished"
}

maven_data() {
    setDockerVM java
    docker run --name maven_data \
        -v /root/.m2 \
        busybox echo 'data for maven'
}

netbeans() {
    setDockerVM java
    del_stopped netbeans

    docker run -ti --rm \
           -e DISPLAY=192.168.98.1:0 \
           -m 3072m \
           -v $HOME/dotfiles/.netbeans-docker:/root/.netbeans \
           -v $(pwd):/workspace \
           --volumes-from maven_data \
           --name netbeans \
           dirichlet/netbeans
}

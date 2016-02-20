#!/bin/bash
# Go to go folder just for the fun of it!
function setgo() {
    # GO environment
    export GO_HOME=/usr/local/go
    export PATH=${GO_HOME}/bin:${PATH}

    # GO Workspace
    export GOPATH=${HOME}/go
    export PATH=${GOPATH}/bin:${PATH}

    alias gogo="cd ${GOPATH}"
    alias gocaddy="cd ${GOPATH}/src/github.com/mholt/caddy"
    function gop() {
        cd ${GOPATH}/src/$1
    }
    function gomyp() {
        cd ${GOPATH}/src/github.com/evermax/$1
    }

    # goapp
    export GO_APP_HOME=${HOME}/bin/go_appengine
    export PATH=${GO_APP_HOME}:${PATH}

    echo "Go environment set up!"
}

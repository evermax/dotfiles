#!/bin/bash
dpsql() {
    setDockerVM server
    del_stopped psql

    docker run -d \
        -e POSTGRES_PASSWORD=$DBPASSWORD \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        --volumes-from mysql_data \
        --name psql \
        postgres
}

connpsql() {
    setDockerVM server
    docker run -it \
        --link psql:postgres \
        --rm postgres \
        sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
}

psql_data() {
    setDockerVM server
    docker create -v /var/lib/postgresql/data/pgdata --name psql_data busybox
}

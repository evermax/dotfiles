#!/bin/bash
dmysql() {
    setDockerVM server
    del_stopped mysql

    docker run -d \
        -e MYSQL_ROOT_PASSWORD=$DBPASSWORD \
        --volumes-from mysql_data \
        --name mysql \
        mysql/mysql-server
}

conndmysql() {
    setDockerVM server
    docker run -it \
        --link mysql \
        --rm mysql/mysql-server \
        sh -c 'exec mysql -h "$MYSQL_PORT_3306_TCP_ADDR" -P "$MYSQL_PORT_3306_TCP_PORT" -u root -p '
}

mysql_data() {
    setDockerVM server
    docker create --name mysql_data -v /var/lib/mysql busybox
}

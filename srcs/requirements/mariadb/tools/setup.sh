#!/bin/bash
    service mariadb start

    mariadb -u root -e \
        "CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE}; \
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}'; \
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%'; \
        FLUSH PRIVILEGES;"

    mysqladmin -u root password '${MARIADB_ROOT_PASSWORD}'
    mariadb -u root -e "FLUSH PRIVILEGES;"
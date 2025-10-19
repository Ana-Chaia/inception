FROM debian:bullseye
ARG HOST_UID
ARG HOST_GID
# Install mariadb environment
RUN apt update && apt upgrade -y && apt install mariadb-server -y && rm -rf /var/lib/apt/lists/*
# Modify the existing mysql user and group to match the host's UID/GID
RUN groupmod -g ${HOST_GID} mysql \
    && usermod -u ${HOST_UID} -g ${HOST_GID} mysql \
    && chown -R mysql:mysql /var/lib/mysql
# Update configuration file
COPY /conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# Set permissions for the configuration file
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf
# Copy the script to configure MariaDB users and password
COPY /tools/setup.sh /tmp/
RUN chmod +x /tmp/setup.sh && bash /tmp/setup.sh
# Expose port 3306 for MariaDB
EXPOSE 3306
# Set the entry point to run the configuration script
ENTRYPOINT ["mysqld_safe"]
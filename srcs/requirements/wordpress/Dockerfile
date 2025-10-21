FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && apt install php7.4\
    php7.4-fpm php7.4-mysql curl\
    php-common php7.4-cli php7.4-common php7.4-redis \
    php7.4-json php7.4-opcache php7.4-readline \
    php7.4-mbstring php7.4-xml redis php-redis \
    php7.4-gd php7.4-curl mariadb-client sendmail \
    libfcgi-bin -y && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on the network
RUN mkdir -p /run/php && \
    sed -i "s/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/" /etc/php/7.4/fpm/pool.d/www.conf

# Set the default working directory
WORKDIR /var/www/html

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xvzf latest.tar.gz --strip-components=1 && \
    rm -rf latest.tar.gz

# Copy the initialization script
COPY ./tools/installwp.sh /tmp/installwp.sh
RUN chmod +x /tmp/installwp.sh

# Expose the PHP-FPM port
EXPOSE 9000

# Set the entry point to run the configuration script
CMD ["/tmp/installwp.sh"]
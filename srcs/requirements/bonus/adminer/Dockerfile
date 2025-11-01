FROM debian:oldstable

# Install necessary packages including PHP and PHP-FPM
RUN apt-get update && apt upgrade -y && \
    apt-get install -y curl less \
    php php-fpm php-common \
    php-gd php-curl \
    php-xml php-mysql \
    php-imap php-pdo \
    php-soap php-ldap \
    php-ctype php-dom \
    php-mbstring php-zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the /var/www/html directory
RUN mkdir -p /var/www/html

# Create the /run/php directory
RUN mkdir -p /run/php

# Download Adminer and set permissions
RUN curl -L -o /var/www/html/index.php https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1-mysql.php && \
    chown www-data:www-data /var/www/html/index.php

# Copy PHP-FPM configuration file
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Set the stop signal to SIGQUIT for graceful shutdown
STOPSIGNAL SIGQUIT

# Start PHP-FPM in the foreground
CMD ["php-fpm8.2", "--nodaemonize"]
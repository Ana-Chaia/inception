FROM debian:bullseye
LABEL maintainer="Ana Chaia"
LABEL project="Inception"

RUN apt-get update && apt-get upgrade -y && apt install php7.4\
    php7.4-fpm php7.4-mysql curl\
    php-common php7.4-cli php7.4-common php7.4-redis \
    php7.4-json php7.4-opcache php7.4-readline \
    php7.4-mbstring php7.4-xml redis php-redis \
    php7.4-gd php7.4-curl mariadb-client sendmail -y && rm -rf /var/lib/apt/lists/*

# Configura o PHP-FPM para escutar na rede
RUN mkdir -p /run/php && \
    sed -i "s/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/" /etc/php/7.4/fpm/pool.d/www.conf

# Instala o wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Define o diretório de trabalho padrão
WORKDIR /var/www/wordpress

# Copia o script de inicialização
COPY ./tools/installwp.sh /tmp/installwp.sh
RUN chmod +x /tmp/installwp.sh

# Expõe a porta do PHP-FPM
EXPOSE 9000

# Define o ponto de entrada para executar o script de configuração
CMD ["/tmp/installwp.sh"]
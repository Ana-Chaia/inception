FROM debian:bullseye

#Install NGINX enviroment
RUN apt update && apt upgrade -y && apt install nginx openssl -y && rm -rf /var/lib/apt/lists/*

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-subj "/C=BR/ST=SP/L=São Paulo/O=42FR/OU=42SP/CN=anacaro5.42.fr" \
-keyout /etc/ssl/inception.key \
-out /etc/ssl/inception.crt


COPY conf/my_wp.conf /etc/nginx/conf.d/
COPY tools/wait.htm /var/www/html/wait.htm
COPY tools/logo.jpg /var/www/html/logo.jpg

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
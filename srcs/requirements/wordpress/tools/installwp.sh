#!/bin/bash
set -euo pipefail

WP_PATH=/var/www/html

# Garante que o diretório existe
mkdir -p "$WP_PATH"
cd "$WP_PATH"

# Espera o MariaDB ficar pronto para conexões
while ! mysqladmin ping -h"$MARIADB_HOST" --silent; do
    echo "Aguardando o MariaDB ficar disponível..."
    sleep 2
done

# Verifica se o WordPress já está configurado. Se não, instala tudo.
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Configurando o WordPress pela primeira vez..."

    # Cria o wp-config.php
    echo "Criando o wp-config.php..."
    wp --allow-root config create \
    --path="$WP_PATH" \
    --dbname="$MARIADB_DATABASE" \
    --dbuser="$MARIADB_USER" \
    --dbpass="$MARIADB_PASSWORD" \
    --dbhost="$MARIADB_HOST"

    # Instala o WordPress
    echo "Instalando o WordPress..."
    wp --allow-root core install \
    --path="$WP_PATH" \
    --url="$DOMAIN_NAME" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL"

    # Cria um usuário adicional
    echo "Criando usuário adicional do WordPress..."
    wp --allow-root user create \
    "$WP_USR" "$WP_EMAIL" --role="$WP_USER_ROLE" \
    --user_pass="$WP_PWD" --path="$WP_PATH"

    # Seta o tema padrão para Twenty Twenty-Four
    echo "Ativando o tema Twenty Twenty-Four..."
    wp --allow-root theme activate twentytwentyfour

    wp config set WP_REDIS_HOST $REDIS_HOST --allow-root
  	wp config set WP_REDIS_PORT $REDIS_PORT --raw --allow-root
 	wp config set WP_CACHE_KEY_SALT $DOMAIN_NAME --allow-root
  	wp config set WP_REDIS_PASSWORD $REDIS_PASSWORD --allow-root
 	wp config set WP_REDIS_CLIENT $REDIS_CLIENT --allow-root
	wp plugin install redis-cache --activate --allow-root
    wp plugin update --all --allow-root
	wp redis enable --allow-root

    echo "WordPress configurado com sucesso."
    touch "$WP_PATH/.wp_ready"
else
    echo "WordPress já está configurado."
    [ -f "$WP_PATH/.wp_ready" ] || touch "$WP_PATH/.wp_ready"
fi

echo "Iniciando o PHP-FPM..."
exec php-fpm7.4 -F
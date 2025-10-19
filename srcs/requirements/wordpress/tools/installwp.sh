#!/bin/bash
set -e # O script irá parar no primeiro erro

# Espera o MariaDB ficar pronto para conexões
while ! mysqladmin ping -h"$MARIADB_HOST" --silent; do
    echo "Aguardando o MariaDB ficar disponível..."
    sleep 2
done
# Muda para o diretório de trabalho correto
cd /var/www/wordpress

# Verifica se o WordPress já está configurado. Se não, instala tudo.
if [ ! -f "wp-config.php" ]; then
    echo "Configurando o WordPress pela primeira vez..."

    # Baixa os arquivos do WordPress. Isso garante que eles existam no volume.
    wp core download --allow-root

    # Cria o wp-config.php, especificando o --dbhost.
    # As variáveis ($MYSQL_DATABASE, etc.) vêm do seu arquivo .env
    wp config create --dbname="$MARIADB_DATABASE" --dbuser="$MARIADB_USER" \
        --dbpass="$MARIADB_PASSWORD" --dbhost="$MARIADB_HOST" --allow-root

    # Instala o WordPress (cria as tabelas no banco de dados)
    wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" --allow-root

    # Cria um usuário adicional
    wp user create "$WP_USR" "$WP_EMAIL" --role="$WP_USER_ROLE" --user_pass="$WP_PWD" --allow-root

    echo "WordPress configurado com sucesso."
    touch /var/www/wordpress/.wp_ready
else
    echo "WordPress já está configurado."
    [ -f /var/www/wordpress/.wp_ready ] || touch /var/www/wordpress/.wp_ready
fi

echo "Iniciando o PHP-FPM..."
# Inicia o PHP-FPM no primeiro plano para manter o contêiner em execução
exec php-fpm7.4 -F
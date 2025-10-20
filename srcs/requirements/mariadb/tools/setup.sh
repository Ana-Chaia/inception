#!/bin/bash

set -e # Faz o script parar se qualquer comando falhar

# Inicia o serviço MariaDB em background
service mariadb start

# --- ESPERA O SERVIÇO FICAR PRONTO ---
# Tenta se conectar repetidamente até que o servidor esteja aceitando conexões
until mariadb-admin ping --silent; do
    echo "Aguardando o serviço MariaDB iniciar..."
    sleep 2
done

echo "Serviço MariaDB iniciado. Configurando banco de dados e usuários..."

# --- EXECUTA OS COMANDOS DE CONFIGURAÇÃO ---
# Usa um "here document" (<<) para passar múltiplos comandos SQL de uma vez.
# Isso é mais limpo e seguro.
mariadb -u root <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';

    -- Aplica todas as mudanças
    FLUSH PRIVILEGES;
SQL

echo "Configuração do MariaDB concluída."

# Para o serviço que estava em background para que o CMD/ENTRYPOINT principal possa iniciá-lo em foreground
# Isso garante que o container não morra após o script terminar.
mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
exec mysqld_safe
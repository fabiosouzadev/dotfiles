#!/bin/bash
set -e

# Função auxiliar para rodar SQLs individuais no banco padrão (admin)
run_sql() {
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "$1"
}

# ------------------------------------------------------------
# 1. Hindsight: Criar Usuário, Banco e Extensão pgvector
# ------------------------------------------------------------
run_sql "CREATE USER hindsight WITH PASSWORD '${HINDSIGHT_POSTGRES_PASSWORD}';"
run_sql "CREATE DATABASE hindsight OWNER hindsight;"
run_sql "GRANT ALL PRIVILEGES ON DATABASE hindsight TO hindsight;"

# Ativar a extensão pgvector usando a conta superusuário (admin) no banco hindsight
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "hindsight" -c "CREATE EXTENSION IF NOT EXISTS vector;"

# Conceder permissões no schema public do banco hindsight
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "hindsight" -c "GRANT ALL ON SCHEMA public TO hindsight;"


# ------------------------------------------------------------
# 2. Synapse: Criar Usuário e Banco (com TEMPLATE template0 e Collation C)
# ------------------------------------------------------------
run_sql "CREATE USER synapse WITH PASSWORD '${SYNAPSE_POSTGRES_PASSWORD}';"
run_sql "CREATE DATABASE synapse WITH OWNER synapse TEMPLATE template0 LC_COLLATE = 'C' LC_CTYPE = 'C';"
run_sql "GRANT ALL PRIVILEGES ON DATABASE synapse TO synapse;"

# Conceder permissões no schema public do banco synapse
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "synapse" -c "GRANT ALL ON SCHEMA public TO synapse;"
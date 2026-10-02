#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 1. Criar usuário e banco do Hindsight usando variáveis de ambiente
    CREATE USER hindsight WITH PASSWORD '${HINDSIGHT_POSTGRES_PASSWORD}';
    CREATE DATABASE hindsight OWNER hindsight;
    GRANT ALL PRIVILEGES ON DATABASE hindsight TO hindsight;

    -- 2. Criar usuário e banco do Synapse usando variáveis de ambiente
    CREATE USER synapse WITH PASSWORD '${SYNAPSE_POSTGRES_PASSWORD}';
    CREATE DATABASE synapse OWNER synapse;

    -- 3. Configurações de collation para o Synapse
    ALTER DATABASE synapse SET LC_COLLATE TO 'C';
    ALTER DATABASE synapse SET LC_CTYPE TO 'C';
    GRANT ALL PRIVILEGES ON DATABASE synapse TO synapse;
EOSQL
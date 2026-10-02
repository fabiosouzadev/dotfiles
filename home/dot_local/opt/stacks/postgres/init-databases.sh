#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 1. Criar usuário e banco do Hindsight
    CREATE USER hindsight WITH PASSWORD '${HINDSIGHT_POSTGRES_PASSWORD}';
    CREATE DATABASE hindsight OWNER hindsight;
    GRANT ALL PRIVILEGES ON DATABASE hindsight TO hindsight;

    -- 2. Criar usuário e banco do Synapse (com o collation C correto na criação)
    CREATE USER synapse WITH PASSWORD '${SYNAPSE_POSTGRES_PASSWORD}';
    CREATE DATABASE synapse WITH OWNER synapse LC_COLLATE = 'C' LC_CTYPE = 'C';
    GRANT ALL PRIVILEGES ON DATABASE synapse TO synapse;
EOSQL
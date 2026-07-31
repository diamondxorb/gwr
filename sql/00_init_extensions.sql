-- Executado automaticamente na primeira subida do container
-- (montado em /docker-entrypoint-initdb.d via docker-compose.yml)

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Schemas para organizar por origem de dado
CREATE SCHEMA IF NOT EXISTS raw;        -- dados crus importados (imóveis, OSM)
CREATE SCHEMA IF NOT EXISTS features;   -- features espaciais processadas
CREATE SCHEMA IF NOT EXISTS analysis;   -- tabelas/views de apoio à análise

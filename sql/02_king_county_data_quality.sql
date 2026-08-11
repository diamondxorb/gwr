-- Auditoria de qualidade de dados do King County House Sales (issue #9).
-- Consultas somente leitura — não alteram a tabela, servem de relatório.

-- 1) Geometria inválida (nas duas colunas de geometria)
SELECT 'geometria_invalida' AS checagem,
       count(*) FILTER (WHERE NOT ST_IsValid(geometry)) AS geometry_invalida,
       count(*) FILTER (WHERE NOT ST_IsValid(geom_metric)) AS geom_metric_invalida
FROM raw.king_county_house_sales;

-- 2) Duplicatas exatas (todas as colunas de negócio idênticas)
SELECT 'linhas_duplicadas_exatas' AS checagem, count(*) AS total
FROM (
    SELECT id, date, price, bedrooms, bathrooms, sqft_living, sqft_lot, floors,
           waterfront, view, condition, grade, sqft_above, sqft_basement,
           yr_built, yr_renovated, zipcode, lat, long
    FROM raw.king_county_house_sales
    GROUP BY id, date, price, bedrooms, bathrooms, sqft_living, sqft_lot, floors,
             waterfront, view, condition, grade, sqft_above, sqft_basement,
             yr_built, yr_renovated, zipcode, lat, long
    HAVING count(*) > 1
) duplicadas;

-- 3) Mesmo imóvel (id) vendido mais de uma vez no MESMO dia — isso sim é suspeito
-- (vendido em dias diferentes é revenda legítima, comum no dataset)
SELECT 'mesmo_id_mesma_data' AS checagem, count(*) AS total
FROM (
    SELECT id, date, count(*) AS n
    FROM raw.king_county_house_sales
    GROUP BY id, date
    HAVING count(*) > 1
) t;

-- 4) Quantos imóveis (id) aparecem mais de uma vez no dataset (revendas — informativo, não é erro)
SELECT 'ids_com_mais_de_uma_venda' AS checagem, count(*) AS total
FROM (
    SELECT id FROM raw.king_county_house_sales GROUP BY id HAVING count(*) > 1
) t;

-- 5) Preços inválidos (<= 0)
SELECT 'preco_invalido' AS checagem, count(*) AS total
FROM raw.king_county_house_sales
WHERE price <= 0;

-- 6) Outliers de preço via IQR (Q1 - 1.5*IQR, Q3 + 1.5*IQR)
WITH stats AS (
    SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY price) AS q1,
           percentile_cont(0.75) WITHIN GROUP (ORDER BY price) AS q3
    FROM raw.king_county_house_sales
)
SELECT 'outliers_preco_iqr' AS checagem,
       count(*) AS total,
       round(min(stats.q1 - 1.5 * (stats.q3 - stats.q1))::numeric, 2) AS limite_inferior,
       round(max(stats.q3 + 1.5 * (stats.q3 - stats.q1))::numeric, 2) AS limite_superior
FROM raw.king_county_house_sales, stats
WHERE price < stats.q1 - 1.5 * (stats.q3 - stats.q1)
   OR price > stats.q3 + 1.5 * (stats.q3 - stats.q1);

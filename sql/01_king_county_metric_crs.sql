-- Reprojeta a geometria do King County House Sales para um CRS métrico local.
-- EPSG:32610 (WGS 84 / UTM zone 10N) cobre toda a região de Seattle/King County
-- com baixa distorção — necessário para ST_Distance/ST_DWithin em metros (Epic 3).
-- A coluna original `geometry` (SRID 4326) é mantida para mapas/visualização.

ALTER TABLE raw.king_county_house_sales
    ADD COLUMN IF NOT EXISTS geom_metric geometry(Point, 32610);

UPDATE raw.king_county_house_sales
SET geom_metric = ST_Transform(geometry, 32610)
WHERE geom_metric IS NULL;

ALTER TABLE raw.king_county_house_sales
    ALTER COLUMN geom_metric SET NOT NULL;

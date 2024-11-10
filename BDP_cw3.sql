CREATE EXTENSION if not exists postgis;

--zad1

-- wczytanie danych:
-- .\shp2pgsql.exe -I "C:\Users\karol\Downloads\Karlsruhe_Germany_Shapefile\T2018_KAR_GERMANY\T2018_KAR_BUILDINGS.shp" public.buildings2018 | .\psql -h localhost -p 5432 -U postgres -d BDP3
-- .\shp2pgsql.exe -I "C:\Users\karol\Downloads\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_BUILDINGS.shp" public.buildings2019 | .\psql -h localhost -p 5432 -U postgres -d BDP3

--nowe budynki (brak danego polygon_id z tabeli buildings2019 w buildings2018)
DROP TABLE IF EXISTS new_modified_buildings;

CREATE TABLE new_modified_buildings AS
SELECT
    b2019.polygon_id,
    'New building' AS change_type,
    b2019.height AS height_2019,
    NULL AS height_2018,
    b2019.geom AS geom_2019,
    NULL AS geom_2018
FROM
    buildings2019 b2019
LEFT JOIN
    buildings2018 b2018 ON b2019.polygon_id = b2018.polygon_id
WHERE
    b2018.polygon_id IS NULL

UNION ALL

-- wyremontowane budynki (zmiana w kolumnie height lub geometry)
SELECT
    b2019.polygon_id,
    'Modified building' AS change_type,
    b2019.height AS height_2019,
    b2018.height AS height_2018,
    b2019.geom AS geome_2019,
    b2018.geom AS geom_2018
FROM
    buildings2019 b2019
JOIN
    buildings2018 b2018 ON b2019.polygon_id = b2018.polygon_id
WHERE
    (b2019.height IS DISTINCT FROM b2018.height)
    OR
    (b2019.geom IS DISTINCT FROM b2018.geom);


--zad2
-- znalezienie punktów (z tabeli points2019), które znajdują się w odległości 500m od nowych i wyremontowanych budynków (tabela new_modified_buildings)

DROP TABLE IF EXISTS points500;
CREATE TABLE points500 AS
SELECT p.poi_id, p.geom, p.type, COUNT(DISTINCT p.geom) AS unique_points_count
FROM points2019 p
JOIN new_modified_buildings b ON ST_DWithin(p.geom, b.geom_2019, 0.005)
GROUP BY p.poi_id, p.geom, p.type;


SELECT type, COUNT(*) AS type_count
FROM points500
GROUP BY type
ORDER BY type_count DESC;


-- zad3

-- wczytanie danych:
-- .\shp2pgsql.exe -I -s 3068 "C:\Users\karol\Downloads\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_STREETS.shp" public.streets_reprojected | .\psql -h localhost -p 5432 -U postgres -d BDP3

UPDATE streets_reprojected
SET geom = ST_Transform(geom, 3068);

-- zad 4

DROP TABLE IF EXISTS input_points;
CREATE TABLE input_points  
(  
    id int NOT NULL,  
    geom geometry,  
); 

INSERT INTO input_points (id, geom, name) VALUES (1, ST_GeomFromText('POINT( 8.36093  49.03174)'));
INSERT INTO input_points (id, geom, name) VALUES (2, ST_GeomFromText('POINT(8.39876 49.00644)'));

-- zad5

-- wczytanie danych:
-- .\shp2pgsql.exe -I -s 3068 "C:\Users\karol\Downloads\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_STREET_NODE.shp" public.streets_nodes | .\psql -h localhost -p 5432 -U postgres -d BDP3

UPDATE input_points
SET geom = ST_SetSRID(geom, 3068)
WHERE ST_SRID(geom) = 0;

--zad 6


select * from streets_nodes;

UPDATE streets_nodes
SET geom = ST_SetSRID(geom, 3068);


SELECT sn.*
FROM streets_nodes sn
JOIN (
    SELECT ST_MakeLine(geom ORDER BY id) AS line_geom
    FROM input_points
) AS line
ON ST_DWithin(sn.geom, line.line_geom, 0.002);


-- zad7
-- wczytanie danych:
-- .\shp2pgsql.exe -I "C:\Users\karol\Downloads\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_LAND_USE_A.shp" public.parks | .\psql -h localhost -p 5432 -U postgres -d BDP3

SELECT COUNT(*)
FROM points2019 p
JOIN parks pr ON ST_DWithin(p.geom, pr.geom, 0.003)
WHERE p.type = 'Sporting Goods Store';

-- zad 8

-- pobranie danych do tabeli railways i water:
-- .\shp2pgsql.exe -I "C:\Users\karol\Downloads\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_RAILWAYS.shp" public.railways | .\psql -h localhost -p 5432 -U postgres -d BDP3
-- .\shp2pgsql.exe -I "C:\Users\karol\Downloads\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_WATER_LINES.shp" public.water | .\psql -h localhost -p 5432 -U postgres -d BDP3


DROP TABLE IF EXISTS T2019_KAR_BRIDGES;

CREATE TABLE T2019_KAR_BRIDGES (
    id serial PRIMARY KEY,
    geom geometry(Point) 
);

-- znalezienie punktów przecięcia geometrii z tabel railways i water
INSERT INTO T2019_KAR_BRIDGES (geom)
SELECT ST_Intersection(r.geom, w.geom)
FROM railways r
JOIN water w
ON ST_Intersects(r.geom, w.geom)
WHERE ST_GeometryType(ST_Intersection(r.geom, w.geom)) = 'ST_Point'; 


--select * from T2019_KAR_BRIDGES
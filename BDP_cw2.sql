create extension postgis;

--zad4
CREATE TABLE buildings  
(  
    id int NOT NULL,  
    geometry geometry,  
    name varchar(50)  
); 

CREATE TABLE roads  
(  
    id int NOT NULL,  
    geometry geometry,  
    name varchar(50)  
); 

CREATE TABLE poi  
(  
    id int NOT NULL,  
    geometry geometry,  
    name varchar(50)  
); 

-- zad 5
INSERT INTO roads (id, geometry, name) VALUES (1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX');
INSERT INTO roads (id, geometry, name) VALUES (2, ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)'), 'RoadY');

INSERT INTO buildings (id, geometry, name) VALUES (1, ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))'), 'BuildingA');
INSERT INTO buildings (id, geometry, name) VALUES (2, ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))'), 'BuildingB');
INSERT INTO buildings (id, geometry, name) VALUES (3, ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))'), 'BuildingC');
INSERT INTO buildings (id, geometry, name) VALUES (4, ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))'), 'BuildingD');
INSERT INTO buildings (id, geometry, name) VALUES (5, ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 'BuildingF');

INSERT INTO poi (id, geometry, name) VALUES (1, ST_GeomFromText('POINT(1 3.5)'), 'G');
INSERT INTO poi (id, geometry, name) VALUES (2, ST_GeomFromText('POINT(5.5 1.5)'), 'H');
INSERT INTO poi (id, geometry, name) VALUES (3, ST_GeomFromText('POINT(9.5 6)'), 'I');
INSERT INTO poi (id, geometry, name) VALUES (4, ST_GeomFromText('POINT(6.5 6)'), 'J');
INSERT INTO poi (id, geometry, name) VALUES (5, ST_GeomFromText('POINT(6 9.5)'), 'K');

--select * from poi

--zad 6a
SELECT sum(st_length(geometry)) FROM roads

--zad 6b
SELECT 
    ST_AsText(geometry) AS geometry_wkt,
    ST_Area(geometry) AS area,
    ST_Perimeter(geometry) AS perimeter
FROM buildings
WHERE name = 'BuildingA';

--zad 6c
SELECT 
    name, 
    ST_Area(geometry) AS area
FROM buildings
ORDER BY name;


--zad 6d
SELECT 
    name, 
    ST_Perimeter(geometry) AS perimeter
FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2;


--zad 6e
SELECT 
    ST_Distance(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        (SELECT geometry FROM poi WHERE name = 'K')
    ) AS shortest_distance;

--zad 6f
SELECT 
    ST_Area(ST_Difference(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        ST_Buffer((SELECT geometry FROM buildings WHERE name = 'BuildingB'), 0.5)
    )) AS area_outside_buffer;

--zad 6g
SELECT 
    name
FROM buildings
WHERE ST_Y(ST_Centroid(geometry)) > 
      (SELECT ST_Y(ST_Centroid(geometry)) FROM roads WHERE name = 'RoadX');

--zad 6h
SELECT 
    ST_Area(ST_Difference(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
    )) AS not_shared;


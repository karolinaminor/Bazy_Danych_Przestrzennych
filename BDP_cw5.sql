create extension if not exists postgis;

DROP TABLE IF EXISTS obiekty;
CREATE TABLE obiekty (
    id SERIAL PRIMARY KEY,        
    geometry GEOMETRY NOT NULL,   
    name VARCHAR(50)              
);

-- OBIEKT 1

INSERT INTO obiekty (geometry, name)
VALUES (
    ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(0 1, 1 1)'),
        ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)'),
        ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)'),
        ST_GeomFromText('LINESTRING(5 1, 6 1)')
    ]),
    'obiekt1'
);

-- OBIEKT 2

WITH circle AS (
    SELECT 
        ST_Buffer(ST_MakePoint(12, 2), 1) AS circle_geom
)

INSERT INTO obiekty (geometry, name)
VALUES (
    (SELECT ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(10 6, 14 6)'),
        ST_GeomFromText('CIRCULARSTRING(14 6, 16 4, 14 2)'),
        ST_GeomFromText('CIRCULARSTRING(14 2, 12 0, 10 2)'),
        ST_GeomFromText('LINESTRING(10 2, 10 6)'),
        circle_geom
    ]) FROM circle),
    'obiekt2'
);

-- OBIEKT 3

INSERT INTO obiekty (geometry, name)
VALUES (
    ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))'),
    'obiekt3'
);


-- OBIEKT 4

INSERT INTO obiekty (geometry, name)
VALUES (
    ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(20 20, 25 25)'),
        ST_GeomFromText('LINESTRING(25 25, 27 24)'),
        ST_GeomFromText('LINESTRING(27 24, 25 22)'),
        ST_GeomFromText('LINESTRING(25 22, 26 21)'),
        ST_GeomFromText('LINESTRING(26 21, 22 19)'),
        ST_GeomFromText('LINESTRING(22 19, 20.5 19.5)')
    ]),
    'obiekt4'
);

-- OBIEKT 5

INSERT INTO obiekty (geometry, name)
VALUES (
    ST_Collect(
        ST_SetSRID(ST_MakePoint(30, 30,59), 0),
        ST_SetSRID(ST_MakePoint(38, 32, 234), 0)  
    ),
    'obiekt5'
);


-- OBIEKT 6

INSERT INTO obiekty (geometry, name)
VALUES (
    ST_Collect(
        ARRAY[
            ST_GeomFromText('LINESTRING(1 1, 3 2)'),
            ST_MakePoint(4, 2)
        ]
    ),
    'obiekt6'
);


-- zadanie 2

SELECT 
    ST_Area(ST_Buffer(ST_ShortestLine(obiekt3.geometry, obiekt4.geometry), 5)) AS buffer_area
FROM 
    (SELECT geometry FROM obiekty WHERE name = 'obiekt3') AS obiekt3,
    (SELECT geometry FROM obiekty WHERE name = 'obiekt4') AS obiekt4;


-- zadanie 3

SELECT ST_GeometryType(geometry) AS geometry_type
FROM obiekty
WHERE name = 'obiekt4';


WITH closed_line AS (
    SELECT 
        ST_MakePolygon(
            ST_AddPoint(
                ST_LineMerge(geometry), 
                ST_StartPoint(ST_LineMerge(geometry))
            )
        ) AS closed_geometry
    FROM obiekty
    WHERE name = 'obiekt4'
)
UPDATE obiekty
SET geometry = closed_geometry
FROM closed_line
WHERE obiekty.name = 'obiekt4';



SELECT ST_GeometryType(geometry) AS geometry_type
FROM obiekty
WHERE name = 'obiekt4';


-- zadanie 4

INSERT INTO obiekty (geometry, name)
SELECT 
    ST_Union(obj3.geometry, obj4.geometry) AS geometry_union,
    'obiekt7' AS name
FROM obiekty obj3, obiekty obj4
WHERE obj3.name = 'obiekt3' AND obj4.name = 'obiekt4';


-- zadanie 5

DROP TABLE IF EXISTS non_arc_objects;
CREATE TEMP TABLE non_arc_objects AS
SELECT 
    id,
    geometry,
    name
FROM obiekty
WHERE NOT ST_HasArc(geometry);

ALTER TABLE non_arc_objects
ADD COLUMN buffer_area DOUBLE PRECISION;


UPDATE non_arc_objects
SET 
    buffer_area = ST_Area(ST_Buffer(geometry, 5)); 

SELECT 
    SUM(buffer_area) AS total_buffer_area
FROM non_arc_objects;


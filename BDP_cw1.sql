DROP TABLE IF EXISTS pracownicy CASCADE;
DROP TABLE IF EXISTS godziny CASCADE;
DROP TABLE IF EXISTS pensja CASCADE;
DROP TABLE IF EXISTS premia CASCADE;
DROP TABLE IF EXISTS wynagrodzenie CASCADE;

CREATE TABLE pracownicy (
    id_pracownika SERIAL PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    adres VARCHAR(100),
    telefon VARCHAR(15)
);

COMMENT ON TABLE pracownicy IS 'Tabela przechowująca dane o pracownikach, w tym dane osobowe i kontaktowe';

CREATE TABLE godziny (
    id_godziny SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    liczba_godzin SMALLINT NOT NULL,
    id_pracownika INT NOT NULL,
    CONSTRAINT fk_pracownik_godziny FOREIGN KEY (id_pracownika) REFERENCES pracownicy (id_pracownika)
);

COMMENT ON TABLE godziny IS 'Tabela przechowująca dane o przepracowanych godzinach przez pracowników';

CREATE TABLE pensja (
    id_pensji SERIAL PRIMARY KEY,
    stanowisko VARCHAR(50) NOT NULL,
    kwota NUMERIC(10, 2) NOT NULL
);

COMMENT ON TABLE pensja IS 'Tabela przechowująca dane o pensjach przypisanych do stanowisk';

CREATE TABLE premia (
    id_premii SERIAL PRIMARY KEY,
    rodzaj VARCHAR(50) NOT NULL,
    kwota NUMERIC(10, 2) NOT NULL
);

COMMENT ON TABLE premia IS 'Tabela przechowująca dane o różnych rodzajach premii';

CREATE TABLE wynagrodzenie (
    id_wynagrodzenia SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    id_pracownika INT NOT NULL,
    id_godziny INT NOT NULL,
    id_pensji INT NOT NULL,
    id_premii INT,
    CONSTRAINT fk_pracownik_wynagrodzenie FOREIGN KEY (id_pracownika) REFERENCES pracownicy (id_pracownika),
    CONSTRAINT fk_godziny_wynagrodzenie FOREIGN KEY (id_godziny) REFERENCES godziny (id_godziny),
    CONSTRAINT fk_pensja_wynagrodzenie FOREIGN KEY (id_pensji) REFERENCES pensja (id_pensji),
    CONSTRAINT fk_premia_wynagrodzenie FOREIGN KEY (id_premii) REFERENCES premia (id_premii)
);

--COMMENT ON TABLE wynagrodzenie IS 'Tabela przechowująca dane o wynagrodzeniach (godziny, pensja i premie)';

-- 2 wypełnienie tabel rekordami
INSERT INTO pracownicy (imie, nazwisko, adres, telefon) VALUES
('Jan', 'Kowalski', 'ul. Zielona 5, Kraków', '123456789'),
('Anna', 'Nowak', 'ul. Słoneczna 10, Warszawa', '987654321'),
('Piotr', 'Wiśniewski', 'ul. Kwiatowa 3, Gdańsk', '456789123'),
('Maria', 'Kamińska', 'ul. Lipowa 7, Poznań', '789123456'),
('Krzysztof', 'Krawczyk', 'ul. Wrocławska 1, Wrocław', '321654987'),
('Karolina', 'Minor', 'ul. Ogrodowa 9, Łódź', '654987321'),
('Adam', 'Mazur', 'ul. Górska 2, Zakopane', '987321654'),
('Katarzyna', 'Dąbrowska', 'ul. Różana 8, Szczecin', '147258369'),
('Michał', 'Wojciechowski', 'ul. Szewska 4, Kraków', '963852741'),
('Agnieszka', 'Krawczyk', 'ul. Tęczowa 6, Opole', '852741963');

INSERT INTO godziny (data, liczba_godzin, id_pracownika) VALUES
('2024-10-01', 8, 1),
('2024-10-01', 6, 2),
('2024-10-02', 8, 3),
('2024-10-02', 9, 4),
('2024-10-03', 8, 5),
('2024-10-03', 8, 6),
('2024-10-04', 8, 7),
('2024-10-04', 8, 8),
('2024-10-05', 9, 9),
('2024-10-05', 7, 10);

INSERT INTO pensja (stanowisko, kwota) VALUES
('Kierownik', 10000.00),
('Asystent', 6500.00),
('Specjalista', 5500.00),
('Analityk', 6000.00),
('Pracownik fizyczny', 1400.00),
('Technik', 5000.00),
('Administrator', 5800.00),
('Menedżer', 7200.00),
('Inżynier', 16500.00),
('Księgowy', 2900.00);

INSERT INTO premia (rodzaj, kwota) VALUES
('Świąteczna', 1000.00),
('Roczna', 2000.00),
('Motywacyjna', 1500.00),
('Za nadgodziny', 500.00),
('Specjalna', 2500.00),
('Okolicznościowa', 1200.00),
('Urodzinowa', 1800.00),
('Uznaniowa', 800.00),
('Lojalnościowa', 2200.00),
('Okresowa', 1300.00);

INSERT INTO wynagrodzenie (data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
('2024-10-01', 1, 1, 1, 1),
('2024-10-01', 2, 2, 2, 2),
('2024-10-02', 3, 3, 3, 8),
('2024-10-02', 4, 4, 4, 4),
('2024-10-03', 5, 5, 5, 4),
('2024-10-03', 6, 6, 6, 6),
('2024-10-04', 7, 7, 7, 2),
('2024-10-04', 8, 8, 8, 8),
('2024-10-05', 9, 9, 9, 9),
('2024-10-05', 10, 10, 10, 5);


SELECT DISTINCT w.id_pracownika, p.kwota
FROM wynagrodzenie w
JOIN pensja p ON w.id_pensji = p.id_pensji
WHERE p.kwota > 1000;

SELECT DISTINCT w.id_pracownika, p.kwota
FROM wynagrodzenie w
JOIN pensja p ON w.id_pensji = p.id_pensji
WHERE w.id_premii IS NULL AND p.kwota > 2000;


-- wyświetl pracowników, których pierwsza litera imienia zaczyna się na literę ‘J’.  
-- wwyświetl pracowników, których nazwisko zawiera literę ‘n’ oraz imię kończy się na literę ‘a’. 
SELECT * FROM pracownicy WHERE imie LIKE 'J%';
SELECT * FROM pracownicy WHERE imie LIKE '%a' and nazwisko LIKE '%n%';


-- wyświetl imiona i nazwiska pracowników, których pensja jest w przedziale (1500, 3000) 
SELECT p.imie, p.nazwisko, pp.kwota
FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja pp ON w.id_pensji = pp.id_pensji
WHERE pp.kwota BETWEEN 1500 and 3000;


--  uszereguj pracowników według pensji malejąco
SELECT p.imie, p.nazwisko,ps.kwota
FROM pracownicy p
JOIN wynagrodzenie w ON w.id_pracownika=p.id_pracownika
JOIN pensja ps ON ps.id_pensji = w.id_pensji
order by ps.kwota DESC;


--  uszereguj pracowników według pensji i premii malejąco
SELECT 
    p.imie, 
    p.nazwisko, 
    ps.kwota AS pensja, 
    COALESCE(pr.kwota, 0) AS premia,
    (ps.kwota + COALESCE(pr.kwota, 0)) AS lacznie
FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja ps ON w.id_pensji = ps.id_pensji
LEFT JOIN premia pr ON w.id_premii = pr.id_premii
ORDER BY (ps.kwota + COALESCE(pr.kwota, 0)) DESC;


-- policz i pogrupuj pracowników według pola ‘stanowisko’
SELECT 
    ps.stanowisko, 
    COUNT(p.id_pracownika) AS liczba_pracownikow
FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja ps ON w.id_pensji = ps.id_pensji
GROUP BY ps.stanowisko
ORDER BY liczba_pracownikow DESC;


-- policz średnią, minimalną i maksymalną płacę dla stanowiska ‘kierownik’
SELECT 
    AVG(ps.kwota) AS srednia_pensja,
    MIN(ps.kwota) AS minimalna_pensja,
    MAX(ps.kwota) AS maksymalna_pensja
FROM pracownicy p
JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
JOIN pensja ps ON w.id_pensji = ps.id_pensji
WHERE p.stanowisko = 'Kierownik';


-- suma wynagrodzeń
SELECT 
    SUM(ps.kwota + COALESCE(pr.kwota, 0)) AS suma_wynagrodzen
FROM wynagrodzenie w
JOIN pensja ps ON w.id_pensji = ps.id_pensji
LEFT JOIN premia pr ON w.id_premii = pr.id_premii;


-- suma wynagrodzeń według danego stanowiska
SELECT 
    ps.stanowisko,
    SUM(ps.kwota + COALESCE(pr.kwota, 0)) AS suma_wynagrodzen
FROM wynagrodzenie w
JOIN pensja ps ON w.id_pensji = ps.id_pensji
LEFT JOIN premia pr ON w.id_premii = pr.id_premii
GROUP BY ps.stanowisko
ORDER BY suma_wynagrodzen DESC;


-- usuwanie pracowników z pensją mniejszą od 1200
DELETE FROM pracownicy
WHERE id_pracownika IN (
    SELECT p.id_pracownika
    FROM pracownicy p
    JOIN wynagrodzenie w ON p.id_pracownika = w.id_pracownika
    JOIN pensja ps ON w.id_pensji = ps.id_pensji
    WHERE ps.kwota < 1200
);




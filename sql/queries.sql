SELECT ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements;

SELECT MAX(aqi) AS aqi_maximum
FROM aqi_measurements;

SELECT MIN(aqi) AS aqi_minimum
FROM aqi_measurements;

SELECT COUNT(*) AS total_mesures
FROM aqi_measurements;

SELECT COUNT(DISTINCT city) AS nb_villes
FROM aqi_measurements;

SELECT
    DATE_TRUNC('month', date)::DATE AS mois,
    ROUND(AVG(aqi), 1)              AS aqi_moyen
FROM aqi_measurements
GROUP BY DATE_TRUNC('month', date)
ORDER BY mois;

SELECT
    city,
    country,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
GROUP BY city, country
ORDER BY aqi_moyen DESC;

SELECT
    city,
    country,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
GROUP BY city, country
ORDER BY aqi_moyen DESC
LIMIT 10;

SELECT
    category,
    COUNT(*)                    AS nb_jours,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pourcentage
FROM aqi_measurements
GROUP BY category
ORDER BY MIN(aqi);

SELECT
    EXTRACT(YEAR FROM date)::INT AS annee,
    ROUND(AVG(pm25), 2) AS pm25,
    ROUND(AVG(pm10), 2) AS pm10,
    ROUND(AVG(no2),  2) AS no2,
    ROUND(AVG(so2),  2) AS so2,
    ROUND(AVG(co),   2) AS co,
    ROUND(AVG(o3),   2) AS o3
FROM aqi_measurements
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY annee;

SELECT
    EXTRACT(YEAR  FROM date)::INT AS annee,
    EXTRACT(MONTH FROM date)::INT AS mois,
    TO_CHAR(date, 'Month')        AS nom_mois,
    ROUND(AVG(aqi), 1)            AS aqi_moyen
FROM aqi_measurements
GROUP BY annee, mois, nom_mois
ORDER BY annee, mois;

SELECT
    city,
    country,
    ROUND(latitude,  4) AS latitude,
    ROUND(longitude, 4) AS longitude,
    ROUND(AVG(aqi), 1)  AS aqi_moyen,
    COUNT(*)            AS nb_mesures
FROM aqi_measurements
GROUP BY city, country, latitude, longitude
ORDER BY aqi_moyen DESC;

SELECT DISTINCT city
FROM aqi_measurements
ORDER BY city;

SELECT DISTINCT country
FROM aqi_measurements
ORDER BY country;

SELECT DISTINCT category
FROM aqi_measurements
ORDER BY category;

SELECT
    city,
    country,
    EXTRACT(YEAR FROM date)::INT AS annee,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
GROUP BY city, country, annee
ORDER BY city, annee;

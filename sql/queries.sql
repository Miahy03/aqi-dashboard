═══════════════════════════════════════════════════════════════
  BLOC 2 – AQI DASHBOARD : REQUÊTES SQL OPTIMISÉES
  Base : aqi_warehouse  |  Table : aqi_measurements
═══════════════════════════════════════════════════════════════

--------------------------------------------------------------------------
1. KPI – AQI MOYEN
--------------------------------------------------------------------------
SELECT ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements;

--------------------------------------------------------------------------
2. KPI – AQI MAXIMUM
--------------------------------------------------------------------------
SELECT MAX(aqi) AS aqi_maximum
FROM aqi_measurements;

--------------------------------------------------------------------------
3. KPI – AQI MINIMUM
--------------------------------------------------------------------------
SELECT MIN(aqi) AS aqi_minimum
FROM aqi_measurements;

--------------------------------------------------------------------------
4. KPI – NOMBRE TOTAL DE MESURES
--------------------------------------------------------------------------
SELECT COUNT(*) AS total_mesures
FROM aqi_measurements;

--------------------------------------------------------------------------
5. KPI – NOMBRE DE VILLES ANALYSÉES
--------------------------------------------------------------------------
SELECT COUNT(DISTINCT city) AS nb_villes
FROM aqi_measurements;

--------------------------------------------------------------------------
6. ÉVOLUTION DE L'AQI DANS LE TEMPS (courbe mensuelle)
--------------------------------------------------------------------------
SELECT
    DATE_TRUNC('month', date)::DATE AS mois,
    ROUND(AVG(aqi), 1)              AS aqi_moyen
FROM aqi_measurements
GROUP BY DATE_TRUNC('month', date)
ORDER BY mois;

--------------------------------------------------------------------------
7. AQI MOYEN PAR VILLE (bar chart horizontal)
--------------------------------------------------------------------------
SELECT
    city,
    country,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
GROUP BY city, country
ORDER BY aqi_moyen DESC;

--------------------------------------------------------------------------
8. TOP 10 DES VILLES LES PLUS POLLUÉES
--------------------------------------------------------------------------
SELECT
    city,
    country,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
GROUP BY city, country
ORDER BY aqi_moyen DESC
LIMIT 10;

--------------------------------------------------------------------------
9. RÉPARTITION DES CATÉGORIES AQI (donut)
--------------------------------------------------------------------------
SELECT
    category,
    COUNT(*)                    AS nb_jours,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pourcentage
FROM aqi_measurements
GROUP BY category
ORDER BY MIN(aqi);  -- ordre logique : Good → Hazardous

--------------------------------------------------------------------------
10. COMPARAISON DES PRINCIPAUX POLLUANTS (moyenne annuelle)
--------------------------------------------------------------------------
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

--------------------------------------------------------------------------
11. HEATMAP – MOIS LES PLUS POLLUÉS (moyenne AQI par mois/année)
--------------------------------------------------------------------------
SELECT
    EXTRACT(YEAR  FROM date)::INT AS annee,
    EXTRACT(MONTH FROM date)::INT AS mois,
    TO_CHAR(date, 'Month')        AS nom_mois,
    ROUND(AVG(aqi), 1)            AS aqi_moyen
FROM aqi_measurements
GROUP BY annee, mois, nom_mois
ORDER BY annee, mois;

--------------------------------------------------------------------------
12. CARTE GÉOGRAPHIQUE – AQI MOYEN PAR VILLE (avec coordonnées)
--------------------------------------------------------------------------
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

--------------------------------------------------------------------------
13. FILTRE : VILLE (pour Metabase – champ de filtre)
--------------------------------------------------------------------------
SELECT DISTINCT city
FROM aqi_measurements
ORDER BY city;

--------------------------------------------------------------------------
14. FILTRE : PAYS
--------------------------------------------------------------------------
SELECT DISTINCT country
FROM aqi_measurements
ORDER BY country;

--------------------------------------------------------------------------
15. FILTRE : CATÉGORIE AQI
--------------------------------------------------------------------------
SELECT DISTINCT category
FROM aqi_measurements
ORDER BY category;

--------------------------------------------------------------------------
16. AQI MOYEN PAR VILLE ET PAR ANNÉE (analyse croisée)
--------------------------------------------------------------------------
SELECT
    city,
    country,
    EXTRACT(YEAR FROM date)::INT AS annee,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
GROUP BY city, country, annee
ORDER BY city, annee;

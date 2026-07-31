-- =====================================================
-- Requêtes du dashboard AQI (16 cartes)
-- Variables filtres optionnelles : {{ville}}, {{pays}},
-- {{categorie}}, {{date_debut}}, {{date_fin}}
-- Les blocs [[ ... ]] sont ignorés si le filtre est vide.
-- =====================================================

-- 1. KPI : AQI Moyen
SELECT ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]];

-- 2. KPI : AQI Maximum
SELECT MAX(aqi) AS aqi_maximum
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]];

-- 3. KPI : AQI Minimum
SELECT MIN(aqi) AS aqi_minimum
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]];

-- 4. KPI : Nombre total de mesures
SELECT COUNT(*) AS total_mesures
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]];

-- 5. KPI : Nombre de villes analysées
SELECT COUNT(DISTINCT city) AS nb_villes
FROM aqi_measurements
WHERE 1=1
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]];

-- 6. KPI : Polluant dominant
WITH avg_polluants AS (
  SELECT AVG(pm25) AS pm25, AVG(pm10) AS pm10, AVG(no2) AS no2,
         AVG(so2) AS so2, AVG(co) AS co, AVG(o3) AS o3
  FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
)
SELECT 'PM2.5' AS polluant_dominant, pm25 AS concentration FROM avg_polluants
UNION ALL SELECT 'PM10', pm10 FROM avg_polluants
UNION ALL SELECT 'NO2', no2 FROM avg_polluants
UNION ALL SELECT 'SO2', so2 FROM avg_polluants
UNION ALL SELECT 'CO', co FROM avg_polluants
UNION ALL SELECT 'O3', o3 FROM avg_polluants
ORDER BY concentration DESC
LIMIT 1;

-- 7. Évolution de l'AQI dans le temps (line chart)
SELECT
    DATE_TRUNC('month', date)::DATE AS mois,
    ROUND(AVG(aqi), 1)              AS aqi_moyen
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY DATE_TRUNC('month', date)
ORDER BY mois;

-- 8. AQI moyen par ville (bar chart)
SELECT
    city,
    country,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY city, country
ORDER BY aqi_moyen DESC;

-- 9. Top 10 des villes les plus polluées (bar chart)
SELECT
    city,
    country,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY city, country
ORDER BY aqi_moyen DESC
LIMIT 10;

-- 10. Répartition des catégories de qualité d'air (pie chart)
SELECT
    category,
    COUNT(*) AS nb_jours,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pourcentage
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY category
ORDER BY MIN(aqi);

-- 11. Comparaison des principaux polluants par année (bar chart empilé)
SELECT
    EXTRACT(YEAR FROM date)::INT AS annee,
    ROUND(AVG(pm25), 2) AS pm25,
    ROUND(AVG(pm10), 2) AS pm10,
    ROUND(AVG(no2),  2) AS no2,
    ROUND(AVG(so2),  2) AS so2,
    ROUND(AVG(co),   2) AS co,
    ROUND(AVG(o3),   2) AS o3
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY annee;

-- 12. Carte géographique des villes (pin map)
SELECT
    city,
    country,
    ROUND(latitude,  4) AS latitude,
    ROUND(longitude, 4) AS longitude,
    ROUND(AVG(aqi), 1)  AS aqi_moyen,
    COUNT(*)            AS nb_mesures
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY city, country, latitude, longitude
ORDER BY aqi_moyen DESC;

-- 13. Tableau détail : AQI moyen par ville et par année
SELECT
    city,
    country,
    EXTRACT(YEAR FROM date)::INT AS annee,
    ROUND(AVG(aqi), 1) AS aqi_moyen
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY city, country, annee
ORDER BY city, annee;

-- 14. Concentration moyenne des polluants (bar chart)
WITH c AS (
  SELECT * FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
)
SELECT polluant, ROUND(AVG(concentration), 2) AS concentration
FROM (
  SELECT 'PM2.5' AS polluant, pm25 AS concentration FROM c
  UNION ALL SELECT 'PM10', pm10 FROM c
  UNION ALL SELECT 'NO2', no2 FROM c
  UNION ALL SELECT 'SO2', so2 FROM c
  UNION ALL SELECT 'CO', co FROM c
  UNION ALL SELECT 'O3', o3 FROM c
) t
GROUP BY polluant
ORDER BY concentration DESC;

-- 15. Évolution des polluants dans le temps (area chart empilé)
SELECT
    DATE_TRUNC('month', date)::DATE AS mois,
    ROUND(AVG(pm25), 2) AS pm25,
    ROUND(AVG(pm10), 2) AS pm10,
    ROUND(AVG(no2),  2) AS no2,
    ROUND(AVG(so2),  2) AS so2,
    ROUND(AVG(co),   2) AS co,
    ROUND(AVG(o3),   2) AS o3
FROM aqi_measurements
WHERE 1=1
[[ AND city = {{ville}} ]]
[[ AND country = {{pays}} ]]
[[ AND category = {{categorie}} ]]
[[ AND date >= {{date_debut}} ]]
[[ AND date <= {{date_fin}} ]]
GROUP BY DATE_TRUNC('month', date)
ORDER BY mois;

-- 16. Profil radar des polluants (barres horizontales)
--     Même requête que la #14, affichée en graphique "row".
SELECT polluant, ROUND(AVG(concentration), 2) AS concentration
FROM (
  SELECT 'PM2.5' AS polluant, pm25 AS concentration FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
  UNION ALL SELECT 'PM10', pm10 FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
  UNION ALL SELECT 'NO2', no2 FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
  UNION ALL SELECT 'SO2', so2 FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
  UNION ALL SELECT 'CO', co FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
  UNION ALL SELECT 'O3', o3 FROM aqi_measurements
  WHERE 1=1
  [[ AND city = {{ville}} ]]
  [[ AND country = {{pays}} ]]
  [[ AND category = {{categorie}} ]]
  [[ AND date >= {{date_debut}} ]]
  [[ AND date <= {{date_fin}} ]]
) t
GROUP BY polluant
ORDER BY concentration DESC;

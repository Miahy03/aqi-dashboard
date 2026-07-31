-- =====================================================
-- Requêtes du dashboard AQI (16 cartes) - Data Warehouse Bloc 1
-- Schéma en étoile : fact_air_quality, dim_ville, dim_temps
-- Variables filtres optionnelles : {{ville}}, {{pays}},
-- {{categorie}}, {{date_debut}}, {{date_fin}}
-- Les blocs [[ ... ]] sont ignorés si le filtre est vide.
-- =====================================================

-- 1. KPI : AQI Moyen
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT ROUND(AVG(aqi), 1) AS aqi_moyen FROM m;

-- 2. KPI : AQI Maximum
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT MAX(aqi) AS aqi_maximum FROM m;

-- 3. KPI : AQI Minimum
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT MIN(aqi) AS aqi_minimum FROM m;

-- 4. KPI : Nombre total de mesures
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT COUNT(*) AS total_mesures FROM m;

-- 5. KPI : Nombre de villes analysées
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT COUNT(DISTINCT ville) AS nb_villes FROM m;

-- 6. KPI : Polluant dominant
WITH base AS (
  SELECT f.*, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
), avg_polluants AS (
  SELECT AVG(pm2_5) AS pm2_5, AVG(pm10) AS pm10, AVG(no2) AS no2,
         AVG(so2) AS so2, AVG(o3) AS o3, AVG(co) AS co,
         AVG(no) AS no, AVG(nh3) AS nh3
  FROM m
)
SELECT 'PM2.5' AS polluant_dominant, pm2_5 AS concentration FROM avg_polluants
UNION ALL SELECT 'PM10', pm10 FROM avg_polluants
UNION ALL SELECT 'NO2', no2 FROM avg_polluants
UNION ALL SELECT 'SO2', so2 FROM avg_polluants
UNION ALL SELECT 'O3', o3 FROM avg_polluants
UNION ALL SELECT 'CO', co FROM avg_polluants
UNION ALL SELECT 'NO', no FROM avg_polluants
UNION ALL SELECT 'NH3', nh3 FROM avg_polluants
ORDER BY concentration DESC
LIMIT 1;

-- 7. Évolution de l'AQI dans le temps (line chart)
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  DATE_TRUNC('month', date_entiere)::DATE AS mois,
  ROUND(AVG(aqi), 1) AS aqi_moyen
FROM m
GROUP BY DATE_TRUNC('month', date_entiere)
ORDER BY mois;

-- 8. AQI moyen par ville (bar chart)
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  ville,
  pays,
  ROUND(AVG(aqi), 1) AS aqi_moyen
FROM m
GROUP BY ville, pays
ORDER BY aqi_moyen DESC;

-- 9. Top 10 des villes les plus polluées (bar chart)
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  ville,
  pays,
  ROUND(AVG(aqi), 1) AS aqi_moyen
FROM m
GROUP BY ville, pays
ORDER BY aqi_moyen DESC
LIMIT 10;

-- 10. Répartition des catégories de qualité d'air (pie chart)
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  categorie,
  COUNT(*) AS nb_mesures,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pourcentage
FROM m
GROUP BY categorie
ORDER BY MIN(aqi);

-- 11. Comparaison des principaux polluants par année (bar chart empilé)
WITH base AS (
  SELECT f.*, v.nom AS ville, v.pays, t.date_entiere, t.annee,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  annee,
  ROUND(AVG(pm2_5)::numeric, 2) AS pm2_5,
  ROUND(AVG(pm10)::numeric, 2) AS pm10,
  ROUND(AVG(no2)::numeric,  2) AS no2,
  ROUND(AVG(so2)::numeric,  2) AS so2,
  ROUND(AVG(o3)::numeric,   2) AS o3,
  ROUND(AVG(co)::numeric,   2) AS co
FROM m
GROUP BY annee
ORDER BY annee;

-- 12. Carte géographique des villes (pin map)
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, v.latitude, v.longitude, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  ville,
  pays,
  ROUND(latitude::numeric,  4) AS latitude,
  ROUND(longitude::numeric, 4) AS longitude,
  ROUND(AVG(aqi), 1) AS aqi_moyen,
  COUNT(*) AS nb_mesures
FROM m
GROUP BY ville, pays, latitude, longitude
ORDER BY aqi_moyen DESC;

-- 13. Tableau détail : AQI moyen par ville et par année
WITH base AS (
  SELECT f.aqi, v.nom AS ville, v.pays, t.date_entiere, t.annee,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  ville,
  pays,
  annee,
  ROUND(AVG(aqi), 1) AS aqi_moyen
FROM m
GROUP BY ville, pays, annee
ORDER BY ville, annee;

-- 14. Concentration moyenne des polluants (bar chart)
WITH base AS (
  SELECT f.*, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT polluant, ROUND(AVG(concentration)::numeric, 2) AS concentration
FROM (
  SELECT 'PM2.5' AS polluant, pm2_5 AS concentration FROM m
  UNION ALL SELECT 'PM10', pm10 FROM m
  UNION ALL SELECT 'NO2', no2 FROM m
  UNION ALL SELECT 'SO2', so2 FROM m
  UNION ALL SELECT 'O3', o3 FROM m
  UNION ALL SELECT 'CO', co FROM m
) t
GROUP BY polluant
ORDER BY concentration DESC;

-- 15. Évolution des polluants dans le temps (area chart empilé)
WITH base AS (
  SELECT f.*, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT
  DATE_TRUNC('month', date_entiere)::DATE AS mois,
  ROUND(AVG(pm2_5)::numeric, 2) AS pm2_5,
  ROUND(AVG(pm10)::numeric, 2) AS pm10,
  ROUND(AVG(no2)::numeric,  2) AS no2,
  ROUND(AVG(so2)::numeric,  2) AS so2,
  ROUND(AVG(o3)::numeric,   2) AS o3,
  ROUND(AVG(co)::numeric,   2) AS co
FROM m
GROUP BY DATE_TRUNC('month', date_entiere)
ORDER BY mois;

-- 16. Profil radar des polluants (barres horizontales)
--     Même requête que la #14, affichée en graphique "row".
WITH base AS (
  SELECT f.*, v.nom AS ville, v.pays, t.date_entiere,
    CASE WHEN f.aqi <= 50 THEN 'Good'
         WHEN f.aqi <= 100 THEN 'Moderate'
         WHEN f.aqi <= 150 THEN 'Unhealthy for Sensitive Groups'
         WHEN f.aqi <= 200 THEN 'Unhealthy'
         WHEN f.aqi <= 300 THEN 'Very Unhealthy'
         ELSE 'Hazardous' END AS categorie
  FROM fact_air_quality f
  JOIN dim_ville v ON f.id_ville = v.id_ville
  JOIN dim_temps t ON f.id_temps = t.id_temps
), m AS (
  SELECT * FROM base WHERE 1=1
  [[ AND ville = {{ville}} ]]
  [[ AND pays = {{pays}} ]]
  [[ AND categorie = {{categorie}} ]]
  [[ AND date_entiere >= {{date_debut}} ]]
  [[ AND date_entiere <= {{date_fin}} ]]
)
SELECT polluant, ROUND(AVG(concentration)::numeric, 2) AS concentration
FROM (
  SELECT 'PM2.5' AS polluant, pm2_5 AS concentration FROM m
  UNION ALL SELECT 'PM10', pm10 FROM m
  UNION ALL SELECT 'NO2', no2 FROM m
  UNION ALL SELECT 'SO2', so2 FROM m
  UNION ALL SELECT 'O3', o3 FROM m
  UNION ALL SELECT 'CO', co FROM m
) t
GROUP BY polluant
ORDER BY concentration DESC;

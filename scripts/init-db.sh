#!/usr/bin/env bash
set -euo pipefail

DB_NAME="aqi_warehouse"
DB_USER="aqi_user"
DB_PASS="aqi_pass_2024"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5433}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 Initialisation du Data Warehouse AQI..."
echo "   Hôte : $DB_HOST:$DB_PORT"
echo "   Base  : $DB_NAME"
echo ""

echo "⏳ Attente de PostgreSQL..."
until PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done
echo "✅ PostgreSQL prêt."
echo ""

echo "📦 Création du schéma..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCRIPT_DIR/sql/schema.sql"
echo "✅ Schéma créé."
echo ""

echo "📊 Import des données..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCRIPT_DIR/sql/seed_data.sql"
echo "✅ Données importées."
echo ""

echo "🔍 Vérification..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<SQL
SELECT
    COUNT(*)           AS total_enregistrements,
    COUNT(DISTINCT city) AS nb_villes,
    MIN(date)          AS date_debut,
    MAX(date)          AS date_fin,
    ROUND(AVG(aqi),1)  AS aqi_moyen
FROM aqi_measurements;
SQL

echo ""
echo "🎯 Initialisation terminée avec succès !"
echo "   Connecte-toi à Metabase sur http://localhost:3001"
echo "   Configure la base de données avec :"
echo "     Host : postgres  (ou localhost si hors Docker)"
echo "     Port : 5432"
echo "     Base : $DB_NAME"
echo "     User : $DB_USER"
echo "     Pass : $DB_PASS"

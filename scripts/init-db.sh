#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/.env"

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5433}"

echo "Initialisation du Data Warehouse AQI..."
echo "   Hote : $DB_HOST:$DB_PORT"
echo "   Base  : $POSTGRES_DB"
echo ""

echo "Attente de PostgreSQL..."
until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done
echo "PostgreSQL pret."
echo ""

echo "Creation du schema..."
PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$SCRIPT_DIR/sql/schema.sql"
echo "Schema cree."
echo ""

HAS_DATA=$(PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -A -c "SELECT COUNT(*) FROM aqi_measurements;" 2>/dev/null || echo "0")
if [ "$HAS_DATA" = "0" ]; then
    echo "Import des donnees..."
    PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$SCRIPT_DIR/sql/seed_data.sql"
    echo "Donnees importees."
else
    echo "Donnees deja presentes ($HAS_DATA enregistrements), import ignore."
fi
echo ""

echo "Verification..."
PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<SQL
SELECT
    COUNT(*)           AS total_enregistrements,
    COUNT(DISTINCT city) AS nb_villes,
    MIN(date)          AS date_debut,
    MAX(date)          AS date_fin,
    ROUND(AVG(aqi),1)  AS aqi_moyen
FROM aqi_measurements;
SQL

echo ""
echo "Initialisation terminee avec succes !"
echo "   Connecte-toi a Metabase sur http://localhost:3001"
echo "   Configure la base de donnees avec :"
echo "     Host : postgres  (ou localhost si hors Docker)"
echo "     Port : 5432"
echo "     Base : $POSTGRES_DB"
echo "     User : $POSTGRES_USER"
echo "     Pass : $POSTGRES_PASSWORD"

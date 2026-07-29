#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/.env"

export PGSSLMODE="$POSTGRES_SSL"
CONN="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB"

echo "Initialisation du Data Warehouse sur Neon..."
echo "   Hote  : $POSTGRES_HOST:$POSTGRES_PORT"
echo "   Base  : $POSTGRES_DB"
echo ""

echo "Attente de Neon..."
until PGPASSWORD="$POSTGRES_PASSWORD" psql $CONN -c "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done
echo "Neon pret."
echo ""

echo "Creation du schema..."
PGPASSWORD="$POSTGRES_PASSWORD" psql $CONN -f "$SCRIPT_DIR/sql/schema.sql"
echo "Schema cree."
echo ""

HAS_DATA=$(PGPASSWORD="$POSTGRES_PASSWORD" psql $CONN -t -A -c "SELECT COUNT(*) FROM aqi_measurements;" 2>/dev/null || echo "0")
if [ "$HAS_DATA" = "0" ]; then
    echo "Import des donnees..."
    PGPASSWORD="$POSTGRES_PASSWORD" psql $CONN -f "$SCRIPT_DIR/sql/seed_data.sql"
    echo "Donnees importees."
else
    echo "Donnees deja presentes ($HAS_DATA enregistrements), import ignore."
fi

echo ""
echo "Verification..."
PGPASSWORD="$POSTGRES_PASSWORD" psql $CONN <<SQL
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
echo "   Metabase : http://localhost:3001"
echo "   Neon     : $POSTGRES_HOST"

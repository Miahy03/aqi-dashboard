# AQI Global Dashboard – Bloc 2

Tableau de bord interactif pour l'analyse de la qualité de l'air (AQI) avec **Metabase** et **PostgreSQL**.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│  Browser    │────▶│   Metabase   │────▶│  PostgreSQL  │
│ localhost:3000│     │  (BI Tool)   │     │  (Data WH)   │
└─────────────┘     └──────────────┘     └──────────────┘
```

## Prérequis

- Docker & Docker Compose
- Python 3 (pour la génération des données)
- Navigateur web

## Déploiement rapide

```bash
# 1. Générer les données (si non présentes)
python3 scripts/generate_data.py

# 2. Lancer PostgreSQL + Metabase
docker compose up -d

# 3. Vérifier l'initialisation
bash scripts/init-db.sh
```

## Accès

| Service    | URL                        |
|------------|----------------------------|
| Metabase   | http://localhost:3000      |
| PostgreSQL | localhost:5432             |

## Connexion Metabase → PostgreSQL

1. Ouvrir http://localhost:3000
2. Créer le compte admin
3. **Ajouter une base de données** :
   - Type : PostgreSQL
   - Host : `postgres` (ou `localhost` si Metabase tourne hors Docker)
   - Port : `5432`
   - Database : `aqi_warehouse`
   - Username : `aqi_user`
   - Password : `aqi_pass_2024`

## Structure du Dashboard

### KPI (5 cartes)
- AQI moyen, AQI max, AQI min, Nombre de mesures, Nombre de villes

### Visualisations (7 graphiques)
1. Évolution temporelle de l'AQI (line chart)
2. AQI moyen par ville (bar chart)
3. Top 10 villes les plus polluées (bar chart)
4. Répartition des catégories AQI (donut)
5. Comparaison des polluants (bar chart groupé)
6. Heatmap mois × année
7. Carte géographique des villes

### Filtres (4)
- Ville, Pays, Date (période), Catégorie AQI

## Palette de couleurs AQI

| Catégorie | Couleur | HEX |
|-----------|---------|-----|
| Good | Vert | #00E400 |
| Moderate | Jaune | #FFFF00 |
| Unhealthy for Sensitive Groups | Orange | #FF7E00 |
| Unhealthy | Rouge | #FF0000 |
| Very Unhealthy | Violet | #8F3F97 |
| Hazardous | Marron | #7E0023 |

## Fichiers du projet

```
.
├── docker-compose.yml         # Infrastructure Docker
├── sql/
│   ├── schema.sql             # Définition de la table
│   ├── seed_data.sql          # Données générées (33 340 lignes, 2022-2026)
│   └── queries.sql            # Toutes les requêtes SQL
├── scripts/
│   ├── generate_data.py       # Générateur de données
│   └── init-db.sh             # Script d'initialisation
├── docs/
│   └── analyse.md             # Analyse et recommandations
└── README.md
```

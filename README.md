# AQI Global Dashboard – Bloc 2

Tableau de bord interactif pour l'analyse de la qualité de l'air (AQI) avec **Metabase** et **Neon PostgreSQL**, construit sur le **data warehouse du Bloc 1** (schéma en étoile).

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│  Browser    │────▶│   Metabase   │────▶│    Neon      │
│ localhost:3001│     │  (BI Tool)   │     │  (Cloud DB)  │
└─────────────┘     └──────────────┘     └──────────────┘
                            │
                    ┌───────┴───────┐
                    │   ngrok (opt) │
                    │ URL publique  │
                    └───────────────┘
```

## Prérequis

- Docker
- Python 3
- Compte [Neon](https://neon.tech) (gratuit) ou une instance PostgreSQL distante
- ngrok (optionnel, pour exposition publique)

## Configuration

```bash
cp .env.example .env
```

Éditer `.env` avec les identifiants Neon (fournis dans le dashboard Neon).

## Lancement

```bash
# 1. Vérifier le Data Warehouse (Neon, schéma en étoile Bloc 1)
#    → dim_ville, dim_temps, fact_air_quality (46 426 mesures)

# 2. Exporter le CSV depuis Neon (optionnel, pour l'analyse pandas)
psql "postgresql://..." -c "\copy (SELECT ... ) TO 'data/aqi_measurements.csv' WITH CSV HEADER"

# 3. Analyse hors Metabase (pandas + matplotlib, optionnel)
pip install pandas matplotlib
python3 scripts/analyse.py

# 4. Lancer Metabase
docker compose up -d
```

## Accès

| Service | URL |
|---------|-----|
| **ngrok (public)** | https://crunchy-graded-albatross.ngrok-free.dev/dashboard/2|

## Sources de données des filtres

Les filtres **Ville**, **Pays** et **Catégorie** sont alimentés par des cartes dédiées :
- `Liste Villes` (5 villes) → filtre Ville
- `Liste Pays` (codes pays) → filtre Pays
- `Liste Categories` (6 catégories calculées depuis `aqi`) → filtre Catégorie


## Dashboard (16 cartes)

```
┌────┬────┬────┬────┬────┬────┐
│Moyen│Max│Min│Mesures│Villes│Polluant│  ← 6 KPIs
├──────────┬─────────────┤
│ Tendance │ Top villes  │  Graphiques
├──────────┼─────────────┤
│AQI/Ville │ Qualité Air │
├──────────┼─────────────┤
│Polluants │ Concentration│
├──────────┼─────────────┤
│Évolution │ Radar       │
├───────────────────────┤
│      Carte AQI        │  Pleine largeur
├───────────────────────┤
│   Tableau détail      │
└───────────────────────┘
```

### KPIs (6)
- AQI moyen, AQI maximum, AQI minimum, Nombre de mesures, Nombre de villes, Polluant dominant

### Graphiques (10)
1. Évolution temporelle de l'AQI (line chart)
2. Top des villes les plus polluées (bar chart)
3. AQI moyen par ville (bar chart)
4. Répartition des catégories AQI (pie chart)
5. Comparaison des polluants (bar chart empilé)
6. Carte géographique des villes (pin map)
7. Concentration moyenne des polluants (bar chart)
8. Évolution des polluants dans le temps (area chart empilé)
9. Profil radar des polluants (barres horizontales)
10. Tableau détail AQI par ville/année (table)

### Filtres interactifs (5)
- **Ville**, **Pays**, **Catégorie**, **Du** (date début), **Au** (date fin)
- Appliqués sur toutes les cartes via variables SQL optionnelles

## Données (data warehouse Bloc 1)

Schéma en étoile sur **Neon PostgreSQL** (hébergé sur `ep-cold-sun-…eu-central-1`):

| Table | Rôle |
|-------|------|
| `dim_ville` | 5 villes : Tokyo, New York, Paris, London, Antananarivo |
| `dim_temps` | Dimension temps (date, année, mois, jour, heure) |
| `fact_air_quality` | Faits : AQI + polluants (PM2.5, PM10, NO2, SO2, O3, CO, NO, NH3) |

- **46 426 mesures** horaires sur 1 an (2025-07 → 2026-07)
- Catégorie AQI calculée en SQL depuis `aqi` (pas de colonne stockée)
- Fichier exporté : `data/aqi_measurements.csv`

## Palette de couleurs AQI

| Catégorie | HEX |
|-----------|-----|
| Bonne | #00E400 |
| Modérée | #FFFF00 |
| Malsaine | #FF7E00 |
| Très malsaine | #FF0000 |
| Dangereuse | #8F3F97 |

## Fichiers du projet

```
.
├── Dockerfile                  # Image Metabase pour déploiement
├── docker-compose.yml          # Metabase (Docker)
├── data/
│   └── aqi_measurements.csv    # Données exportées depuis Neon (46 426 lignes)
├── sql/
│   └── queries.sql           # 16 requêtes SQL du dashboard (schéma en étoile)
├── scripts/
│   └── analyse.py              # Analyse pandas + matplotlib (5 figures)
├── docs/
│   ├── analyse.md              # Analyse et recommandations
│   └── figures/                # Graphiques générés par analyse.py
├── .env                        # Identifiants (ne pas commiter)
├── .env.example                # Template des variables
└── README.md
```

## Déploiement public

### ngrok (recommandé pour démonstration)

```bash
ngrok http 3001
```

L'URL change à chaque redémarrage sur le plan gratuit.

## Licence

Projet scolaire : Visualisation de données.

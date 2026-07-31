# AQI Global Dashboard – Bloc 2

Tableau de bord interactif pour l'analyse de la qualité de l'air (AQI) avec **Metabase** et **Neon PostgreSQL**.

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
# 1. Générer les données (33 340 enregistrements)
#    → sql/seed_data.sql ET data/aqi_measurements.csv
python3 scripts/generate_data.py

# 2. Initialiser la base Neon
bash scripts/init-db.sh

# 3. Valider les données
python3 scripts/validate_data.py

# 4. Analyse hors Metabase (pandas + matplotlib, optionnel)
pip install pandas matplotlib
python3 scripts/analyse.py

# 5. Lancer Metabase
docker compose up -d
```

## Accès

| Service | URL |
|---------|-----|
| **ngrok (public)** | https://crunchy-graded-albatross.ngrok-free.dev/dashboard/2|


## Dashboard (13 cartes)

```
┌────┬────┬────┬────┬────┬────┐
│Moyen│Max│Min│Mesures│Villes│Polluant│  ← 6 KPIs
├──────────┬─────────────┤
│ Tendance │ Top 10      │  Graphiques
├──────────┼─────────────┤
│AQI/Ville │ Qualité Air │
├──────────┼─────────────┤
│Polluants │ Tableau     │
├───────────────────────┤
│      Carte AQI        │  Pleine largeur
└───────────────────────┘
```

### KPIs (6)
- AQI moyen, AQI maximum, AQI minimum, Nombre de mesures, Nombre de villes, Polluant dominant

### Graphiques (6)
1. Évolution temporelle de l'AQI (line chart)
2. Top 10 des villes les plus polluées (bar chart)
3. AQI moyen par ville (bar chart)
4. Répartition des catégories AQI (pie chart)
5. Comparaison des polluants (bar chart empilé)
6. Carte géographique des villes (pin map)

### Filtres interactifs (5)
- **Ville**, **Pays**, **Catégorie**, **Du** (date début), **Au** (date fin)
- Appliqués sur toutes les cartes via variables SQL optionnelles

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
│   └── aqi_measurements.csv    # Données exportées (33 340 lignes, source CSV)
├── sql/
│   ├── schema.sql              # Définition de la table
│   ├── seed_data.sql           # Données générées (33 340 lignes)
│   └── queries.sql           # 13 requêtes SQL du dashboard
├── scripts/
│   ├── generate_data.py        # Générateur de données (SQL + CSV)
│   ├── init-db.sh              # Script d'initialisation Neon
│   ├── validate_data.py        # Validation (8 vérifications)
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

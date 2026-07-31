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
python3 scripts/generate_data.py

# 2. Initialiser la base Neon
bash scripts/init-db.sh

# 3. Valider les données
python3 scripts/validate_data.py

# 4. Lancer Metabase
docker compose up -d
```

## Accès

| Service | URL |
|---------|-----|
| Metabase | http://localhost:3001 |
| Dashboard | http://localhost:3001/dashboard/2 |
| **ngrok (public)** | https://crunchy-graded-albatross.ngrok-free.dev |

## Connexion Metabase

- **Email :** `hei.miahy.2@gmail.com`
- **Mot de passe :** `miahy171008`
- La base Neon est préconfigurée (table `aqi_measurements` avec 33 340 lignes, 20 villes, 2022-2026)

## Dashboard (16 cartes)

```
┌────┬────┬────┬────┬────┬────┐
│Moyen│Max│Min│Mesures│Villes│Polluant│  ← 6 KPIs
├──────────┬─────────────┤
│ Tendance │ Top 10      │  Graphiques
├──────────┼─────────────┤
│AQI/Ville │ Qualité Air │
├──────────┼─────────────┤
│ Conc.    │ Évolution   │
│ polluants│ polluants   │
├──────────┼─────────────┤
│Polluants │ Profil      │
│ annuels  │ radar       │
├───────────────────────┤
│      Carte AQI        │  Pleine largeur
├───────────────────────┤
│    Tableau détail     │
└───────────────────────┘
```

### KPIs (6)
- AQI moyen, AQI maximum, AQI minimum, Nombre de mesures, Nombre de villes, Polluant dominant

### Graphiques (9)
1. Évolution temporelle de l'AQI (line chart)
2. Top 10 des villes les plus polluées (bar chart)
3. AQI moyen par ville (bar chart)
4. Répartition des catégories AQI (pie chart)
5. Comparaison des polluants (bar chart empilé)
6. **Concentration moyenne des polluants** (bar chart)
7. **Évolution des polluants dans le temps** (area chart empilé, 6 séries)
8. **Profil radar des polluants** (barres horizontales — équivalent radar, Metabase n'a pas de radar natif)
9. Carte géographique des villes (pin map)

### Tableau
- Tableau détail : AQI moyen par ville et par année

### Filtres interactifs (5)
- **Ville**, **Pays**, **Catégorie**, **Du** (date début), **Au** (date fin)
- Appliqués sur toutes les cartes via variables SQL optionnelles
- Les filtres Ville / Pays / Catégorie proposent des suggestions (liste des valeurs DISTINCT)

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
├── sql/
│   ├── schema.sql              # Définition de la table
│   ├── seed_data.sql           # Données générées (33 340 lignes)
│   └── queries.sql           # 13 requêtes SQL du dashboard
├── scripts/
│   ├── generate_data.py        # Générateur de données
│   ├── init-db.sh              # Script d'initialisation Neon
│   ├── validate_data.py        # Validation (8 vérifications)
│   └── deploy_setup.py         # Setup automatisé Metabase
├── docs/
│   └── analyse.md              # Analyse et recommandations
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

### Render / Railway

Le `Dockerfile` permet le déploiement sur toute plateforme Docker. Configurer les 15 variables d'env (cf. `.env.example`). Lancer ensuite :

```bash
python3 scripts/deploy_setup.py
```

## Licence

Projet scolaire – Bloc 2 : Visualisation de données.

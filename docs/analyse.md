# Analyse du Dashboard AQI – Bloc 2

*Données : data warehouse Bloc 1 (schéma en étoile Neon), 46 426 mesures horaires, 5 villes, 2025-07 → 2026-07.*

## 1. Villes

| Ville | Pays | AQI moyen |
|-------|------|-----------|
| Tokyo | JP | 45.2 |
| Paris | FR | 35.4 |
| London | GB | 35.0 |
| New York | US | 34.7 |
| Antananarivo | MG | 30.7 |

**Tokyo est la ville la plus polluée** du jeu de données ; **Antananarivo la moins polluée**. Les écarts entre villes restent modérés (30.7 – 45.2).

## 2. Tendances observées

- **AQI globalement bon** : l'AQI moyen global est de ~37.6, la majorité des mesures (84 %) tombent dans la catégorie **Good**.
- Les pics d'AQI interviennent surtout en **hiver** (décembre-février) dans l'hémisphère nord (Tokyo, Paris, London).
- Peu de tendance forte à la hausse ou baisse sur la période d'un an.

## 3. Périodes critiques

| Période | Constat |
|---------|---------|
| Décembre – Février | AQI maximal, surtout à Tokyo et London |
| Heures de pointe (8h–12h) | AQI légèrement plus élevé, lié au trafic matinal |

La granularité **horaire** du warehouse permet d'observer un profil journalier : la pollution augmente le matin, atteint un plateau en journée, et diminue la nuit.

## 4. Principaux polluants

| Polluant | Concentration moyenne |
|----------|----------------------|
| **CO** | ~182 µg/m³ |
| **O3** | ~79 µg/m³ |
| **PM10** | ~19 µg/m³ |
| **PM2.5** | ~10 µg/m³ |
| NO2 | ~5 µg/m³ |
| SO2 | ~2 µg/m³ |

**Conclusion :** Le monoxyde de carbone (CO) et l'ozone (O3) dominent en concentration ; les particules fines (PM2.5/PM10) restent le risque sanitaire le plus suivi.

## 5. Conclusions

1. **La qualité de l'air est globalement bonne** sur le jeu de données (84 % de mesures "Good").
2. **Tokyo concentre la pollution** : c'est la ville avec l'AQI moyen le plus élevé.
3. **La saisonnalité hivernale** marque les pics dans l'hémisphère nord.
4. **La granularité horaire** permet de visualiser l'effet du trafic sur l'AQI quotidien.
5. **Le CO et l'O3** dominent en concentration ; les PM restent le principal enjeu sanitaire.

## 6. Recommandations

### Pour les villes
- Renforcer le **contrôle des émissions de trafic** (zones à faibles émissions), surtout à Tokyo.
- Suivre l'**ozone en été** (formation photochimique) et le **CO en hiver**.

### Pour l'analyse
- Étendre le jeu de données à **plus de villes et plusieurs années** pour des tendances fiables.
- Croiser l'AQI avec la **météo** (température, vent, précipitations).
- Utiliser la dimension **horaire** pour alerter aux heures de pointe.

### Pour les décideurs
- Aligner les seuils sur les **normes OMS** (plus strictes).
- Publier des **bulletins par heure** pour les populations sensibles.

---

*Document produit dans le cadre du projet AQI – Bloc 2 : Visualisation de données.*
*Données : data warehouse Bloc 1 (Neon, schéma en étoile), 5 villes, mesures horaires 2025-2026.*

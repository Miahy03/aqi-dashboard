#!/usr/bin/env python3
import os
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(BASE, "data", "aqi_measurements.csv")
OUT_DIR = os.path.join(BASE, "docs", "figures")

AQI_COLORS = {
    "Good": "#00E400",
    "Moderate": "#FFFF00",
    "Unhealthy for Sensitive Groups": "#FF7E00",
    "Unhealthy": "#FF0000",
    "Very Unhealthy": "#8F3F97",
    "Hazardous": "#7E0023",
}

POLLUANTS = ["pm25", "pm10", "no2", "so2", "co", "o3"]


def save(fig, name):
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, name)
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print("  ->", path)


def main():
    if not os.path.exists(CSV_PATH):
        sys.exit("Fichier introuvable : {} (lancer d'abord scripts/generate_data.py)".format(CSV_PATH))

    df = pd.read_csv(CSV_PATH, parse_dates=["date"])
    df["year"] = df["date"].dt.year
    df["month"] = df["date"].dt.month

    print("Chargement : {} enregistrements, {} villes, {} pays".format(
        len(df), df["city"].nunique(), df["country"].nunique()
    ))

    # 1. AQI moyen par ville
    top = (df.groupby("city")["aqi"].mean().sort_values(ascending=False).head(10))
    fig, ax = plt.subplots(figsize=(9, 5))
    top.plot(kind="barh", ax=ax, color="#d62728")
    ax.set_title("Top 10 villes les plus polluées (AQI moyen)")
    ax.set_xlabel("AQI moyen")
    ax.invert_yaxis()
    save(fig, "top10_villes.png")

    # 2. Évolution mensuelle globale
    monthly = df.groupby(df["date"].dt.to_period("M"))["aqi"].mean()
    fig, ax = plt.subplots(figsize=(11, 4))
    monthly.plot(ax=ax, color="#1f77b4", linewidth=1.5)
    ax.set_title("Évolution mensuelle de l'AQI moyen (global)")
    ax.set_ylabel("AQI moyen")
    ax.set_xlabel("")
    save(fig, "evolution_mensuelle.png")

    # 3. Répartition des catégories
    counts = df["category"].value_counts()
    fig, ax = plt.subplots(figsize=(7, 7))
    colors = [AQI_COLORS[c] for c in counts.index]
    ax.pie(counts, labels=counts.index, colors=colors, autopct="%.1f%%", startangle=90)
    ax.set_title("Répartition des catégories AQI")
    save(fig, "categories.png")

    # 4. Concentrations moyennes des polluants
    means = df[POLLUANTS].mean().sort_values(ascending=False)
    fig, ax = plt.subplots(figsize=(8, 4))
    means.plot(kind="bar", ax=ax, color="#2ca02c")
    ax.set_title("Concentration moyenne des polluants (toutes villes)")
    ax.set_ylabel("µg/m³ (CO : autres unités)")
    ax.set_xticklabels(ax.get_xticklabels(), rotation=0)
    save(fig, "polluants_moyens.png")

    # 5. Saisonnalité (AQI moyen par mois)
    seasonal = df.groupby("month")["aqi"].mean()
    fig, ax = plt.subplots(figsize=(8, 4))
    seasonal.plot(kind="line", marker="o", ax=ax, color="#9467bd")
    ax.set_title("Saisonnalité : AQI moyen par mois")
    ax.set_ylabel("AQI moyen")
    ax.set_xticks(range(1, 13))
    save(fig, "saisonnalite.png")

    # Synthèse texte
    print("\n=== SYNTHÈSE ===")
    print("AQI moyen global : {:.1f}".format(df["aqi"].mean()))
    print("Ville la plus polluée : {}".format(
        df.groupby("city")["aqi"].mean().idxmax()
    ))
    print("Ville la moins polluée : {}".format(
        df.groupby("city")["aqi"].mean().idxmin()
    ))
    print("Catégorie la plus fréquente : {}".format(counts.idxmax()))
    print("Année la plus polluée : {}".format(
        df.groupby("year")["aqi"].mean().idxmax()
    ))
    print("Figures sauvegardées dans {}".format(OUT_DIR))


if __name__ == "__main__":
    main()

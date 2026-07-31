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

POLLUANTS = ["pm2_5", "pm10", "no2", "so2", "co", "o3"]


def aqi_category(aqi):
    if aqi <= 50:
        return "Good"
    if aqi <= 100:
        return "Moderate"
    if aqi <= 150:
        return "Unhealthy for Sensitive Groups"
    if aqi <= 200:
        return "Unhealthy"
    if aqi <= 300:
        return "Very Unhealthy"
    return "Hazardous"


def save(fig, name):
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, name)
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print("  ->", path)


def main():
    if not os.path.exists(CSV_PATH):
        sys.exit("Fichier introuvable : {} (exporter depuis Neon d'abord)".format(CSV_PATH))

    df = pd.read_csv(CSV_PATH, parse_dates=["date_entiere"])
    df["category"] = df["aqi"].apply(aqi_category)
    df["date"] = pd.to_datetime(df["date_entiere"])
    df["year"] = df["date"].dt.year
    df["month"] = df["date"].dt.month

    print("Chargement : {} enregistrements, {} villes, {} pays".format(
        len(df), df["ville"].nunique(), df["pays"].nunique()
    ))

    # 1. AQI moyen par ville
    top = df.groupby("ville")["aqi"].mean().sort_values(ascending=False)
    fig, ax = plt.subplots(figsize=(8, 4.5))
    top.plot(kind="barh", ax=ax, color="#d62728")
    ax.set_title("AQI moyen par ville")
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

    # 5. Profil horaire (AQI moyen par heure)
    hourly = df.groupby("heure")["aqi"].mean()
    fig, ax = plt.subplots(figsize=(8, 4))
    hourly.plot(kind="line", marker="o", ax=ax, color="#9467bd")
    ax.set_title("Profil horaire : AQI moyen par heure de la journée")
    ax.set_ylabel("AQI moyen")
    ax.set_xlabel("Heure")
    ax.set_xticks(range(0, 24, 2))
    save(fig, "profil_horaire.png")

    # Synthèse texte
    print("\n=== SYNTHÈSE ===")
    print("AQI moyen global : {:.1f}".format(df["aqi"].mean()))
    print("Ville la plus polluée : {}".format(df.groupby("ville")["aqi"].mean().idxmax()))
    print("Ville la moins polluée : {}".format(df.groupby("ville")["aqi"].mean().idxmin()))
    print("Catégorie la plus fréquente : {}".format(counts.idxmax()))
    print("Période : {} → {}".format(df["date"].min().date(), df["date"].max().date()))
    print("Figures sauvegardées dans {}".format(OUT_DIR))


if __name__ == "__main__":
    main()

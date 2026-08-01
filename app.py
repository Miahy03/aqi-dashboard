#!/usr/bin/env python3
import os
from pathlib import Path

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from sqlalchemy import create_engine
import streamlit as st

st.set_page_config(page_title="Tableau de bord Qualité de l'Air (AQI)", layout="wide")

CATEGORY_FR = {
    "Bonne": "Bonne",
    "Moderee": "Modérée",
    "Malsaine pour groupes sensibles": "Malsaine pour groupes sensibles",
    "Malsaine": "Malsaine",
    "Tres malsaine": "Très malsaine",
    "Dangereuse": "Dangereuse",
}

AQI_COLORS = {
    "Bonne": "#00E400",
    "Moderee": "#FFFF00",
    "Malsaine pour groupes sensibles": "#FF7E00",
    "Malsaine": "#FF0000",
    "Tres malsaine": "#8F3F97",
    "Dangereuse": "#7E0023",
}

POLLUANTS = ["pm2_5", "pm10", "no2", "so2", "co", "o3"]
POLLUANT_LABELS = {
    "pm2_5": "PM2.5",
    "pm10": "PM10",
    "no2": "NO2",
    "so2": "SO2",
    "co": "CO",
    "o3": "O3",
}


def aqi_category_fr(aqi):
    if aqi <= 50:
        return "Bonne"
    if aqi <= 100:
        return "Moderee"
    if aqi <= 150:
        return "Malsaine pour groupes sensibles"
    if aqi <= 200:
        return "Malsaine"
    if aqi <= 300:
        return "Tres malsaine"
    return "Dangereuse"


def get_credentials():
    secrets = {}
    try:
        secrets = st.secrets.get("neon", {})
    except Exception:
        secrets = {}
    if secrets:
        return secrets

    env = {}
    p = Path(".env")
    if p.exists():
        for line in p.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip()
    return {
        "host": env.get("POSTGRES_HOST", ""),
        "port": env.get("POSTGRES_PORT", "5432"),
        "db": env.get("POSTGRES_DB", ""),
        "user": env.get("POSTGRES_USER", ""),
        "password": env.get("POSTGRES_PASSWORD", ""),
        "sslmode": env.get("POSTGRES_SSL", "require"),
    }


@st.cache_data(ttl=300, show_spinner=False)
def load_data():
    c = get_credentials()
    url = "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}?sslmode={ssl}".format(
        user=c["user"], password=c["password"], host=c["host"],
        port=c["port"], db=c["db"], ssl=c.get("sslmode", "require"),
    )
    engine = create_engine(url)
    query = """
        SELECT
            v.nom AS ville,
            v.pays AS pays,
            t.date_entiere AS date,
            t.heure AS heure,
            f.aqi AS aqi,
            f.pm2_5, f.pm10, f.no2, f.so2, f.co, f.o3, f.nh3
        FROM fact_air_quality f
        JOIN dim_ville v ON v.id_ville = f.id_ville
        JOIN dim_temps t ON t.id_temps = f.id_temps
    """
    df = pd.read_sql_query(query, engine)
    engine.dispose()
    df["date"] = pd.to_datetime(df["date"])
    df["categorie"] = df["aqi"].apply(aqi_category_fr)
    df["annee_mois"] = df["date"].dt.to_period("M").astype(str)
    return df


@st.cache_data(ttl=300, show_spinner=False)
def ranking(df):
    return (
        df.groupby(["ville", "pays"], as_index=False)["aqi"].mean()
        .sort_values("aqi", ascending=False)
        .reset_index(drop=True)
    )


def main():
    st.title("Tableau de bord Qualité de l'Air (AQI)")

    try:
        df = load_data()
    except Exception as e:
        st.error("Connexion à la base de données impossible : {}".format(e))
        st.stop()

    st.caption("Données : data warehouse Neon (schéma en étoile) · {} mesures · {} villes · période {} → {}".format(
        len(df), df["ville"].nunique(), df["date"].min().date(), df["date"].max().date()
    ))

    col1, col2, col3 = st.columns(3)
    col1.metric("Mesures analysées", "{:,}".format(len(df)))
    col2.metric("AQI moyen global", "{:.1f}".format(df["aqi"].mean()))
    col3.metric("Catégorie dominante", df["categorie"].value_counts().idxmax())

    with st.sidebar:
        st.header("Filtres")
        villes = st.multiselect("Villes", sorted(df["ville"].unique()), default=sorted(df["ville"].unique()))
        pays = st.multiselect("Pays", sorted(df["pays"].unique()), default=sorted(df["pays"].unique()))
        categories = st.multiselect(
            "Catégories",
            ["Bonne", "Moderee", "Malsaine pour groupes sensibles", "Malsaine", "Tres malsaine", "Dangereuse"],
            default=["Bonne", "Moderee", "Malsaine pour groupes sensibles", "Malsaine", "Tres malsaine", "Dangereuse"],
        )
        date_min = df["date"].min().date()
        date_max = df["date"].max().date()
        date_range = st.date_input("Période", value=(date_min, date_max), min_value=date_min, max_value=date_max)

    mask = df["ville"].isin(villes) & df["pays"].isin(pays) & df["categorie"].isin(categories)
    if len(date_range) == 2:
        mask &= (df["date"].dt.date >= date_range[0]) & (df["date"].dt.date <= date_range[1])
    d = df[mask]

    if d.empty:
        st.warning("Aucune donnée avec les filtres sélectionnés.")
        st.stop()

    st.markdown("---")
    st.subheader("Classement des Villes les Plus Polluées")
    rk = ranking(d).reset_index(drop=True)
    rk.index = rk.index + 1
    rk.index.name = "Rang"
    rk["AQI moyen"] = rk["aqi"].round(1)
    rk["Catégorie"] = rk["AQI moyen"].apply(aqi_category_fr)
    st.dataframe(
        rk[["ville", "pays", "AQI moyen", "Catégorie"]].rename(
            columns={"ville": "Ville", "pays": "Pays"}
        ),
        width="stretch",
    )

    c1, c2 = st.columns(2)
    with c1:
        st.subheader("AQI moyen par ville")
        top = d.groupby("ville")["aqi"].mean().sort_values()
        fig = px.bar(top, orientation="h", color_discrete_sequence=["#d62728"])
        fig.update_layout(xaxis_title="AQI moyen", yaxis_title="", height=380, showlegend=False)
        st.plotly_chart(fig, width="stretch")

    with c2:
        st.subheader("Répartition des catégories AQI")
        counts = d["categorie"].value_counts()
        colors = [AQI_COLORS.get(c, "#999999") for c in counts.index]
        fig = go.Figure(go.Pie(labels=counts.index, values=counts.values, marker=dict(colors=colors)))
        fig.update_layout(height=380)
        st.plotly_chart(fig, width="stretch")

    st.subheader("Évolution mensuelle de l'AQI moyen")
    monthly = d.groupby("annee_mois")["aqi"].mean().reset_index()
    fig = px.line(monthly, x="annee_mois", y="aqi", markers=True, color_discrete_sequence=["#1f77b4"])
    fig.update_layout(xaxis_title="", yaxis_title="AQI moyen", height=380)
    st.plotly_chart(fig, width="stretch")

    c3, c4 = st.columns(2)
    with c3:
        st.subheader("Concentration moyenne des polluants")
        means = d[POLLUANTS].mean().sort_values(ascending=False)
        fig = px.bar(
            means,
            orientation="v",
            color_discrete_sequence=["#2ca02c"],
            labels={"value": "µg/m³", "index": "Polluant"},
        )
        fig.update_layout(xaxis_title="", yaxis_title="µg/m³", height=380, showlegend=False)
        st.plotly_chart(fig, width="stretch")

    with c4:
        st.subheader("Profil horaire : AQI moyen par heure")
        hourly = d.groupby("heure")["aqi"].mean().reset_index()
        fig = px.line(hourly, x="heure", y="aqi", markers=True, color_discrete_sequence=["#9467bd"])
        fig.update_layout(xaxis_title="Heure", yaxis_title="AQI moyen", height=380)
        st.plotly_chart(fig, width="stretch")

    st.subheader("Saisonnalité de l'AQI")
    seas = d.assign(mois=d["date"].dt.month).groupby("mois")["aqi"].mean().reset_index()
    fig = px.bar(seas, x="mois", y="aqi", color_discrete_sequence=["#ff7f0e"])
    fig.update_layout(xaxis_title="Mois", yaxis_title="AQI moyen", height=380, showlegend=False)
    st.plotly_chart(fig, width="stretch")


if __name__ == "__main__":
    main()

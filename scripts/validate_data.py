#!/usr/bin/env python3
import os
import subprocess
import sys

def run_sql(query):
    cmd = [
        "psql",
        "-h", "localhost",
        "-p", "5433",
        "-U", "aqi_user",
        "-d", "aqi_warehouse",
        "-t", "-A",
        "-c", query
    ]
    env = os.environ.copy()
    env["PGPASSWORD"] = "aqi_pass_2024"
    result = subprocess.run(cmd, capture_output=True, text=True, env=env)
    return result.stdout.strip()

checks = [
    ("Total enregistrements", "SELECT COUNT(*) FROM aqi_measurements;", lambda v: int(v) > 0),
    ("Aucune valeur AQI negative", "SELECT COUNT(*) FROM aqi_measurements WHERE aqi < 0;", lambda v: v == "0"),
    ("Aucune valeur AQI > 500", "SELECT COUNT(*) FROM aqi_measurements WHERE aqi > 500;", lambda v: v == "0"),
    ("Aucune valeur PM25 negative", "SELECT COUNT(*) FROM aqi_measurements WHERE pm25 < 0;", lambda v: v == "0"),
    ("Date minimale correcte", "SELECT MIN(date)::text FROM aqi_measurements;", lambda v: v == "2022-01-01"),
    ("Date maximale correcte", "SELECT MAX(date)::text FROM aqi_measurements;", lambda v: v == "2026-07-25"),
    ("Nombre de villes", "SELECT COUNT(DISTINCT city) FROM aqi_measurements;", lambda v: int(v) == 20),
    ("Categories AQI valides", "SELECT COUNT(DISTINCT category) FROM aqi_measurements;", lambda v: int(v) == 6),
]

all_ok = True
for label, query, validator in checks:
    value = run_sql(query)
    ok = validator(value)
    all_ok = all_ok and ok
    status = "OK" if ok else "ECHEC"
    print(f"  [{status}] {label}: {value}")

sys.exit(0 if all_ok else 1)

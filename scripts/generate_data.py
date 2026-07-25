#!/usr/bin/env python3
import math
import random
from datetime import date, timedelta

random.seed(42)

CITIES = [
    ("Delhi",          "India",       28.61,  77.23,  180, 60, 25),
    ("Mumbai",         "India",       19.08,  72.88,  130, 45, 20),
    ("Dhaka",          "Bangladesh",  23.81,  90.41,  200, 55, 30),
    ("Karachi",        "Pakistan",    24.86,  67.01,  170, 50, 25),
    ("Beijing",        "China",       39.90, 116.40,  140, 50, 20),
    ("Shanghai",       "China",       31.23, 121.47,  110, 40, 18),
    ("Jakarta",        "Indonesia",   -6.21, 106.85,  120, 35, 20),
    ("Cairo",          "Egypt",       30.04,  31.24,  150, 45, 22),
    ("Lahore",         "Pakistan",    31.55,  74.36,  190, 55, 28),
    ("Mexico City",    "Mexico",      19.43, -99.13,  115, 40, 18),
    ("Los Angeles",    "USA",         34.05,-118.24,   75, 30, 15),
    ("London",         "UK",          51.50,  -0.13,   55, 20, 12),
    ("Paris",          "France",      48.86,   2.35,   60, 22, 13),
    ("Moscow",         "Russia",      55.76,  37.62,   65, 25, 14),
    ("Tokyo",          "Japan",       35.68, 139.69,   55, 20, 12),
    ("Sydney",         "Australia",  -33.87, 151.21,   40, 15, 10),
    ("Sao Paulo",      "Brazil",     -23.55, -46.63,   70, 25, 15),
    ("Istanbul",       "Turkey",      41.01,  28.98,   85, 30, 16),
    ("Nairobi",        "Kenya",      -1.28,   36.82,   95, 35, 18),
    ("Seoul",          "South Korea", 37.57, 126.98,   80, 28, 15),
]

START_DATE = date(2022, 1, 1)
END_DATE   = date(2026, 7, 25)

def aqi_category(aqi_val: int) -> str:
    if aqi_val <= 50:       return "Good"
    if aqi_val <= 100:      return "Moderate"
    if aqi_val <= 150:      return "Unhealthy for Sensitive Groups"
    if aqi_val <= 200:      return "Unhealthy"
    if aqi_val <= 300:      return "Very Unhealthy"
    return "Hazardous"

def clamp(v, lo, hi):
    return max(lo, min(hi, v))

def generate_row(d, city, country, lat, lon, base, amp, noise):
    month = d.month
    season = -math.cos((month - 1) * math.pi / 6)

    aqi_raw = base + amp * season + random.gauss(0, noise)
    aqi_val = int(clamp(round(aqi_raw), 0, 500))

    polluants = {
        "pm25": base * 0.8 + amp * 0.7 * season + random.gauss(0, noise * 0.6),
        "pm10": base * 1.2 + amp * 1.0 * season + random.gauss(0, noise * 0.8),
        "no2":  base * 0.4 + amp * 0.2 * season + random.gauss(0, noise * 0.3),
        "so2":  base * 0.15 + amp * 0.1 * season + random.gauss(0, noise * 0.15),
        "co":   base * 0.03 + amp * 0.02 * season + random.gauss(0, noise * 0.02),
        "o3":   base * 0.25 + amp * 0.15 * (-season) + random.gauss(0, noise * 0.2),
    }
    for k in polluants:
        polluants[k] = round(clamp(polluants[k], 0, 999), 2)

    cat = aqi_category(aqi_val)

    return (
        city, country, lat, lon, d.isoformat(),
        aqi_val,
        polluants["pm25"], polluants["pm10"],
        polluants["no2"],  polluants["so2"],
        polluants["co"],   polluants["o3"],
        cat
    )

def main():
    rows = []
    current = START_DATE
    while current <= END_DATE:
        for city_info in CITIES:
            rows.append(generate_row(current, *city_info))
        current += timedelta(days=1)

    random.shuffle(rows)

    with open("/home/miahy/Donnee2-perso/sql/seed_data.sql", "w") as f:
        batch_size = 500
        for i in range(0, len(rows), batch_size):
            batch = rows[i:i+batch_size]
            f.write("INSERT INTO aqi_measurements\n")
            f.write("    (city, country, latitude, longitude, date, aqi,\n")
            f.write("     pm25, pm10, no2, so2, co, o3, category)\n")
            f.write("VALUES\n")
            vals = []
            for r in batch:
                vals.append(
                    "('{}', '{}', {}, {}, '{}', {}, {}, {}, {}, {}, {}, {}, '{}')".format(*r)
                )
            f.write(",\n".join(vals))
            f.write(";\n\n")

    print("✅ Fichier généré : sql/seed_data.sql ({} lignes, {} enregistrements)".format(
        len(rows), len(rows)
    ))

if __name__ == "__main__":
    main()

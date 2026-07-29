import json, os, sys, time, requests

MB_URL = os.environ.get("MB_URL", "http://localhost:3000")
EMAIL = os.environ.get("MB_EMAIL", "admin@aqi.local")
PASS = os.environ.get("MB_PASSWORD", "admin123")
NEON_HOST = os.environ.get("POSTGRES_HOST", "")
NEON_PORT = os.environ.get("POSTGRES_PORT", "5432")
NEON_DB = os.environ.get("POSTGRES_DB", "neondb")
NEON_USER = os.environ.get("POSTGRES_USER", "")
NEON_PASS = os.environ.get("POSTGRES_PASSWORD", "")

H = {"Content-Type": "application/json"}

def wait_for_metabase():
    for i in range(60):
        try:
            r = requests.get(f"{MB_URL}/api/session/properties", timeout=5)
            if r.status_code == 200:
                return r.json()
        except:
            pass
        time.sleep(2)
    raise Exception("Metabase not ready after 120s")

def setup_admin(props):
    token = props.get("setup-token")
    if not token:
        print("Already has admin, logging in...")
        r = requests.post(f"{MB_URL}/api/session", json={"username": EMAIL, "password": PASS})
        if r.status_code == 200:
            return r.json()["id"]
        print("Login failed, trying to reset...")
        return None
    print("Creating admin...")
    r = requests.post(f"{MB_URL}/api/setup", json={
        "token": token,
        "user": {"first_name": "Admin", "last_name": "AQI", "email": EMAIL, "password": PASS},
        "prefs": {"site_name": "AQI Global Dashboard", "site_locale": "fr", "allow_tracking": False}
    })
    if r.status_code == 200:
        print("Admin created")
        return r.json()["id"]
    raise Exception(f"Setup failed: {r.text}")

def add_database(session_id):
    dbs = requests.get(f"{MB_URL}/api/database", headers={"X-Metabase-Session": session_id}).json()
    for db in dbs.get("data", []):
        if not db.get("is_sample"):
            print(f"DB exists: {db['name']} (ID {db['id']})")
            return db["id"]
    print("Connecting Neon...")
    r = requests.post(f"{MB_URL}/api/database", headers={"X-Metabase-Session": session_id, "Content-Type": "application/json"}, json={
        "engine": "postgres",
        "name": "AQI Warehouse",
        "details": {
            "host": NEON_HOST,
            "port": int(NEON_PORT) if NEON_PORT else 5432,
            "dbname": NEON_DB,
            "user": NEON_USER,
            "password": NEON_PASS,
            "ssl": True,
            "tunnel-enabled": False,
            "advanced-options": False,
        }
    })
    if r.status_code == 200:
        print(f"Neon connected (DB ID {r.json()['id']})")
        return r.json()["id"]
    raise Exception(f"DB connect failed: {r.text}")

def create_cards(db_id, session_id):
    cards = [
        {"name": "AQI Moyen", "q": "SELECT ROUND(AVG(aqi), 1) AS aqi_moyen FROM aqi_measurements;", "display": "scalar", "vs": {"scalar.field": "aqi_moyen"}},
        {"name": "AQI Maximum", "q": "SELECT MAX(aqi) AS aqi_maximum FROM aqi_measurements;", "display": "scalar", "vs": {"scalar.field": "aqi_maximum"}},
        {"name": "Mesures", "q": "SELECT COUNT(*) AS total_mesures FROM aqi_measurements;", "display": "scalar", "vs": {"scalar.field": "total_mesures"}},
        {"name": "Villes", "q": "SELECT COUNT(DISTINCT city) AS nb_villes FROM aqi_measurements;", "display": "scalar", "vs": {"scalar.field": "nb_villes"}},
        {"name": "Tendance AQI", "q": "SELECT DATE_TRUNC('month', date)::DATE AS mois, ROUND(AVG(aqi), 1) AS aqi_moyen FROM aqi_measurements GROUP BY DATE_TRUNC('month', date) ORDER BY mois;", "display": "line", "vs": {"graph.dimensions": ["mois"], "graph.metrics": ["aqi_moyen"], "graph.colors": ["#4263EB"], "graph.show_trendline": True}},
        {"name": "AQI par Ville", "q": "SELECT city, country, ROUND(AVG(aqi), 1) AS aqi_moyen FROM aqi_measurements GROUP BY city, country ORDER BY aqi_moyen DESC;", "display": "bar", "vs": {"graph.dimensions": ["city"], "graph.metrics": ["aqi_moyen"], "graph.colors": ["#0CA678"], "graph.show_values": True}},
        {"name": "Qualit\u00e9 Air", "q": "SELECT category, COUNT(*) AS nb_jours, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pourcentage FROM aqi_measurements GROUP BY category ORDER BY MIN(aqi);", "display": "pie", "vs": {"pie.dimension": "category", "pie.metric": "nb_jours", "pie.show_labels": True}},
        {"name": "Polluants", "q": "SELECT EXTRACT(YEAR FROM date)::INT AS annee, ROUND(AVG(pm25), 2) AS pm25, ROUND(AVG(pm10), 2) AS pm10, ROUND(AVG(no2), 2) AS no2, ROUND(AVG(so2), 2) AS so2, ROUND(AVG(co), 2) AS co, ROUND(AVG(o3), 2) AS o3 FROM aqi_measurements GROUP BY EXTRACT(YEAR FROM date) ORDER BY annee;", "display": "bar", "vs": {"graph.dimensions": ["annee"], "graph.metrics": ["pm25", "pm10", "no2", "so2", "co", "o3"], "stackable.stack_type": "stacked", "graph.colors": ["#4263EB","#1098AD","#2F9E44","#E67700","#E03131","#7048E8"], "graph.series_labels": {"pm25":"PM2.5","pm10":"PM10","no2":"NO2","so2":"SO2","co":"CO","o3":"O3"}}},
        {"name": "Carte AQI", "q": "SELECT city, country, ROUND(latitude, 4) AS latitude, ROUND(longitude, 4) AS longitude, ROUND(AVG(aqi), 1) AS aqi_moyen, COUNT(*) AS nb_mesures FROM aqi_measurements GROUP BY city, country, latitude, longitude ORDER BY aqi_moyen DESC;", "display": "map", "vs": {"map.type": "pin", "map.latitude_column": "latitude", "map.longitude_column": "longitude", "map.metric": "aqi_moyen", "map.pin_style": "circle"}},
        {"name": "Filtre Ville", "q": "SELECT DISTINCT city FROM aqi_measurements ORDER BY city;", "display": "category", "vs": {}},
        {"name": "Filtre Cat\u00e9gorie", "q": "SELECT DISTINCT category FROM aqi_measurements ORDER BY category;", "display": "category", "vs": {}},
        {"name": "Tableau D\u00e9tail", "q": "SELECT city, country, EXTRACT(YEAR FROM date)::INT AS annee, ROUND(AVG(aqi), 1) AS aqi_moyen FROM aqi_measurements GROUP BY city, country, annee ORDER BY city, annee;", "display": "table", "vs": {"table.columns": [{"name":"city","fieldRef":["field","city",{"base-type":"type/Text"}],"enabled":True},{"name":"country","fieldRef":["field","country",{"base-type":"type/Text"}],"enabled":False},{"name":"annee","fieldRef":["field","annee",{"base-type":"type/Integer"}],"enabled":True},{"name":"aqi_moyen","fieldRef":["field","aqi_moyen",{"base-type":"type/Float"}],"enabled":True}], "table.pivot": True, "table.pivot_column": "city", "table.cell_column": "aqi_moyen"}},
    ]
    created = []
    for c in cards:
        r = requests.post(f"{MB_URL}/api/card", headers={"X-Metabase-Session": session_id, "Content-Type": "application/json"}, json={
            "name": c["name"], "dataset_query": {"database": db_id, "type": "native", "native": {"query": c["q"]}},
            "display": c["display"], "visualization_settings": c["vs"], "collection_id": None
        })
        if r.status_code in (200, 201):
            cid = r.json()["id"]
            created.append(cid)
            print(f"  Card '{c['name']}' (ID {cid})")
        else:
            print(f"  FAIL '{c['name']}': {r.status_code}")
    return created

def create_dashboard(card_ids, session_id):
    r = requests.post(f"{MB_URL}/api/dashboard", headers={"X-Metabase-Session": session_id, "Content-Type": "application/json"}, json={
        "name": "AQI Dashboard", "description": "Surveillance de la qualit\u00e9 de l'air", "collection_id": None
    })
    dash_id = r.json()["id"]
    print(f"Dashboard ID {dash_id}")

    layout = [
        (0, 0, 0, 5, 3), (1, 0, 7, 4, 3), (2, 0, 13, 5, 3), (3, 0, 20, 4, 3),
        (4, 4, 0, 14, 7), (6, 4, 15, 9, 7),
        (5, 12, 0, 12, 7), (7, 12, 13, 11, 7),
        (8, 20, 0, 24, 9),
        (9, 30, 0, 5, 3), (10, 30, 6, 5, 3), (11, 30, 13, 11, 4),
    ]
    cards_payload = []
    for entry in layout:
        cid_idx, row, col, sx, sy = entry
        cards_payload.append({"id": -(i+1), "card_id": card_ids[cid_idx], "row": row, "col": col, "size_x": sx, "size_y": sy, "parameter_mappings": []})

    r = requests.put(f"{MB_URL}/api/dashboard/{dash_id}/cards", headers={"X-Metabase-Session": session_id, "Content-Type": "application/json"}, json={"cards": cards_payload})
    if r.status_code == 200:
        print(f"Dashboard ready! {MB_URL}/dashboard/{dash_id}")
    else:
        print(f"Layout failed: {r.text[:200]}")

if __name__ == "__main__":
    print("Waiting for Metabase...")
    props = wait_for_metabase()
    print("Metabase ready")

    sid = setup_admin(props)
    if not sid:
        r = requests.post(f"{MB_URL}/api/session", json={"username": EMAIL, "password": PASS})
        if r.status_code == 200:
            sid = r.json()["id"]
        else:
            print(f"Login failed. Manual setup required at {MB_URL}")
            sys.exit(1)

    db_id = add_database(sid)
    card_ids = create_cards(db_id, sid)
    create_dashboard(card_ids, sid)
    print("\nDone!")

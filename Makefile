.PHONY: up down init generate logs psql metabase

up:
	docker compose up -d

down:
	docker compose down

init:
	bash scripts/init-db.sh

generate:
	python3 scripts/generate_data.py

logs:
	docker compose logs -f

psql:
	docker compose exec postgres psql -U aqi_user -d aqi_warehouse

metabase:
	docker compose exec metabase java -jar /app/metabase.jar version

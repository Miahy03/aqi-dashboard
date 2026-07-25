.PHONY: setup up down init generate logs psql metabase validate

setup:
	cp -n .env.example .env 2>/dev/null || true

up:
	docker compose up -d

down:
	docker compose down

init:
	bash scripts/init-db.sh

generate:
	python3 scripts/generate_data.py

validate:
	python3 scripts/validate_data.py

logs:
	docker compose logs -f

psql:
	docker compose exec postgres psql -U aqi_user -d aqi_warehouse

metabase:
	open http://localhost:3001

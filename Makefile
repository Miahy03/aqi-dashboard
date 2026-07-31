.PHONY: setup up down analyse logs metabase

setup:
	cp -n .env.example .env 2>/dev/null || true

up:
	docker compose up -d

down:
	docker compose down

analyse:
	python3 scripts/analyse.py

logs:
	docker compose logs -f

metabase:
	open http://localhost:3001

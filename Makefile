DB_CONTAINER := wisdom-postgres
DB_IMAGE     := postgres:15
DB_PORT      := 5432
DB_HOST      := localhost
DB_USER      ?= oden
DB_PASSWORD  ?= 1124vattnaRn
DB_NAME      := wisdom
DB_URL       := postgresql://$(DB_USER):$(DB_PASSWORD)@localhost:$(DB_PORT)/$(DB_NAME)

.PHONY: db.up db.down db.logs db.psql db.migrate db.seed db.reset web.dev web.build web.lint schema.check backend.dev

db.up:
	@container_id="$$(docker ps -aq -f name=$(DB_CONTAINER))"; \
	if [ -n "$$container_id" ]; then \
		echo "Starting existing container $(DB_CONTAINER)"; \
		docker start $(DB_CONTAINER) >/dev/null; \
	else \
		echo "Creating container $(DB_CONTAINER)"; \
		docker run --name $(DB_CONTAINER) \
			-e POSTGRES_USER=$(DB_USER) \
			-e POSTGRES_PASSWORD=$(DB_PASSWORD) \
			-e POSTGRES_DB=$(DB_NAME) \
			-p $(DB_PORT):5432 \
			-d $(DB_IMAGE) >/dev/null; \
	fi
	@echo "✅ Postgres available on $(DB_URL)"

db.down:
	@docker stop $(DB_CONTAINER) >/dev/null 2>&1 && echo "Stopped $(DB_CONTAINER)" || echo "$(DB_CONTAINER) already stopped"
	@docker rm $(DB_CONTAINER)   >/dev/null 2>&1 && echo "Removed $(DB_CONTAINER)" || echo "No container to remove"

db.logs:
	@docker logs -f $(DB_CONTAINER)

db.psql:
	@PGPASSWORD=$(DB_PASSWORD) psql "$(DB_URL)"

db.migrate:
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) scripts/wait_for_db.sh
	@PGPASSWORD=$(DB_PASSWORD) psql "$(DB_URL)" -v ON_ERROR_STOP=1 -f backend/migrations/sql/001_app_schema.sql

db.seed:
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) scripts/wait_for_db.sh
	@PGPASSWORD=$(DB_PASSWORD) psql "$(DB_URL)" -v ON_ERROR_STOP=1 -f backend/migrations/sql/002_seed_dev.sql

db.reset: db.down db.up db.migrate db.seed
	@echo "✅ Database reset complete"

web.dev:
	@cd web && npm install && npm run dev

web.build:
	@cd web && npm install && npm run build

web.lint:
	@cd web && npm install && npm run lint

schema.check:
	@python3 scripts/check_schema_sync.py --diff

backend.dev:
	@bash scripts/dev_backend.sh

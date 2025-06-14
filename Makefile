.PHONY: up down build logs backend-logs frontend-logs clean

# Start all services
up:
	@echo "Starting all services..."
	docker compose up -d
	@echo "Services started!"
	@echo "Frontend: http://localhost:5173"
	@echo "Backend: http://localhost:8080"

# Stop all services
down:
	@echo "Stopping all services..."
	docker compose down

# Build services
build:
	@echo "Building services..."
	docker compose build

# View logs for all services
logs:
	docker compose logs -f

# View backend logs
backend-logs:
	docker compose logs -f backend

# View frontend logs
frontend-logs:
	docker compose logs -f frontend

# Clean up
clean:
	@echo "Cleaning up..."
	docker compose down -v
	rm -rf backend/vendor
	rm -rf frontend/node_modules
	rm -rf frontend/dist

# Restart services
restart: down up

# Enter backend container
backend-shell:
	docker compose exec backend sh

# Enter frontend container
frontend-shell:
	docker compose exec frontend sh

# Run go tests
test:
	docker compose exec backend go test ./...

# Format go code
fmt:
	docker compose exec backend go fmt ./...

# Install frontend dependencies
frontend-install:
	docker compose exec frontend npm install

# Build frontend for production
frontend-build:
	docker compose exec frontend npm run build
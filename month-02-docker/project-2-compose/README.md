# Docker Compose Full Stack Application

Complete stack with Frontend, Backend, and Database running in Docker containers.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose Network                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐   ┌──────────────┐  │
│  │   Frontend   │      │   Backend    │   │  PostgreSQL  │  │
│  │   (Nginx)    │──────│  (Node.js)   │───│  (Database)  │  │
│  │ :80          │      │ :3001        │   │ :5432        │  │
│  └──────────────┘      └──────────────┘   └──────────────┘  │
│       ▲                      │                     │           │
│       │                      │                     │           │
│    HTTP Port            Health Check           Volume          │
│                                              postgres_data     │
│                                                                │
└─────────────────────────────────────────────────────────────┘
```

## Services

### 1. PostgreSQL (Database)
- **Image**: postgres:15-alpine
- **Port**: 5432 (internal only, not exposed to host)
- **Volume**: `postgres_data:/var/lib/postgresql/data` (persistent)
- **Credentials**: 
  - User: `devops_user`
  - Password: `devops_pass`
  - Database: `devops_db`
- **Init Script**: `init.sql` (creates `users` table with sample data)
- **Health Check**: pg_isready command

### 2. Backend (Node.js API)
- **Image**: Custom Node.js image
- **Port**: 3001
- **Environment**: Production mode
- **Database Connection**: Via docker compose network to `postgres:5432`
- **Health Check**: HTTP GET `/health` endpoint
- **Dependencies**: Waits for PostgreSQL to be healthy before starting
- **Endpoints**:
  - `GET /health` — Service health status
  - `GET /api/users` — List all users
  - `POST /api/users` — Create new user (body: {name, email})
  - `GET /api/users/:id` — Get user by ID

### 3. Frontend (Nginx + Static HTML)
- **Image**: Custom Nginx image
- **Port**: 80 (publicly accessible)
- **Static Files**: HTML + CSS served by Nginx
- **Proxy**: `/api/*` requests proxied to backend:3001
- **Health Check**: HTTP GET `/health` endpoint
- **CORS**: Handled via Nginx headers

## Quick Start

### 1. Build and Start All Services

```bash
docker-compose up -d --build
```

Services will start in order:
1. PostgreSQL (waits for startup)
2. Backend (waits for PostgreSQL to be healthy)
3. Frontend (starts last)

### 2. Verify All Services

```bash
# Check running containers
docker-compose ps

# Check service health
docker-compose exec backend curl http://localhost:3001/health
docker-compose exec frontend curl http://localhost/health
docker-compose exec postgres pg_isready -U devops_user
```

### 3. Access the Application

- **Frontend**: http://localhost
- **Backend API**: http://localhost:3001/api/users
- **PostgreSQL**: localhost:5432 (not exposed, access only from backend)

## Key Features

### Health Checks
Each service has a health check configured:
- **PostgreSQL**: `pg_isready` command
- **Backend**: HTTP GET to `/health` endpoint
- **Frontend**: HTTP GET to `/health` endpoint

View health status:
```bash
docker-compose ps
# HEALTH column shows: healthy, starting, unhealthy
```

### Service Dependencies
Services start in dependency order:
```yaml
backend:
  depends_on:
    postgres:
      condition: service_healthy  # Wait until healthy!
```

### Networking
All services communicate via Docker bridge network `devops-network`:
- Frontend → Backend: `http://backend:3001`
- Backend → PostgreSQL: `postgres:5432`

### Volumes
Persistent storage for database:
```yaml
volumes:
  postgres_data:/var/lib/postgresql/data
```

Data persists even if containers are stopped/removed.

## Database Schema

Table `users`:
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Sample data inserted on first run:
- Alice Johnson (alice@example.com)
- Bob Smith (bob@example.com)
- Charlie Brown (charlie@example.com)

## Common Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f postgres

# Execute commands in containers
docker-compose exec backend npm start
docker-compose exec postgres psql -U devops_user -d devops_db

# Rebuild images
docker-compose build

# Remove volumes (delete persistent data)
docker-compose down -v
```

## Troubleshooting

### Backend can't connect to PostgreSQL
```bash
# Check PostgreSQL health
docker-compose exec postgres pg_isready -U devops_user

# Check Backend logs
docker-compose logs backend
```

### Frontend can't reach Backend API
```bash
# Test connectivity from Frontend
docker-compose exec frontend curl http://backend:3001/health

# Check Nginx config
docker-compose logs frontend
```

### Database is empty
```bash
# Re-initialize from init.sql
docker-compose down -v
docker-compose up -d
```

## Production Considerations

⚠️ This is a learning example. For production:
- Use `.env` file instead of hardcoded passwords
- Enable SSL/TLS (use reverse proxy)
- Use managed databases instead of containers
- Implement proper authentication and authorization
- Add resource limits (memory, CPU)
- Implement logging and monitoring
- Use secrets management (AWS Secrets Manager, etc.)

# Docker Deployment Guide

## Quick Start

### Development with Docker Compose

```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f platform

# Stop services
docker-compose down

# Stop and remove volumes (WARNING: deletes database)
docker-compose down -v
```

The API will be available at `http://localhost:4000`

Routes:
- `POST /register` - User registration
- `POST /login` - User authentication

### Production Deployment

#### 1. Build the Docker image

```bash
docker build -t platform:latest .
```

#### 2. Generate a secret key

```bash
# Generate with mix (requires Elixir installed)
mix phx.gen.secret

# Or generate with openssl
openssl rand -base64 48
```

#### 3. Run with Docker

```bash
docker run -d \
  --name platform \
  -p 4000:4000 \
  -e DATABASE_URL=ecto://user:pass@postgres_host/lnm3_platform \
  -e SECRET_KEY_BASE=your_generated_secret_here \
  -e PHX_HOST=your-domain.com \
  -e CORS_ORIGINS=https://your-domain.com \
  platform:latest
```

## Environment Variables

### Required in Production

- `DATABASE_URL`: PostgreSQL connection string
  - Format: `ecto://user:pass@host:port/database`
  - Example: `ecto://platform:securepass@db.example.com:5432/lnm3_platform`

- `SECRET_KEY_BASE`: Secret for signing/encrypting cookies and tokens
  - Generate with: `mix phx.gen.secret` or `openssl rand -base64 48`
  - Must be at least 64 characters

- `PHX_HOST`: Your domain name
  - Example: `api.yourdomain.com`

### Optional

- `PORT`: Port to bind (default: `4000`)
- `CORS_ORIGINS`: Comma-separated list of allowed origins
  - Example: `https://app.example.com,https://www.example.com`
- `POOL_SIZE`: Database connection pool size (default: `10`)
- `ECTO_IPV6`: Enable IPv6 for Ecto (`true` or `false`)

## Database Migrations

### On first deployment

```bash
# Run migrations
docker exec -it platform bin/platform eval "Platform.Release.migrate()"

# Run seeds (optional)
docker exec -it platform bin/platform eval "Platform.Release.seed()"
```

### Create release tasks

Add to `lib/platform/release.ex`:

```elixir
defmodule Platform.Release do
  @moduledoc """
  Tasks to run in production releases
  """
  @app :platform

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _repo ->
        Code.eval_file("priv/repo/seeds.exs")
      end)
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
```

Then you can run:

```bash
# Migrate
docker exec platform bin/platform eval "Platform.Release.migrate()"

# Seed
docker exec platform bin/platform eval "Platform.Release.seed()"

# Rollback
docker exec platform bin/platform eval "Platform.Release.rollback(Platform.Repo, 20260105134906)"
```

## Health Check

The container includes a health check that pings the root endpoint:

```bash
# Check container health
docker ps

# Manual health check
curl http://localhost:4000/

# Test specific endpoints
curl -X POST http://localhost:4000/register \
  -H "Content-Type: application/json" \
  -d '{"user":{"username":"test","email":"test@example.com","password":"password123"}}'

curl -X POST http://localhost:4000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## Logs

```bash
# View logs
docker logs platform

# Follow logs
docker logs -f platform

# Last 100 lines
docker logs --tail 100 platform
```

## Docker Compose Configuration

The `docker-compose.yml` includes:
- PostgreSQL 16 with health check
- Automatic database initialization
- Volume for data persistence
- Proper dependency ordering (platform waits for db)

## Security Best Practices

1. **Never use default secrets in production**
   - Generate unique `SECRET_KEY_BASE`
   - Use strong database passwords

2. **Use HTTPS in production**
   - Set `CORS_ORIGINS` to HTTPS URLs only
   - Place behind a reverse proxy (nginx, Caddy, Traefik)

3. **Restrict database access**
   - Don't expose PostgreSQL port publicly
   - Use Docker networks for service communication

4. **Regular updates**
   - Keep base images updated
   - Update dependencies regularly

## Troubleshooting

### Database connection issues

```bash
# Check if database is reachable
docker exec platform ping db

# Test database connection
docker exec platform bin/platform remote
```

### View Elixir console

```bash
docker exec -it platform bin/platform remote
```

### Reset database (development only)

```bash
docker-compose down -v
docker-compose up
```

## Multi-stage Build

The Dockerfile uses a multi-stage build:
1. **Build stage**: Compiles the application with all build tools
2. **Runtime stage**: Minimal Alpine image with only runtime dependencies

This results in a much smaller final image (~50MB vs ~500MB).

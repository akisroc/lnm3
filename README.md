# LNM3 Project

Multi-service application with Phoenix backend and frontend.

## Architecture

```
lnm3/
└── services/
    ├── frontend/          # Frontend applications (Nuxt app)
    ├── platform/          # Platform API (Elixir/Phoenix/PostgreSQL)
    └── archive/           # Archive API (PHP/Symfony/SQLite)
```

## Quick Start

### Prerequisites

- Docker & Docker Compose
- (Optional) Elixir 1.15+ for local development

### Start All Services

```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Services

| Service | Port | Description |
|---------|------|-------------|
| **platform** | 4000 | Phoenix API backend |
| **db-platform** | 5432 | PostgreSQL database |
| **adminer** | 8081 | Database admin UI |

### API Endpoints

**Platform API** - `http://localhost:4000`

```bash
# Register a new user
curl -X POST http://localhost:4000/register \
  -H "Content-Type: application/json" \
  -d '{"user":{"username":"john","email":"john@example.com","password":"password123"}}'

# Login
curl -X POST http://localhost:4000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"password123"}'
```

### Database Access

**Adminer** - `http://localhost:8081`
- System: PostgreSQL
- Server: `db-platform`
- Username: `user`
- Password: `pass`
- Database: `lnm3_platform`

## Development

### Platform Service (Phoenix)

See [services/platform/README.md](services/platform/README.md) for detailed documentation.

```bash
cd services/platform

# Local development (without Docker)
mix deps.get
mix ecto.setup
mix phx.server

# Run tests
mix test

# Docker development
docker-compose up
```

### Environment Variables

Create a `.env` file at the root for custom configuration:

```bash
# Platform
SECRET_KEY_BASE=your_secret_key_here
PHX_HOST=localhost
CORS_ORIGINS=http://localhost:8000,http://localhost:3000
```

Generate a secret key:
```bash
cd services/platform
mix phx.gen.secret
```

## Production Deployment

### Using Docker Compose

```bash
# Set environment variables
export SECRET_KEY_BASE=$(cd services/platform && mix phx.gen.secret)
export PHX_HOST=api.yourdomain.com
export CORS_ORIGINS=https://yourdomain.com

# Build and start
docker-compose build
docker-compose up -d

# Run migrations
docker-compose exec platform bin/platform eval "Platform.Release.migrate()"
```

### Individual Services

Each service can be deployed independently. See service-specific documentation:
- [Platform Service Docker Guide](services/platform/DOCKER_README.md)

## Project Status

### Implemented
- ✅ User registration & authentication
- ✅ Session management with secure tokens
- ✅ CORS configuration
- ✅ Database migrations & seeds
- ✅ Comprehensive test suite (30+ tests)
- ✅ Docker & Docker Compose setup

### In Progress
- 🚧 Frontend integration
- 🚧 Authentication middleware
- 🚧 Protected routes

## License

[Add your license here]

# LNM3

> **Note**
> 
> While _Le Nouveau Monde_’s community is french speaking, let’s
> keep the codebase in english by convention.

LNM rebirth. (:

Historcally a PHP project, this rebirth runs on an
Elixir/Phoenix/PostgreSQL backend (REST API), a Nuxt
frontend, and some PHP/Symfony to serve the legacy
forum archives.

---

## Project technical overview

### Project structure

```directory
lnm3/
├── .env.example                # Example environment variables
├── docker-compose.yml          # Local development orchestration
├── Makefile                    # Makefile for local development
├── infrastructure/
│   ├── database/               # PostgreSQL database 
│   └── reverse_proxy/          # Traefik reverse proxy
└── services/
    ├── archive/                # Archive API (PHP/Symfony/SQLite)
    ├── frontend/               # Nuxt frontend (Bun runtime)
    └── platform/               # Platform API (Elixir/Phoenix/PostgreSQL)
```

All bricks in `infrastructure/` and `services/` have Dockerfiles.

Depending on the final deployment target, `infrastructure/` might
not be handled through Docker though. At this stage of the project,
LNM3 will likely be deployed on an OVH VPS under Coolify, so only
`services/` would be containerized in this scenario.

### Networking & routing

Traefik is used as reverse proxy.

Internal communications follow this schema:

```
Traefik
├── domain.example ───────────── lnm3_frontend:3000   # Frontend app
├── platform.domain.example ──── lnm3_platform:4000   # Platform API
    └── lnm3_database:5432                            # Postgres DB
└── archive.domain.example ───── lnm3_archive:9000    # Archive API
```

```mermaid
graph TD
%% Internet
    Internet((Internet))

%% Networks
    subgraph front_network [front_network]
        Traefik[Traefik Proxy]
        Frontend[lnm3_frontend:3000]
        Archive[lnm3_archive:9000]
        Platform[lnm3_platform:4000]
    end

    subgraph database_network [database_network]
        Database[(lnm3_database:5432)]
        Platform_DB_Interface[lnm3_platform]
    end

%% External Routing
    Internet -->|domain.example| Traefik
    Internet -->|platform.domain.example| Traefik
    Internet -->|archive.domain.example| Traefik

%% HTTP Proxying
    Traefik -.-> Frontend
    Traefik -.-> Platform
    Traefik -.-> Archive

%% Database Internal Link
    Platform <-->|Internal Port 5432| Database

%% Styling
    style front_network fill:#fff9c4,stroke:#fbc02d,stroke-dasharray: 5 5
    style database_network fill:#ffcdd2,stroke:#e53935,stroke-dasharray: 5 5
    style Platform fill:#e3f2fd,stroke:#1976d2,stroke-width:4px
    style Database fill:#f5f5f5
```

The database communicates only with the Platform service through
a shared `database_network`. It is isolated from the reverse
proxy’s `front_network` and the external world.

So services are accessed through the following URLs:

| Service          | URL                             | Description                       |
|------------------|---------------------------------|-----------------------------------|
| **Frontend**     | https://www.domain.example      | Nuxt frontend application         |
| **Platform API** | https://platform.domain.example | Phoenix API backend               |
| **Archive API**  | https://archive.domain.example  | Legacy forum archives (read-only) |

In development environment, the following URLs should work by
default:

- http://localhost
- http://platform.localhost
- http://archive.localhost
- http://localhost:8080/dashboard

Maybe check your `/etc/hosts` if something doesn’t work as expected.

> **Note**
> 
> While the two REST APIs (Platform and Archive) are openly exposed
> to the world – and are meant to be that way –, in reality they act
> as a backend and will be mostly consumed by the frontend. I don’t
> expect that much direct traffic to them.

> **Note**
> 
> Traefik exposes its `localhost:8080/dashboard` in the `dev`
> Docker stage **only**.
> 
> This is obviously not to be deployed in production.

---

### Database structure

```mermaid
---
title: LNM3 platform database schema
---
erDiagram
    USERS ||--o{ SHOUTS : "sends"
    USERS ||--o{ KINGDOMS : "owns"
    USERS ||--o{ PROTAGONISTS : "plays"
    USERS ||--o{ CHRONICLES : "masters"
    USERS ||--o{ BOARDS : "creates"
    USERS ||--o{ THREADS : "starts"
    USERS ||--o{ POSTS : "writes"
    USERS ||--o{ SESSIONS : "has"
    USERS ||--o{ CHAPTERS_VIEWS : "reads"

    KINGDOMS ||--o{ BATTLES : "attacks/defends"
    KINGDOMS ||--o{ MISSIVES : "sends/receives"
    KINGDOMS |o--o| PROTAGONISTS : "led_by"

    PROTAGONISTS ||--o{ WHISPERS : "sends/receives"
    PROTAGONISTS ||--o{ PROTAGONISTS_CHRONICLES : "participates"
    PROTAGONISTS ||--o{ CHAPTERS : "writes"

    CHRONICLES ||--o{ PROTAGONISTS_CHRONICLES : "includes"
    CHRONICLES ||--o{ CHAPTERS : "contains"
    
    BOARDS ||--o{ THREADS : "contains"
    THREADS ||--o{ POSTS : "contains"
    CHAPTERS ||--o{ CHAPTERS_VIEWS : "viewed_by"

    USERS {
        uuid id PK
        varchar nickname
        varchar email
        varchar slug
        platform_theme_enum platform_theme
        bool is_enabled
        bool is_removed
        timestamp inserted_at
    }

    PROTAGONISTS {
        uuid id PK
        uuid user_id FK
        uuid kingdom_id FK
        varchar name
        numeric fame
        bool is_anonymous
        bool is_removed
    }

    KINGDOMS {
        uuid id PK
        uuid user_id FK
        uuid leader_id FK
        varchar name
        numeric fame
        integer_array defense_troop
        integer_array attack_troop
        bool is_active
        bool is_removed
    }

    SHOUTS {
        uuid id PK
        uuid user_id FK
        text content
        timestamp inserted_at
    }

    WHISPERS {
        uuid id PK
        uuid sender_id FK
        uuid receiver_id FK
        text content
        bool is_read
        timestamp inserted_at
    }

    MISSIVES {
        uuid id PK
        uuid sender_id FK
        uuid receiver_id FK
        text content
        bool is_read
        timestamp inserted_at
    }

    BATTLES {
        uuid id PK
        uuid attacker_kingdom_id FK
        uuid defender_kingdom_id FK
        integer_array attacker_initial_troop
        integer_array defender_initial_troop
        jsonb log
        bool attacker_wins
        numeric attacker_fame_modifier
        numeric defender_fame_modifier
    }

    CHRONICLES {
        uuid id PK
        uuid gm_id FK
        uuid user_id FK
        varchar title
        varchar slug
        bool is_removed
    }

    CHAPTERS {
        uuid id PK
        uuid chronicle_id FK
        uuid protagonist_id FK
        text content
        timestamp inserted_at
    }

    THREADS {
        uuid id PK
        uuid user_id FK
        uuid board_id FK
        varchar title
        varchar slug
        bool is_removed
    }

    POSTS {
        uuid id PK
        uuid user_id FK
        uuid thread_id FK
        text content
        timestamp inserted_at
    }

    SESSIONS {
        uuid id PK
        uuid user_id FK
        bytea token
        inet ip_address
        varchar user_agent
        timestamp expires_at
    }
```

Some points:
- Keys are UUIDv7 generated in code.
- Passwords use Argon2id hash.

## Development

### Prerequisites

- `docker` & `docker compose`
- `make`

### Setup

The following command should put you on the rails with
the whole default dev environment:

```bash
make setup
```

It will copy the `.env.example` file into a newly
created `.env`. You can customize it if needed, `docker compose`
will read it.

### Git worklow

`master` is the main branch. It should be stable and tested.
It receives PRs from development sub-branches or forks.

When a release is ready, `master` is merged into `release` with
`--no-ff`, and that merge commit is tagged with a version number
following [SemVer](https://semver.org/) convention.

```text
release  ________*(v1.2.0)___________*(v1.2.1)_______*(v1.2.2)__
                /                   /               /
master   ______*_____*_____________*_______*_______*____________
              / \   /             /       / \     /
feature  ____/   \_/             /       /   \___/
                                /       /
hotfix   ______________________/_______/
```

## Production Deployment

🚧 Todo

## License

[GNU GPL v3](LICENSE)

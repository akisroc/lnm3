# --- BASE STAGE ---
FROM elixir:1.19-alpine AS base

RUN apk add --no-cache build-base git

WORKDIR /app

RUN set -eux; \
    mix local.hex --force; \
    mix local.rebar --force;

# --- DEV STAGE ---
FROM base AS dev
ENV MIX_ENV=dev

RUN apk add --no-cache inotify-tools curl netcat-openbsd

COPY mix.exs mix.lock ./
RUN mix deps.get

COPY . .

RUN chmod +x scripts/wait-for-db.sh

CMD ["scripts/wait-for-db.sh", "lnm3_database", "--", "sh", "-c", "mix ecto.migrate && mix phx.server"]

HEALTHCHECK --interval=10s --timeout=2s --start-period=30s --retries=3 \
  CMD nc -z 127.0.0.1 4000 || exit 1

CMD ["mix", "phx.server"]

# --- BUILDER STAGE ---
FROM base AS builder
ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN set -eux; \
    mix deps.get --only prod; \
    mix deps.compile;

COPY config config
COPY assets assets
COPY priv priv
COPY lib lib

RUN set -eux; \
    mix assets.deploy; \
    mix compile; \
    mix release;

# --- PROD STAGE ---
FROM alpine:3.23 AS prod
ENV MIX_ENV=prod
ENV HOME=/app
ENV PHX_SERVER=true

RUN apk add --no-cache libstdc++ openssl ncurses-libs ca-certificates netcat-openbsd

COPY --from=builder --chown=1000:1000 /app/_build/prod/rel/platform ./

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD nc -z 127.0.0.1 4000 || exit 1

USER 1000
EXPOSE 4000

CMD ["bin/platform", "start"]

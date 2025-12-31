# --- COMMON ---
FROM elixir:1.19-alpine AS base
RUN apk add --no-cache build-base git
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force

# --- DEV ---
FROM base AS dev
ENV MIX_ENV=dev
CMD ["mix", "run", "--no-halt"]

# --- PROD BUILDER ---
FROM base AS builder
ENV MIX_ENV=prod
COPY . .
RUN mix deps.get --only prod && mix release

# --- FINAL PROD IMAGE ---
FROM alpine:3.23 AS prod
RUN apk add --no-cache libstdc++ openssl ncurses-libs
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/battle .
EXPOSE 50051
CMD ["bin/battle", "start"]

# --- BASE STAGE ---
FROM oven/bun:1.3-alpine AS base
WORKDIR /app

# --- DEV STAGE ---
FROM base AS dev
ENV NODE_ENV=development

RUN apk add --no-cache netcat-openbsd

COPY package.json bun.lock* ./
RUN bun install
COPY . .

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD nc -z 127.0.0.1 3000 || exit 1

CMD ["bun", "run", "dev", "--host", "0.0.0.0", "--port", "3000"]

# --- BUILDER STAGE ---
FROM base AS builder
ENV NODE_ENV=production

COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile

COPY . .

RUN bun run build

# --- PROD STAGE ---
FROM alpine:3.23 AS prod
ENV NODE_ENV=production
ENV PORT=3000

RUN apk add --no-cache libstdc++ ca-certificates netcat-openbsd

RUN set -eux; \
    addgroup -S bun; \
    adduser -S bun -G bun;

COPY --from=base /usr/local/bin/bun /usr/local/bin/bun

WORKDIR /app

COPY --from=builder /app/.output ./.output

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD nc -z 127.0.0.1 3000 || exit 1

USER bun
EXPOSE 3000

CMD ["bun", ".output/server/index.mjs"]

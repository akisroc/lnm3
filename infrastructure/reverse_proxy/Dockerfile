# --- BASE STAGE ---
FROM traefik:3.6 AS base

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
  CMD traefik healthcheck || exit 1

EXPOSE 80

# --- DEV STAGE ---
FROM base AS dev

CMD ["traefik", \
     "--api.insecure=true", \
     "--api.dashboard=true", \
     "--providers.docker=true", \
     "--providers.docker.exposedbydefault=false", \
     "--entrypoints.web.address=:80", \
     "--log.level=DEBUG"]

EXPOSE 8080

## --- PROD STAGE ---
FROM base AS prod

LABEL org.opencontainers.image.description="LNM3 Reverse Proxy"

CMD ["traefik"]

EXPOSE 443

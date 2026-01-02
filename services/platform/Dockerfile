# --- COMMON ---
FROM dunglas/frankenphp:1.3-php8.4-alpine AS base

RUN apk add --no-cache bash icu-dev libzip-dev zip \
    && install-php-extensions pdo_pgsql intl zip opcache apcu ctype iconv

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp

WORKDIR /app

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --- DEV ---
FROM base AS dev
ENV APP_ENV=dev

RUN install-php-extensions xdebug

CMD ["frankenphp", "run", "--config", "/config/caddy/Caddyfile", "--watch"]

# --- BUILDER ---
FROM base AS builder
COPY . .
RUN composer install --no-dev --optimize-autoloader --no-scripts

# --- FINAL PROD IMAGE ---
FROM base AS prod
ENV APP_ENV=prod
ENV APP_DEBUG=0

COPY --from=builder /app .

RUN php bin/console cache:clear --env=prod \
    && php bin/console cache:warmup --env=prod

ENV FRANKENPHP_CONFIG="worker ./public/index.php"

EXPOSE 80
EXPOSE 443

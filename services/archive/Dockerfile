# --- BASE STAGE ---
FROM php:8.4-fpm-alpine AS base

# Runtime deps
RUN apk add --no-cache icu-libs libpq libzip file git fcgi

# Build (install deps, compile, clean)
RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
      icu-dev libpq-dev libzip-dev zlib-dev $PHPIZE_DEPS; \
    docker-php-ext-install intl pdo pdo_pgsql zip opcache; \
    pecl install apcu; \
    docker-php-ext-enable apcu opcache; \
    apk del .build-deps;

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

WORKDIR /app

# --- DEV STAGE ---
FROM base AS dev
ENV APP_ENV=dev

RUN apk add --no-cache $PHPIZE_DEPS linux-headers curl netcat-openbsd

RUN set -eux; \
    pecl install xdebug; \
    docker-php-ext-enable xdebug;
ENV XDEBUG_MODE=debug

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD nc -z 127.0.0.1 8000 || exit 1

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]

# --- BUILDER STAGE ---
FROM base AS builder
ENV APP_ENV=prod

COPY composer.json composer.lock symfony.lock ./
RUN set -eux; \
    composer install --no-cache --no-dev --no-scripts \
                     --no-autoloader --no-progress \
                     --prefer-dist;

COPY . .

RUN set -eux; \
    mkdir -p var/cache var/log var/share; \
    composer dump-autoload --no-dev --classmap-authoritative; \
    composer dump-env prod; \
    composer run-script --no-dev post-install-cmd; \
    chmod +x bin/console; sync;

# --- PROD STAGE ---
FROM base AS prod
ENV APP_ENV=prod
ENV APP_DEBUG=0

RUN set -eux; \
    echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf

COPY --from=builder --chown=www-data:www-data /app /app

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY docker/php/opcache.ini $PHP_INI_DIR/app.conf.d/opcache.ini

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD SCRIPT_NAME=/status SCRIPT_FILENAME=/status REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

USER www-data
EXPOSE 9000
CMD ["php-fpm"]

FROM dunglas/frankenphp:latest-alpine

RUN apk add --no-cache python3 py3-pip sqlite bash
RUN python3 -m venv /opt/datasette-venv
RUN /opt/datasette-venv/bin/pip install datasette

RUN install-php-extensions pdo_sqlite

ENV SERVER_NAME=:8100
ENV FRANKENPHP_CONFIG="worker /app/public/index.php"

WORKDIR /app
COPY . .

RUN echo '#!/bin/sh\n\
/opt/datasette-venv/bin/datasette /app/data/lnm_archive.db --host 0.0.0.0 --port 8101 --immutable &\n\
exec frankenphp run --config /etc/caddy/Caddyfile' > /usr/local/bin/start-app.sh && chmod +x /usr/local/bin/start-app.sh

EXPOSE 8100 8101

CMD ["/usr/local/bin/start-app.sh"]

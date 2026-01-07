# Build stage
FROM hexpm/elixir:1.17.3-erlang-27.1.2-alpine-3.20.3 AS build

# Install build dependencies
RUN apk add --no-cache build-base git curl

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build environment
ENV MIX_ENV=prod

# Copy dependency files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy application code
COPY config config
COPY lib lib
COPY priv priv

# Compile application
RUN mix compile

# Create release
RUN mix release

# Runtime stage
FROM alpine:3.20.3

# Install runtime dependencies
RUN apk add --no-cache \
    ncurses-libs \
    libstdc++ \
    libgcc \
    openssl

# Create non-root user
RUN addgroup -g 1000 platform && \
    adduser -D -u 1000 -G platform platform

WORKDIR /app

# Copy release from build stage
COPY --from=build --chown=platform:platform /app/_build/prod/rel/platform ./

# Switch to non-root user
USER platform

# Expose port
EXPOSE 4000

# Set environment variables
ENV HOME=/app \
    PHX_SERVER=true

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:4000/ || exit 1

# Start the application
CMD ["bin/platform", "start"]

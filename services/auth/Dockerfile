# --- COMMON ---
FROM golang:1.25-alpine AS base
RUN apk add --no-cache git
WORKDIR /app
# Install hot reload
RUN go install github.com/cosmtrek/air@latest
COPY go.mod go.sum ./
RUN go mod download

# --- DEV ---
FROM base AS dev
ENV GO_ENV=dev
COPY . .
CMD ["air", "-c", ".air.toml"]

# --- PROD BUILDER ---
FROM base AS builder
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/auth main.go

# --- FINAL PROD IMAGE ---
FROM alpine:3.18 AS prod
RUN apk add --no-cache ca-certificates
WORKDIR /root/
COPY --from=builder /app/auth .
EXPOSE 50051
CMD ["./auth"]

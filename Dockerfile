# ─── Builder: Go backend ─────────────────────────────────────────────────────
FROM golang:1.23-alpine AS builder_go
WORKDIR /app

# Install git (for modules) and ca-certificates for SSL
RUN apk add --no-cache git ca-certificates

# Copy module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy entire codebase (including server/ctrl/static)
COPY . ./

# Build static binary (embed will pick up static/www, static/404.html, etc.)
RUN CGO_ENABLED=0 \
    go build \
    -ldflags "-s -w" \
    -o filestash \
    ./cmd/main.go

# ─── Builder: Frontend assets ─────────────────────────────────────────────────
FROM node:18-alpine AS builder_frontend
WORKDIR /app
RUN apk add --no-cache git
# Copy client code and build
COPY client/ ./client/
WORKDIR /app/client
RUN npm install --legacy-peer-deps && npm run build

# ─── Final: Minimal runtime ────────────────────────────────────────────────────
FROM alpine:3.17 AS runtime
# SSL support
RUN apk add --no-cache ca-certificates

WORKDIR /root/
# Copy Go binary
COPY --from=builder_go /app/filestash ./filestash
# Copy builtin static files (404, loader) and www content
COPY --from=builder_go /app/server/ctrl/static ./server/ctrl/static
# Copy public frontend assets
COPY --from=builder_frontend /app/client/public ./public

# Expose default port
EXPOSE 8334

# Launch
ENTRYPOINT ["./filestash"]
CMD ["--config", "./config/config.json"]
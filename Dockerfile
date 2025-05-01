# ─── Builder: Go backend using vendored dependencies ─────────────────────────
FROM golang:1.23-alpine AS builder_go
WORKDIR /app

# 1) Copy module definition and vendored deps
COPY go.mod go.sum ./
COPY vendor/ ./vendor

# 2) Copy source code (including cmd/, server/, etc.)
COPY . ./

# 3) Build static binary using vendor folder
RUN CGO_ENABLED=0 GOFLAGS="-mod=vendor" \
    go build -o filestash ./cmd/main.go

# ─── Builder: Frontend assets build ────────────────────────────────────────────
FROM node:18-alpine AS builder_frontend
WORKDIR /app

# Copy everything and install dependencies
COPY . ./
RUN npm install --legacy-peer-deps

# Build the frontend (adjust if your build command differs)
RUN npm run build

# ─── Final runtime image ──────────────────────────────────────────────────────
FROM alpine:3.17

# Include CA certs for HTTPS support
RUN apk add --no-cache ca-certificates
WORKDIR /root/

# Copy in the Go binary
COPY --from=builder_go /app/filestash .

# Copy in the built frontend assets
COPY --from=builder_frontend /app/public ./public

# Expose the default Filestash port
EXPOSE 8334

# Launch Filestash
ENTRYPOINT ["./filestash"]
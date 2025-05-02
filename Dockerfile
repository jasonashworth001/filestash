# ─────────────────────────────────────────────────────────
# 1. Build frontend
FROM node:18 AS frontend
WORKDIR /app
COPY . .
RUN npm install && npm run build

# ─────────────────────────────────────────────────────────
# 2. Build backend
FROM golang:1.23 AS backend
WORKDIR /app
COPY --from=frontend /app /app
RUN make go-prod

# ─────────────────────────────────────────────────────────
# 3. Final runtime image
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=backend /app/filestash /app/filestash
EXPOSE 8334
CMD ["/app/filestash"]

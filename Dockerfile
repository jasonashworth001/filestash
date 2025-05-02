FROM golang:latest as builder

WORKDIR /app

# Copy source
COPY . .

# Ensure Go modules are enabled
ENV GO111MODULE=on

# Build with Keycloak support enabled via build tag
RUN go build -tags "keycloak" -o filestash ./cmd/filestash

# Final image
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the built binary
COPY --from=builder /app/filestash /app/filestash

# Expose the web server port
EXPOSE 8334

# Run Filestash
CMD ["/app/filestash"]

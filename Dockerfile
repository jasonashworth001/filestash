# ---- BUILD STAGE ----
FROM golang:latest as builder

# Set working directory in the builder container
WORKDIR /app

# Copy source code into the container
COPY . .

# Build the Filestash binary with Keycloak support from the cmd directory
RUN go build -tags "keycloak" -o filestash ./cmd

# ---- RUNTIME STAGE ----
FROM debian:bookworm-slim

# Install only what's needed to run the binary
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Set working directory in runtime container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/filestash /app/filestash

# Expose default Filestash port
EXPOSE 8334

# Run the binary
CMD ["/app/filestash"]

# Stage 1: Clone full repo (with static assets)
FROM alpine/git AS clone
WORKDIR /src
ARG GIT_REPO=https://github.com/jasonashworth001/filestash
ARG GIT_BRANCH=master
RUN git clone --depth 1 --branch ${GIT_BRANCH} ${GIT_REPO} .

# Stage 2: Build
FROM golang:1.23-alpine AS builder
WORKDIR /app

# Install deps
RUN apk add --no-cache git

# Copy source code from cloned repo
COPY --from=clone /src .

# Download Go dependencies
RUN go mod download

# ✅ Build (static assets MUST be present!)
RUN CGO_ENABLED=0 go build -o filestash ./cmd/main.go

# Stage 3: Final runtime container
FROM alpine:latest
WORKDIR /app

# Copy built binary
COPY --from=builder /app/filestash .

# Copy static + other runtime files
COPY --from=builder /app/static ./static
COPY --from=builder /app/config ./config
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/data ./data

EXPOSE 8334

# ✅ Run it!
CMD ["./filestash"]

# ─── Stage 1: clone your fork ─────────────────────────────────────────────────
FROM alpine/git AS prepare
WORKDIR /app
ARG GIT_REPO=https://github.com/jasonashworth001/filestash
ARG GIT_BRANCH=master
RUN git clone --depth 1 --branch ${GIT_BRANCH} ${GIT_REPO} .

# ─── Stage 2: build Go backend ───────────────────────────────────────────────
FROM golang:1.23-alpine AS builder_go
WORKDIR /app
# copy the entire source (including server/, static/, your plugin, go.mod, etc.)
COPY --from=prepare /app . 
# compile it (this picks up all the embedded static files)
RUN CGO_ENABLED=0 go build -o filestash ./cmd/main.go

# ─── Stage 3: build frontend ────────────────────────────────────────────────
FROM node:18-alpine AS builder_frontend
WORKDIR /app/client
# copy just frontend code
COPY --from=prepare /app/client ./
RUN npm install --legacy-peer-deps && npm run build

# ─── Stage 4: assemble runtime ──────────────────────────────────────────────
FROM alpine:3.17
RUN apk add --no-cache ca-certificates
WORKDIR /root/

# bring in the compiled backend
COPY --from=builder_go /app/filestash .
# bring in the built frontend assets
COPY --from=builder_frontend /app/client/dist public

# expose your Filestash port
EXPOSE 8334

# run it!
ENTRYPOINT ["./filestash"]

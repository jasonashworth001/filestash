# ─── Builder: Go backend ───────────────────────────────────────────────────────
FROM golang:1.23-alpine AS builder_go

WORKDIR /app
# pull in dependencies
COPY go.mod go.sum ./
RUN go mod download

# bring in entire source, including server/, cmd/, plugins/, etc.
COPY . .

# compile your main.go (with plugin baked in)
RUN go build -o filestash ./cmd/main.go

# ─── Builder: Frontend ─────────────────────────────────────────────────────────
FROM node:18-alpine AS builder_frontend

WORKDIR /app/client
# adjust path if your frontend lives elsewhere
COPY client/package*.json ./
RUN npm install --legacy-peer-deps

# copy remaining client code & build
COPY client/ ./
RUN npm run build

# ─── Final runtime image ──────────────────────────────────────────────────────
FROM alpine:3.17

# for HTTPS certs
RUN apk add --no-cache ca-certificates

WORKDIR /root/

# copy in the backend binary
COPY --from=builder_go /app/filestash .

# copy in the built frontend assets
COPY --from=builder_frontend /app/client/dist ./public

# expose the default Filestash port
EXPOSE 8334

# run Filestash
ENTRYPOINT ["./filestash"]

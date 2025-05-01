FROM golang:1.23 AS builder
WORKDIR /app

# Add this line to make sure we copy .go and go.mod properly
COPY go.mod go.sum ./
RUN go mod download

COPY . ./
RUN make

FROM alpine
COPY --from=builder /app/filestash /filestash
ENTRYPOINT ["/filestash"]

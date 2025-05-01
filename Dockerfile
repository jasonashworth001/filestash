FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN make

FROM alpine
COPY --from=builder /app/filestash /filestash
ENTRYPOINT ["/filestash"]

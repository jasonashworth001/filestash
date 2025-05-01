FROM golang:latest AS builder
WORKDIR /app
COPY . .
RUN make

FROM alpine
COPY --from=builder /app/filestash /filestash
ENTRYPOINT ["/filestash"]

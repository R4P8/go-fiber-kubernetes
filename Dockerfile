FROM golang:1.25 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o go-fiber-example .

FROM ubuntu:22.04

WORKDIR /app

COPY --from=builder /app/go-fiber-example .

COPY .env .

EXPOSE 8080


CMD ["./go-fiber-example"]

FROM golang:1.22.6-alpine3.20 AS builder
WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/app .

FROM alpine:3.20.6
RUN addgroup -S app && adduser -S -G app app
WORKDIR /app

COPY --from=builder /out/app /app/app

USER app

EXPOSE 8080

CMD ["/app/app"]

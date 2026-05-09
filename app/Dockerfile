FROM golang:1.22.5-alpine3.20 AS base

WORKDIR /app

COPY go.mod ./


RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o main .

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

COPY --from=base /app/main .
COPY --from=base /app/static ./static

EXPOSE 8080

CMD ["./main"]
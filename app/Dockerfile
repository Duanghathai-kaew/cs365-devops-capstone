FROM golang:1.22.5-alpine3.20 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY main.go ./
COPY static ./static

RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \
    -trimpath \
    -o main .

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/static ./static

EXPOSE 8080

ENTRYPOINT ["./main"]
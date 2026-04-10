# shiftleft-go-demo needs CGO for github.com/gen2brain/go-unarr (libunarr).
FROM golang:1.22-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc6-dev libunarr-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-s -w" -o /shiftleft-demo .

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libunarr1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /shiftleft-demo /usr/local/bin/shiftleft-demo
COPY --from=builder /src/config ./config
COPY --from=builder /src/templates ./templates
COPY --from=builder /src/public ./public

EXPOSE 8082

USER nobody

CMD ["shiftleft-demo"]

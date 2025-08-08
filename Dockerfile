# Stage #1
FROM alpine:latest as builder
RUN apk add --no-cache g++ libstdc++ musl-dev
WORKDIR /app
COPY . .
RUN g++ heartbeat.cpp -std=c++23 -O2 -s -static \
    -flto -o heartbeat -fno-exceptions

# Stage #2
FROM scratch
COPY --from=builder /app/heartbeat heartbeat
EXPOSE 8080
CMD ["./heartbeat", "8080"]

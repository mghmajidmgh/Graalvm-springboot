# Build Stage
FROM ghcr.io/graalvm/native-image-community:21 AS builder


WORKDIR /app
COPY . .
RUN chmod +x mvnw && \
    ./mvnw -B --no-transfer-progress package -Pnative
# RUN ls -la app/de*  # failed to build: failed to solve: process "/bin/sh -c ls -la app/de*" did not complete successfully: exit code: 2 

# Run Stage
FROM alpine:3.19
RUN apk add --no-cache libstdc++
WORKDIR /app
COPY --from=builder /app/demo /app/demo
EXPOSE 8080
ENTRYPOINT ["./demo"]
# Build Stage
FROM ghcr.io/graalvm/native-image-community:21 AS builder
WORKDIR /app
COPY . .
RUN chmod +x mvnw && \
    ./mvnw -B --no-transfer-progress package -Pnative && \
    ls -la target/

# Run Stage
FROM alpine:3.19
RUN apk add --no-cache libstdc++
WORKDIR /app
COPY --from=builder /app/target/demo-graalvm /app/demo
EXPOSE 8080
ENTRYPOINT ["./demo"]
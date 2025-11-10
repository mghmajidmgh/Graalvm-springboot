# Build Stage
FROM ghcr.io/graalvm/native-image-community:21 AS builder
RUN apt-get update && apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
WORKDIR /app
COPY . .
RUN chmod +x mvnw && \
    ./mvnw -B --no-transfer-progress package -Pnative
RUN ls -la target/de*

# Run Stage
FROM alpine:3.19
RUN apk add --no-cache libstdc++
WORKDIR /app
COPY --from=builder /app/target/demo /app/demo
EXPOSE 8080
ENTRYPOINT ["./demo"]
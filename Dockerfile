# Build Stage
FROM ghcr.io/graalvm/native-image-community:21 AS builder

# Set up locale
RUN microdnf install -y glibc-langpack-en && \
    microdnf clean all
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

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
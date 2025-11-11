# Build Stage
FROM ghcr.io/graalvm/native-image-community:21 AS builder


WORKDIR /app
COPY . .
RUN chmod +x mvnw && \
    ./mvnw -B --no-transfer-progress package -Pnative
RUN echo "--- target contents ---" && ls -la target || true
RUN echo "--- find target files ---" && find target -maxdepth 3 -type f -exec ls -l {} \; || true

# Run Stage
FROM ubuntu:22.04

# Install minimal runtime deps (glibc + libstdc++) required by GraalVM native images
RUN apt-get update && \
    apt-get install -y --no-install-recommends libstdc++6 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
# copy native executable produced by the builder (it lives under target/)
COPY --from=builder /app/target/demo /app/demo
# ensure it's executable
RUN chmod +x /app/demo || true
EXPOSE 8080
ENTRYPOINT ["/app/demo"]
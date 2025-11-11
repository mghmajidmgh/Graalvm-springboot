# Build Stage
FROM ghcr.io/graalvm/native-image-community:21 AS builder


WORKDIR /app
COPY . .
RUN chmod +x mvnw && \
        ./mvnw -B --no-transfer-progress package -Pnative || (echo "Maven native build failed"; exit 1); \
        echo ""; echo "=== target directory listing ==="; ls -la target/ || true; \
        echo ""; echo "=== checking for demo_graal file ==="; \
        if [ -f target/demo_graal ]; then \
            echo "Found target/demo_graal"; ls -la target/demo_graal; \
        else \
            echo "target/demo_graal not found, searching for similar files:"; \
            find target -maxdepth 3 -type f -name "*demo*" -ls || true; \
        fi

#RUN which demo_graal

# Run Stage
FROM ubuntu:22.04

# Install minimal runtime deps (glibc + libstdc++) required by GraalVM native images
RUN apt-get update && \
    apt-get install -y --no-install-recommends libstdc++6 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
# copy native executable produced by the builder (it lives under target/)
# the native image name is now 'demo_graal'
COPY --from=builder /app/target/demo_graal /app/demo_graal
# ensure it's executable
RUN chmod +x /app/demo_graal || true
EXPOSE 8080
ENTRYPOINT ["/app/demo_graal"]
# Build stage
FROM rust:1.70-slim as builder

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /usr/src/sview

# Copy manifests
COPY Cargo.toml Cargo.lock ./

COPY src/ ./src/


# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl1.1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /usr/src/sview/target/release/sview /usr/local/bin/sview

# Set the working directory
WORKDIR /app

# Expose the port the app runs on
EXPOSE 8080

# Run the application
CMD ["sview"]

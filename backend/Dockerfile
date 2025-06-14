FROM golang:1.24.1-alpine AS builder

# Install basic tools
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum* ./

# Download dependencies
RUN go mod download 2>/dev/null || true

# Copy source code
COPY . .

# Development stage
FROM golang:1.24.1-alpine

RUN apk add --no-cache git

WORKDIR /app

# Copy from builder
COPY --from=builder /app .

# Expose port
EXPOSE 8080

CMD ["go", "run", "main.go"]
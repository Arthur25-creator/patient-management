# integration-test/Dockerfile
FROM maven:3.9.12-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Run the tests (this is the main purpose)
RUN mvn clean test

# Optional: Keep test results accessible
FROM eclipse-temurin:21-jre AS runner
WORKDIR /app

# Copy test results if you want to access them later
COPY --from=builder /app/target/surefire-reports /app/test-results

# Default command
CMD ["echo", "Integration tests completed successfully!"]

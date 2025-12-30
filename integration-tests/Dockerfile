FROM maven:3.9.12-eclipse-temurin-21

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src

# Skip integration tests during build
CMD ["mvn", "clean", "test", "-Dtest=!*IntegrationTest"]

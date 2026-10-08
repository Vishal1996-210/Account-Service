# ============================================================
# Stage 1: Build
# ============================================================

# Maven + Java 17 image used to build the application
FROM maven:3.9-eclipse-temurin-17 AS build

# Working directory inside the build container
WORKDIR /build

# Copy Maven configuration first
# This allows Docker to reuse this layer when only source code changes
COPY pom.xml .

# Copy application source code
COPY src ./src

# Build the Spring Boot JAR
# Tests are already executed in the GitHub Actions CI pipeline
RUN mvn clean package -DskipTests


# ============================================================
# Stage 2: Runtime
# ============================================================

# Java 17 JRE is enough to run the generated JAR
FROM eclipse-temurin:17-jre

# Application working directory
WORKDIR /app

# Create a dedicated non-root group and user
RUN groupadd --system spring && \
    useradd --system --gid spring --no-create-home spring

# Copy only the generated JAR from the build stage
# Set ownership directly to the non-root user
COPY --from=build --chown=spring:spring /build/target/*.jar app.jar

# Run the application as the non-root user
USER spring

# Spring Boot application port
EXPOSE 8080

# Start the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

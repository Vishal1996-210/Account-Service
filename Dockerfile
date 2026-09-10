# ============================================================
# Stage 1: Build
# ============================================================
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Copy dependency definition first
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy application source
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests


# ============================================================
# Stage 2: Runtime
# ============================================================
FROM eclipse-temurin:17-jre

WORKDIR /app

# Create a non-root user
RUN groupadd --system spring && \
    useradd --system --gid spring --no-create-home spring

# Copy only the generated JAR from the build stage
COPY --from=build /build/target/*.jar app.jar

# Give ownership to the non-root user
RUN chown spring:spring app.jar

# Run application as non-root user
USER spring

# Spring Boot application port
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

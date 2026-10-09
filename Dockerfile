# ============================================================
# Stage 1: Build
# ============================================================

# Maven + Java 17 image used to build the application 
FROM maven:3.9-eclipse-temurin-17 AS build [FROM is used to define the base image used to build the application.]

# Working directory inside the build container 
WORKDIR /build [WORKDIR is used to define the working directory inside the container image.]

# Copy Maven configuration first
# This allows Docker to reuse this layer when only source code changes 
COPY pom.xml . [COPY and ADD are used to copy files from the host file system into the container image. However, ADD has additional capabilities, such as automatically extracting local tar archives.]

# Copy application source code
COPY src ./src

# Build the Spring Boot JAR 
# Tests are already executed in the GitHub Actions CI pipeline
RUN mvn clean package -DskipTests [RUN is used to execute commands during the image build process.]


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
USER spring [USER is used to specify the user who will run commands and the application inside the container.]

# Spring Boot application port
EXPOSE 8080 [EXPOSE is used to document the port on which the application listens inside the container. It does not automatically publish the port to the host.]

# Start the Spring Boot application
[ARG is mainly for build-time variables, whereas ENV is used for environment variables that persist into the container]
[CMD is used to specify the default command or arguments to run when the container starts. It can be overridden when running the container.]
[ENTRYPOINT is used to specify the main executable that runs when the container starts. It is commonly used to define the main application process.]
ENTRYPOINT ["java", "-jar", "/app/app.jar"] 

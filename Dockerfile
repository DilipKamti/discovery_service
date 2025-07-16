# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the jar file into the container
COPY target/discovery-service-0.0.1-SNAPSHOT.jar app.jar

# Expose the port your discovery service runs on (e.g., 8761 for Eureka)
EXPOSE 8761

# Run the jar file
ENTRYPOINT ["java", "-jar", "app.jar"]
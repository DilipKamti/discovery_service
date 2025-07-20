# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the jar file into the container
COPY target/discovery-service*.jar app.jar

# Run the jar file
ENTRYPOINT ["java", "-jar", "app.jar"]
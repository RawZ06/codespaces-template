#!/bin/bash
set -e

echo "Building Spring Boot project..."
mvn clean package -DskipTests

echo "Setup complete! Run './mvnw spring-boot:run' to start development server."

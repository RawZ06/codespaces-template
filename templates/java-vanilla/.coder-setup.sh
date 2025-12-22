#!/bin/bash
set -e

echo "Compiling Java project..."
mvn clean compile

echo "Setup complete! Run 'mvn test' to run tests or 'mvn exec:java' to execute."

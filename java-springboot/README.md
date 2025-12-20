# Spring Boot 4 Template

Template Spring Boot 4 avec Java 25, H2, Lombok et exemple Hello World.

## Démarrage rapide

```bash
# Compiler et lancer l'application
./mvnw spring-boot:run

# Ou avec Maven installé globalement
mvn spring-boot:run
```

## Endpoints disponibles

- `GET /api/hello?name=YourName` - Endpoint Hello World
- `GET /api/health` - Health check
- `GET /h2-console` - Console H2 Database (en développement)

### Exemple d'utilisation

```bash
# Test du endpoint hello
curl http://localhost:8080/api/hello?name=Alexandre

# Réponse
{
  "message": "Hello, Alexandre!",
  "timestamp": "2025-12-20T12:00:00",
  "status": "success"
}
```

## Base de données H2

La base de données H2 est configurée en mode mémoire (testdb).

Pour accéder à la console H2:
1. Aller sur http://localhost:8080/h2-console
2. JDBC URL: `jdbc:h2:mem:testdb`
3. Username: `sa`
4. Password: (vide)

## Technologies

- **Spring Boot 4.0.0** (LTS)
- **Java 25** (LTS - Septembre 2025)
- Spring Web
- Spring Data JPA
- H2 Database
- Lombok

## Nouveautés Spring Boot 4

- Support Jakarta EE 11
- Modularisation complète du codebase
- Support OpenTelemetry natif
- Null Safety avec JSpecify
- Spring Framework 7

## Nouveautés Java 25

- Scoped Values (JEP 506) - Alternative aux thread-local variables
- Compact Source Files - Simplification pour débutants
- Flexible Constructor Bodies (JEP 513)
- Primitive Types in Patterns (JEP 507) - Preview
- Structured Concurrency (JEP 505)

## Build

```bash
# Créer un JAR exécutable
./mvnw clean package

# Lancer le JAR
java -jar target/java-springboot-0.0.1-SNAPSHOT.jar
```

## Configuration

La configuration se trouve dans `src/main/resources/application.yml`:
- Port serveur: 8080
- Base H2 en mémoire activée
- Logs au niveau DEBUG pour le développement
- Console H2 accessible en développement

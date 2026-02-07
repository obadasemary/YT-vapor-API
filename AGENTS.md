# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Build & Run Commands

```bash
# Build the project
swift build

# Run the server (default: http://localhost:8080)
swift run

# Run all tests (requires PostgreSQL running)
swift test

# Run a specific test
swift test --filter "YtVaporApiTests/testName"

# Run tests matching a pattern
swift test --filter "TodoController"
```

## Docker Commands

```bash
# Start PostgreSQL database
docker compose up db

# Run database migrations
docker compose run migrate

# Start the application
docker compose up app

# Revert migrations
docker compose run revert

# Stop everything (add -v to wipe database)
docker compose down
```

## Database Configuration

Environment variables (defaults work with docker-compose):
- `DATABASE_HOST` (default: localhost)
- `DATABASE_PORT` (default: 5432)
- `DATABASE_USERNAME` (default: vapor_username)
- `DATABASE_PASSWORD` (default: vapor_password)
- `DATABASE_NAME` (default: vapor_database)

## Architecture

This is a Vapor 4 REST API using Swift 6 with async/await concurrency.

### Request Flow
`entrypoint.swift` → `configure.swift` → `routes.swift` → `Controllers/`

### Layer Responsibilities

- **Models/** - Fluent ORM entities with `@ID`, `@Field` property wrappers. Each model has a `schema` name and `toDTO()` method.
- **DTOs/** - Data Transfer Objects conforming to `Content` for JSON serialization. Include `toModel()` for conversion.
- **Controllers/** - Route collections implementing `RouteCollection`. Register routes in `boot(routes:)` and mark handlers with `@Sendable`.
- **Migrations/** - Implement `AsyncMigration` with `prepare(on:)` and `revert(on:)` methods.

### Testing Pattern

Tests use Swift Testing (`@Test`) with VaporTesting. The `withApp` helper:
1. Creates app in `.testing` environment
2. Runs `autoMigrate()` before tests
3. Runs `autoRevert()` after tests to clean up

### Adding New Features

1. Create migration in `Migrations/` and register in `configure.swift`
2. Create model in `Models/` with `toDTO()` method
3. Create DTO in `DTOs/` with `toModel()` method
4. Create controller in `Controllers/` implementing `RouteCollection`
5. Register controller in `routes.swift`

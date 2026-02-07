# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
# Build the project
swift build

# Run the server (starts on http://localhost:8080)
swift run

# Run all tests (requires PostgreSQL running)
swift test

# Run a specific test
swift test --filter "YtVaporApiTests/testName"
```

## Docker Database Setup

PostgreSQL database is required for development and testing:

```bash
# Start PostgreSQL (runs on port 5432)
docker compose up db

# Run migrations (after building image)
docker compose build && docker compose run migrate

# Start the full application stack
docker compose up app

# Revert migrations
docker compose run revert

# Stop and optionally wipe database
docker compose down      # Keep data
docker compose down -v   # Wipe database
```

## Database Configuration

Environment variables (with defaults from [configure.swift:11-18](configure.swift)):
- `DATABASE_HOST` (default: "localhost")
- `DATABASE_PORT` (default: 5432)
- `DATABASE_USERNAME` (default: "vapor_username")
- `DATABASE_PASSWORD` (default: "vapor_password")
- `DATABASE_NAME` (default: "vapor_database")

Docker Compose automatically configures these when using `docker compose up db`.

## Project Architecture

This is a Vapor 4 REST API using Swift 6 with async/await concurrency.

### Application Flow
1. [entrypoint.swift](Sources/YtVaporApi/entrypoint.swift) - Application entry point with NIO event loop setup
2. [configure.swift](Sources/YtVaporApi/configure.swift) - Database configuration, migration registration, runs `autoMigrate()`
3. [routes.swift](Sources/YtVaporApi/routes.swift) - Route registration for all controllers

### Code Organization

**Models/** ([Song.swift](Sources/YtVaporApi/Models/Song.swift) example)
- Fluent ORM entities conforming to `Model, Content, @unchecked Sendable`
- Use `@ID(key: .id)` for primary keys (UUID)
- Use `@Field(key: "column_name")` for regular fields
- Static property `schema` defines the database table name
- Simple init methods for instantiation

**Controllers/** ([SongController.swift](Sources/YtVaporApi/Controllers/SongController.swift) example)
- Implement `RouteCollection` protocol
- Register routes in `boot(routes:)` method using route groups
- Route handlers can return `EventLoopFuture<T>` or use async/await
- Access database via `req.db`

**Migrations/** ([CreateSongs.swift](Sources/YtVaporApi/Migrations/CreateSongs.swift) example)
- Implement `Migration` protocol (not `AsyncMigration`)
- Use `EventLoopFuture<Void>` return type
- `prepare(on:)` creates schema with `.id()`, `.field()`, `.create()`
- `revert(on:)` drops schema with `.delete()`
- Register in [configure.swift:20](configure.swift) before `autoMigrate()`

### Testing Pattern

Tests use Swift Testing framework with VaporTesting. The `withApp` helper in [YtVaporApiTests.swift:8-21](Tests/YtVaporApiTests/YtVaporApiTests.swift):
1. Creates app in `.testing` environment
2. Calls `configure(app)` to setup database and migrations
3. Runs `autoMigrate()` to create test schema
4. Executes test logic
5. Runs `autoRevert()` to clean up database
6. Shuts down app

Use `@Suite(.serialized)` to prevent concurrent test execution that could cause database conflicts.

Test HTTP endpoints with `app.testing().test(.METHOD, "path", ...)` providing `beforeRequest` and `afterResponse` closures.

## Adding New Features

Follow this sequence when adding new REST resources:

1. **Create Migration** in `Sources/YtVaporApi/Migrations/`
   - Implement `Migration` protocol with `EventLoopFuture` return types
   - Register in [configure.swift](Sources/YtVaporApi/configure.swift) using `app.migrations.add()`
   - Place registration before `autoMigrate()` call

2. **Create Model** in `Sources/YtVaporApi/Models/`
   - Conform to `Model, Content, @unchecked Sendable`
   - Define `static let schema` matching migration table name
   - Use `@ID(key: .id)` for primary key
   - Use `@Field(key:)` for columns

3. **Create Controller** in `Sources/YtVaporApi/Controllers/`
   - Implement `RouteCollection`
   - Define route group in `boot(routes:)`
   - Implement handler methods (CRUD operations)

4. **Register Controller** in [routes.swift](Sources/YtVaporApi/routes.swift)
   - Use `try app.register(collection: YourController())`

5. **Write Tests** in `Tests/YtVaporApiTests/`
   - Use `@Test` attribute with descriptive names
   - Wrap tests in `withApp` helper
   - Test all CRUD endpoints

## Swift Configuration

The project uses Swift 6 with these settings from [Package.swift:42-44](Package.swift):
- `.enableUpcomingFeature("ExistentialAny")` - Requires explicit `any` keyword for existential types
- Platform: macOS 13+

## Notes

- Migrations run synchronously on app startup via `autoMigrate().wait()` in [configure.swift:21](configure.swift)
- The codebase uses `EventLoopFuture` for database operations, not async/await in migrations
- Controllers can use either `EventLoopFuture<T>` or async handlers

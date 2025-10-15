# Architecture Patterns

## Project Architecture Patterns

### Vertical Slice Architecture (Default)

Organize by feature rather than technical layer.

```text
src/
├── main.[ext]
├── core/              # Shared infrastructure (auth, database, logging)
├── features/          # Business features
│   ├── user_management/
│   │   ├── handlers.[ext]
│   │   ├── service.[ext]
│   │   ├── repository.[ext]
│   │   └── tests/
│   └── payment/
└── shared/            # Shared utilities (use sparingly)
```

**Benefits**: High cohesion, easy navigation, scales well, clear boundaries
**When to use**: Default choice for most applications

### Hexagonal Architecture (Ports and Adapters)

Separate core business logic from external concerns.

```text
src/
├── domain/            # Core business logic (no external dependencies)
├── ports/             # Interfaces
│   ├── inbound/       # External world calls us
│   └── outbound/      # We call external world
├── adapters/          # Implementations
│   ├── inbound/       # HTTP, CLI
│   └── outbound/      # Database, external services
└── application/       # Application services (orchestration)
```

**Benefits**: Testable, flexible, clean boundaries
**When to use**: Complex domains, need infrastructure flexibility

### Onion Architecture

Dependencies point inward: Domain Model → Domain Services → Application Services → Infrastructure

**When to use**: Complex business domains, DDD projects

### Layered Architecture (N-Tier)

```text
src/
├── presentation/     # UI, controllers
├── application/      # Application logic
├── domain/          # Business logic
└── infrastructure/  # Database, external services
```

**When to use**: Simple apps, team familiar with pattern

## Design Patterns

### Creational

**Factory**: Create objects without specifying exact class
**Builder**: Construct complex objects step by step
**Singleton**: Ensure only one instance exists (use sparingly)

### Structural

**Repository**: Abstract data access

```python
class UserRepository:
    def find_by_id(self, user_id: int) -> Optional[User]:
        # Data access logic
        pass
```

**Adapter**: Make incompatible interfaces work together
**Decorator**: Add behavior dynamically

### Behavioral

**Strategy**: Select algorithm at runtime
**Observer**: Notify dependents of state changes
**Command**: Encapsulate requests as objects

## Error Handling Patterns

### Exceptions (Python, JS, Java, C#)

```python
class ValidationError(Exception):
    """Data validation failed"""
    pass

try:
    validate_data(data)
except ValidationError as e:
    logger.error(f"Validation failed: {e}")
    raise ServiceError("Failed to process") from e
```

### Result Types (Rust)

```rust
fn calculate_price(price: f64, tax: f64) -> Result<f64, String> {
    if price < 0.0 || tax < 0.0 {
        return Err("Must be non-negative".to_string());
    }
    Ok(price * (1.0 + tax))
}
```

### Error Returns (Go)

```go
func CreateUser(email string) (*User, error) {
    if err := validateEmail(email); err != nil {
        return nil, fmt.Errorf("invalid email: %w", err)
    }
    return &User{Email: email}, nil
}
```

### Best Practices

- Define custom error types for different domains
- Include context in errors
- Chain exceptions to preserve stack traces
- Log errors with structured data
- Fail fast with informative messages

## Database Patterns

### Naming Conventions

- **Tables**: Plural snake_case (`users`, `order_items`)
- **Columns**: snake_case (`user_id`, `created_at`, `is_active`)
- **Primary Keys**: `id` (auto-increment or UUID)
- **Foreign Keys**: `{table}_id` (`user_id`, `order_id`)
- **Timestamps**: `created_at`, `updated_at`, `deleted_at`
- **Booleans**: `is_` or `has_` prefix
- **Indexes**: `idx_{table}_{columns}`

### Repository Pattern

```python
class BaseRepository:
    def find_by_id(self, id: int): raise NotImplementedError
    def find_all(self): raise NotImplementedError
    def save(self, entity): raise NotImplementedError
    def delete(self, id: int): raise NotImplementedError

class UserRepository(BaseRepository):
    def find_by_id(self, user_id: int) -> Optional[User]:
        row = self.db.query_one("SELECT * FROM users WHERE id = ?", (user_id,))
        return User.from_dict(row) if row else None
```

### ORM vs Raw SQL

**Use ORM**: Standard CRUD, complex relationships, database abstraction
**Use Raw SQL**: Complex queries, performance-critical operations, bulk operations

### Migration Management

- Version controlled migrations
- Reversible migrations (up/down)
- Test on staging first
- Never modify existing migrations
- Separate data migrations

## Data Models

### Separate Models by Layer

**Domain Models**: Core business logic

```python
@dataclass
class User:
    id: Optional[int]
    email: str
    name: str
```

**API Models (DTOs)**: External representation

```python
class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str
    password: str
```

**Database Models**: Persistence layer

```python
class UserModel(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    email = Column(String(255), unique=True, nullable=False)
```

### Validation

- **Input Validation**: At boundaries (API, CLI)
- **Business Validation**: In domain logic
- **Database Validation**: Constraints (as last resort)

## Configuration Patterns

### Environment-Based

```python
class Config:
    def __init__(self):
        self.environment = os.getenv("ENVIRONMENT", "development")
        self.database_url = os.getenv("DATABASE_URL")
        self.api_key = os.getenv("API_KEY")
        self._validate()

    def _validate(self):
        if not self.database_url:
            raise ValueError("DATABASE_URL must be set")
```

### Configuration Files

```yaml
# config/production.yaml
database:
  host: ${DATABASE_HOST}
  port: ${DATABASE_PORT}

logging:
  level: INFO
  format: json
```

## Project-Specific Architecture

Document in `.context/architecture-decisions.md`:

- Chosen patterns and rationale
- Technology stack
- Integration approaches
- Known limitations

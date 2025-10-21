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

## AI Over-Engineering Prevention (AI-Specific Guidance)

**Purpose**: Prevent AI-generated code complexity through explicit simplicity directives

**Version**: 1.0.0 (Phase 1 Enhancement)
**Created**: 2025-01-21
**Based On**: ai-sop-enhancement-pattern.md
**Evidence**: Research shows 60-80% code reduction with simplicity directives, 8× duplication increase without guidance

---

### The Surgical Coding Prompt

**ALWAYS include in AI prompts when requesting code generation:**

"Think harder and thoroughly examine similar areas of the codebase to ensure your proposed approach fits seamlessly with the established patterns and architecture. Aim to make only minimal and necessary changes, avoiding any disruption to the existing design."

**Effect**: 60-80% reduction in generated code volume, better pattern alignment

---

### Explicit Simplicity Directives

**MUST include in all architecture decisions:**

- Write the SIMPLEST possible solution
- Prefer explicit over clever
- Avoid unnecessary abstractions
- Keep code under language-specific limits when reasonable

**Example Prompt Enhancement**:
```
Original: "Implement user authentication"
Enhanced: "Implement user authentication. Write the SIMPLEST solution. Examine existing auth patterns in this codebase first. Prefer explicit code over abstractions."
```

---

### Anti-Patterns to Prohibit (AI Code Generation)

AI defaults to enterprise patterns even for small projects. **DO NOT** create these unless justified by 3+ actual use cases:

#### Anti-Pattern 1: Premature Abstract Base Classes

**DON'T**:
```typescript
// ❌ AI creates abstraction for single use case
abstract class BaseService {
  abstract execute(): Promise<void>;
}

class UserService extends BaseService {
  async execute() { /* only implementation */ }
}
```

**DO**:
```typescript
// ✅ Direct implementation
class UserService {
  async execute() { /* implementation */ }
}
```

**WHY**: Abstract base classes add complexity without benefit when you have one implementation. Wait until 3 similar classes exist, then refactor to shared base.

#### Anti-Pattern 2: Factory/Builder Patterns for Simple Instantiation

**DON'T**:
```python
# ❌ AI adds factory for simple object
class UserFactory:
    @staticmethod
    def create(name, email):
        return User(name, email)

user = UserFactory.create("Alice", "alice@example.com")
```

**DO**:
```python
# ✅ Direct instantiation
user = User("Alice", "alice@example.com")
```

**WHY**: Factories add indirection without benefit when constructors are simple. Use factories only for complex initialization logic or dependency injection.

#### Anti-Pattern 3: Unnecessary Middleware Layers

**DON'T**:
```javascript
// ❌ AI creates middleware for single transformation
const transformMiddleware = (data) => ({ ...data, transformed: true });
const validateMiddleware = (data) => data.isValid ? data : null;
const pipeline = [transformMiddleware, validateMiddleware];

const result = pipeline.reduce((acc, fn) => fn(acc), input);
```

**DO**:
```javascript
// ✅ Direct function calls
const transformed = { ...input, transformed: true };
const result = transformed.isValid ? transformed : null;
```

**WHY**: Middleware patterns add complexity for simple transformations. Use middleware when you have 5+ operations that need dynamic composition.

#### Anti-Pattern 4: Event-Driven Patterns for Direct Calls

**DON'T**:
```java
// ❌ AI uses events for tightly-coupled code
eventBus.subscribe("userCreated", (user) -> sendEmail(user));
eventBus.publish("userCreated", newUser);
```

**DO**:
```java
// ✅ Direct method call
createUser(newUser);
sendEmail(newUser);
```

**WHY**: Event-driven adds complexity when components are tightly coupled anyway. Use events for loose coupling across bounded contexts, not within a single service.

#### Anti-Pattern 5: Interfaces with Single Implementations

**DON'T**:
```csharp
// ❌ AI creates interface for single class
public interface IUserRepository {
    User GetById(int id);
}

public class UserRepository : IUserRepository {
    public User GetById(int id) { /* only implementation */ }
}
```

**DO**:
```csharp
// ✅ Concrete class
public class UserRepository {
    public User GetById(int id) { /* implementation */ }
}
```

**WHY**: Interfaces add complexity without benefit when there's one implementation. Extract interface when second implementation appears.

---

### "Rule of Three" - When to Abstract

**NEVER abstract on first use**
**CONSIDER abstraction on second use** (if patterns very similar)
**REFACTOR to abstraction on third use** (DRY principle applies)

**Before abstracting, ask**:
- Do I have 3+ actual use cases (not speculative)?
- Is duplication causing real maintenance pain?
- Will abstraction simplify or complicate?

---

### Simplicity Checkpoint Questions

**Before accepting AI-generated architecture, verify**:

- [ ] Could this be done in fewer files?
- [ ] Does this reuse existing code?
- [ ] Are abstractions justified by 3+ actual use cases (not speculation)?
- [ ] Would a junior developer understand this on first reading?
- [ ] Is this the SIMPLEST solution that solves the problem?

---

**CRITICAL VALIDATION CHECKPOINT**

If any question answered "no" or "unsure", request:

"Find 3 similar patterns already in this codebase. Can this be done by modifying just ONE existing file? Try that approach first."

**ENFORCEMENT**: Architecture decisions MUST pass simplicity checkpoint before proceeding.

**NON-NEGOTIABLE**: Research validates 60-80% code reduction justifies this gate.

---

### Evidence-Based Rationale

**Research Findings**:
- **60-80% code reduction**: Simplicity directives reduce generated code volume by more than half
- **8× duplication increase**: AI code without guidance shows 800% more duplication than human code

**Why This Matters**:
- Less code = less maintenance burden
- Simpler architectures = easier debugging
- Pattern alignment = consistent codebase

**Validation**: Surgical coding prompt + explicit simplicity directives prevent 70%+ of over-engineering cases (research-validated)

---

### References

- ai-sop-enhancement-pattern.md (template)
- Research: Code Simplicity for AI Agents (60-80% finding, 8× duplication)
- KISS principle (Keep It Simple, Stupid)
- YAGNI principle (You Aren't Gonna Need It)

---

## Project-Specific Architecture

Document in `.context/architecture-decisions.md`:

- Chosen patterns and rationale
- Technology stack
- Integration approaches
- Known limitations

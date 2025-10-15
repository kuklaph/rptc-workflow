# Security and Performance

## Security Best Practices

### OWASP Top 10 (2021)

#### 1. Broken Access Control

**Prevention**:

- Deny by default
- Implement RBAC (Role-Based Access Control)
- Verify permissions on every request
- Log access control failures

```python
@require_permission("users.edit")
def update_user(user_id: int, requesting_user: User):
    if not requesting_user.can_access_user(user_id):
        raise ForbiddenError("Insufficient permissions")
    # Update logic
```

#### 2. Cryptographic Failures

**Prevention**:

- Use strong algorithms (AES-256, RSA-2048+)
- Never implement custom crypto
- Hash passwords with Argon2 or bcrypt
- Store secrets in environment variables or vaults
- Use HTTPS everywhere
- Rotate keys regularly

```python
import bcrypt

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())
```

#### 3. Injection

**Prevention**:

```python
# SQL: Use parameterized queries
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (user_id,))

# Command: Use libraries, not shell
subprocess.run(["ping", "-c", "1", user_input], check=True)

# XSS: Use textContent or auto-escaping templates
element.textContent = userContent  # JavaScript
# React, Vue, Angular auto-escape by default
```

**Best Practices**:

- Parameterized queries always
- Validate and sanitize all input
- Use ORMs with proper escaping
- Content Security Policy (CSP)

#### 4. Insecure Design

**Prevention**:

- Threat modeling during design
- Security requirements in user stories
- Principle of least privilege
- Defense in depth

#### 5. Security Misconfiguration

**Prevention**:

- Disable debug mode in production
- Remove default accounts
- Use minimal, hardened configurations
- Keep software updated
- Set security headers

```python
# Security headers
response.headers['X-Content-Type-Options'] = 'nosniff'
response.headers['X-Frame-Options'] = 'DENY'
response.headers['X-XSS-Protection'] = '1; mode=block'
response.headers['Strict-Transport-Security'] = 'max-age=31536000'
response.headers['Content-Security-Policy'] = "default-src 'self'"
```

#### 6. Vulnerable Components

**Prevention**:

- Scan for vulnerabilities: `npm audit`, `pip-audit`, `snyk test`
- Keep dependencies updated
- Remove unused dependencies
- Use Dependabot or Renovate

#### 7. Authentication Failures

**Prevention**:

- Implement MFA (Multi-Factor Authentication)
- Rate limiting and account lockout
- Secure session management
- Strong password requirements

```python
@limiter.limit("5 per minute")
def login(credentials):
    user = authenticate(credentials.username, credentials.password)
    if not user:
        raise AuthenticationError("Invalid credentials")
    return create_session(user)

# Session config
session_config = {
    "httponly": True,    # Prevent JS access
    "secure": True,      # HTTPS only
    "samesite": "strict", # CSRF protection
    "max_age": 3600      # 1 hour timeout
}
```

#### 8. Software Integrity Failures

**Prevention**:

- Sign releases and verify signatures
- Use checksums for integrity
- Secure CI/CD pipelines
- Scan for secrets in code

#### 9. Logging and Monitoring Failures

**Prevention**:

- Log all authentication events
- Log access control failures
- Include sufficient context
- Never log PII, passwords, tokens
- Centralized log management
- Real-time alerting

```python
logger.info("user_action",
    user_id=user.id,
    action="purchase",
    product_id=product.id,
    amount=amount
)
```

#### 10. Server-Side Request Forgery (SSRF)

**Prevention**:

- Whitelist allowed URLs/domains
- Block access to internal networks
- Validate and sanitize URLs
- Implement timeouts

```python
ALLOWED_DOMAINS = ["api.trusted-service.com"]
BLOCKED_NETWORKS = ["127.0.0.0/8", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

def is_safe_url(url: str) -> bool:
    parsed = urlparse(url)
    if parsed.hostname not in ALLOWED_DOMAINS:
        return False
    # Check for blocked networks
    return True
```

## Authentication and Authorization

### JWT (JSON Web Tokens)

```python
import jwt
from datetime import datetime, timedelta

SECRET_KEY = os.getenv("JWT_SECRET_KEY")

def create_access_token(user_id: int):
    expire = datetime.utcnow() + timedelta(minutes=15)
    return jwt.encode({
        "user_id": user_id,
        "exp": expire,
        "type": "access"
    }, SECRET_KEY, algorithm="HS256")

def verify_token(token: str):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise AuthenticationError("Token expired")
```

**Best Practices**:

- Short-lived access tokens (15 minutes)
- Longer-lived refresh tokens (30 days)
- Rotate secrets regularly
- Implement token blacklist for logout

### OAuth 2.0

**Flow Types**:

- **Authorization Code**: Web apps (most secure)
- **PKCE**: Mobile/SPA apps
- **Client Credentials**: Service-to-service

## Input Validation

### Validation

```python
from pydantic import BaseModel, EmailStr, constr, validator

class UserRegistration(BaseModel):
    username: constr(min_length=3, max_length=20, regex=r'^[a-zA-Z0-9_]+$')
    email: EmailStr
    password: constr(min_length=8)

    @validator('password')
    def validate_password_strength(cls, v):
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain digit')
        return v
```

### Sanitization

```python
import bleach

def sanitize_html(user_input: str) -> str:
    allowed_tags = ['p', 'br', 'strong', 'em', 'a']
    allowed_attrs = {'a': ['href', 'title']}
    return bleach.clean(user_input, tags=allowed_tags, attributes=allowed_attrs, strip=True)
```

## Performance Optimization

### Profiling

**Python**:

```python
import cProfile
profiler = cProfile.Profile()
profiler.enable()
# Your code
profiler.disable()
profiler.print_stats()
```

**JavaScript**:

```javascript
console.time("operation");
// Your code
console.timeEnd("operation");
```

### Caching Strategies

**In-Memory**:

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_computation(n: int):
    return result
```

**Redis**:

```python
import redis
redis_client = redis.Redis(host='localhost', port=6379)

def get_user_profile(user_id: int):
    cache_key = f"user:{user_id}:profile"
    cached = redis_client.get(cache_key)
    if cached:
        return json.loads(cached)

    profile = database.get_user_profile(user_id)
    redis_client.setex(cache_key, 3600, json.dumps(profile))
    return profile
```

**HTTP Caching**:

```python
response.headers['Cache-Control'] = 'public, max-age=3600'
response.headers['ETag'] = generate_etag(data)
```

### Database Optimization

**Query Optimization**:

```python
# BAD: N+1 queries
users = User.query.all()
for user in users:
    print(user.profile.bio)  # Separate query per user

# GOOD: Eager loading
users = User.query.options(joinedload(User.profile)).all()
```

**Indexing**:

```python
class User(Base):
    email = Column(String, unique=True, index=True)
    created_at = Column(DateTime, index=True)

    # Composite index
    __table_args__ = (
        Index('idx_user_email_active', 'email', 'is_active'),
    )
```

**Connection Pooling**:

```python
engine = create_engine(
    'postgresql://user:pass@localhost/db',
    pool_size=10,
    max_overflow=20,
    pool_timeout=30
)
```

**Batch Operations**:

```python
# GOOD: Single batch query
User.query.filter(User.id.in_(user_ids)).update(data)
```

### Async/Await

**Python**:

```python
import asyncio
import aiohttp

async def fetch_all_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [session.get(url) for url in urls]
        return await asyncio.gather(*tasks)
```

**JavaScript**:

```javascript
// Parallel (fast)
const [user, posts, comments] = await Promise.all([fetchUser(userId), fetchPosts(userId), fetchComments(userId)]);
```

### Frontend Performance

**Code Splitting**:

```javascript
const Component = lazy(() => import("./Component"));
```

**Image Optimization**:

```html
<img
  src="image.jpg"
  loading="lazy"
  alt="Description" />
```

**Asset Optimization**:

```javascript
// Webpack config
optimization: {
  splitChunks: { chunks: "all" },
  minimize: true,
  usedExports: true  // Tree shaking
}
```

## Monitoring and Observability

### Application Metrics

```python
from prometheus_client import Counter, Histogram

request_count = Counter('http_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
request_duration = Histogram('http_request_duration_seconds', 'Request duration')

@app.middleware('http')
async def metrics_middleware(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start

    request_count.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    request_duration.observe(duration)

    return response
```

### Error Tracking

```python
import sentry_sdk

sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN"),
    traces_sample_rate=0.1,
    environment=os.getenv("ENVIRONMENT")
)
```

### Logging Best Practices

```python
import structlog

logger = structlog.get_logger()

logger.info("user_action",
    user_id=user.id,
    action="purchase",
    product_id=product.id,
    timestamp=datetime.now().isoformat()
)

# Never log sensitive data
# BAD: logger.info(f"User {username} password {password}")
# GOOD: logger.info("user_login", user_id=user.id, success=True)
```

## Project-Specific Security

Document in `.context/security-notes.md`:

- Compliance requirements (GDPR, HIPAA, PCI-DSS)
- Data classification
- Encryption requirements
- Authentication providers
- Rate limiting rules

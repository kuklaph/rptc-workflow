# Security and Performance

**Purpose**: Comprehensive security and performance guidance for AI agents implementing RPTC workflows. Emphasizes OWASP Top 10 compliance, evidence-based security patterns, and systematic performance optimization with quality gates.

**Version**: 2.0.0
**Created**: 2024-01-15
**Last Updated**: 2025-01-21

**Applies To**: `/rptc:feat` (unified workflow), `/rptc:research`, `/rptc:commit`, `/rptc:sync-prod-to-tests`, Code Review Agent, Security Agent, all implementation sub-agents

---

## Table of Contents

1. [AI-Specific Security Enforcement](#ai-specific-security-enforcement)
2. [Security Best Practices (OWASP Top 10 2021)](#security-best-practices)
3. [Authentication and Authorization](#authentication-and-authorization)
4. [Input Validation](#input-validation)
5. [Performance Optimization](#performance-optimization)
6. [Monitoring and Observability](#monitoring-and-observability)
7. [AI Security Anti-Patterns](#ai-security-anti-patterns)
8. [Security Testing Requirements](#security-testing-requirements)
9. [Related SOPs](#related-standard-operating-procedures)

---

## AI-Specific Security Enforcement

> **Research Foundation**: AI-generated code exhibits 322% higher vulnerability rates when security validation is optional vs. mandatory. This section provides systematic security gates that transform security from "best practice" to "enforced requirement."

### Why AI Agents Need Stricter Security Discipline

**Human vs AI Security Behavior:**

| Aspect | Human Developers | AI Agents |
|--------|------------------|-----------|
| **Threat Awareness** | Varies by experience, improves with training | No inherent threat model, follows patterns literally |
| **Security Trade-offs** | Balance security vs convenience consciously | Defaults to convenience unless constrained |
| **Input Validation** | May skip "obviously safe" inputs | Cannot assess "obvious safety" without rules |
| **OWASP Compliance** | May know but not apply consistently | Applies perfectly once rules established |

**Key Principle**: AI agents lack security intuition. Systematic validation gates provide the missing threat awareness.

### Core Security Commandments for AI Agents

**Absolute Rules (No Exceptions)**:

1. ✅ **Validate ALL external input** - No trusted sources, validate everything
2. ✅ **Parameterize ALL queries** - No string concatenation with user data
3. ✅ **Enforce HTTPS everywhere** - No unencrypted transmission of sensitive data
4. ✅ **Hash passwords with bcrypt/Argon2** - Never plain text or weak algorithms
5. ✅ **Security gates BEFORE commit** - OWASP scan, dependency audit, secret detection
6. ✅ **Fail securely** - Default deny, explicit allow only

**Enforcement Mechanisms**:

```bash
# Pre-commit security gates (from git-and-deployment.md SOP)
# These checks run automatically before EVERY commit:

1. Secret Detection:
   git secrets --scan  # Blocks commits with API keys, passwords, tokens

2. Dependency Audit:
   npm audit --audit-level=moderate  # Blocks vulnerable dependencies
   pip-audit  # Python equivalent

3. OWASP Dependency Check:
   dependency-check --scan . --failOnCVSS 7  # Blocks high-severity CVEs

4. Static Analysis Security Testing (SAST):
   semgrep --config=auto  # Blocks common vulnerability patterns

# Example enforcement output:
git commit -m "feat: add user authentication"
# ❌ BLOCKED: API key detected in src/config.js (line 42)
# ❌ BLOCKED: 3 high-severity vulnerabilities in dependencies
# ✅ PASS: No secrets, no vulnerabilities, OWASP compliant
```

### Security Validation Workflow (Extended Shift-Left)

Traditional security (test after) enhanced for AI agents (validate during):

**Phase 0: THREAT MODELING** (AI-Specific Addition)
- **Input**: Feature requirements, data flows, trust boundaries
- **Output**: Security requirements list (auth, input validation, encryption needs)
- **Validation**: Security specialist/PM review before implementation
- **Why**: Prevents building insecure features correctly

**Phase 1: SECURE DESIGN** (Write Security Tests First)
- **Action**: Write security tests for ONE threat from threat model
- **Validation**: Run tests, confirm failure with expected security violation
- **Anti-Pattern Warning**: Don't skip threat modeling (leads to missing security requirements)
- **Best Practice**: Start with OWASP Top 10 test for relevant category

**Phase 2: SECURE IMPLEMENTATION** (Minimal Secure Code)
- **Action**: Write MINIMAL secure code to pass the ONE security test
- **Validation**: Security test passes, no regressions
- **Anti-Pattern Warning**: Don't add security controls "just in case" (YAGNI violation)
- **Best Practice**: Use vetted security libraries (bcrypt, Helmet, OWASP libs)

**Phase 3: SECURITY AUDIT** (Automated + Manual Review)
- **Action**: Run SAST tools, dependency audit, manual code review
- **Validation**: No high/critical vulnerabilities detected
- **Anti-Pattern Warning**: Don't skip automated scans (human review misses patterns)
- **Best Practice**: Treat medium+ vulnerabilities as blocking issues

**Phase 4: REPEAT** (Next Security Requirement)
- **Action**: Return to Phase 1 for next threat scenario
- **Validation**: Security test coverage increasing, no regressions
- **Completion**: When all threat model scenarios implemented and validated

---

**CRITICAL VALIDATION CHECKPOINT - SECURITY BREACH PREVENTION**

Before committing any code that handles authentication, authorization, user input, sensitive data, or external communication:

**Security Gate Check**: "All security validation gates" MUST pass

**Verification Steps**:
1. Run `git secrets --scan` - confirms no hardcoded secrets
2. Run `npm audit` or equivalent - confirms no vulnerable dependencies
3. Run SAST scanner (semgrep, SonarQube) - confirms no vulnerability patterns
4. Review OWASP Top 10 checklist for relevant categories
5. Verify parameterized queries (no string concatenation with user data)
6. Verify input validation present for ALL external inputs
7. Verify encryption/hashing for sensitive data (passwords, PII, tokens)

❌ **COMMIT BLOCKED** - Security validation incomplete

**Required Action**: Fix all high/critical vulnerabilities, add missing security controls, re-run verification

**ENFORCEMENT**: If security gates NOT passed:
1. **NEVER** commit code with known vulnerabilities
2. **NEVER** bypass security scans ("I'll fix later")
3. **ALWAYS** treat security failures as blocking issues
4. **MUST** document risk acceptance if medium vulnerabilities remain (PM approval required)

**This is a NON-NEGOTIABLE gate. Security vulnerabilities in production cost 30x more to fix than in development. AI-generated code has 322% higher vulnerability rate when validation is optional.**

---

### AI Security Testing Patterns

**Pattern 1: Threat-Driven Test Generation**

For each OWASP Top 10 category, generate systematic test suite:

```python
# Example: Injection (OWASP A03:2021) test generation

class TestSQLInjectionPrevention:
    """
    Tests SQL injection prevention for user search feature.
    References: OWASP A03:2021 Injection
    """

    def test_search_sanitizes_single_quote(self):
        """Verify single quote doesn't break query"""
        malicious_input = "'; DROP TABLE users; --"
        result = search_users(malicious_input)

        # Should return empty results, not execute SQL
        assert result == []

        # Verify users table still exists
        assert User.query.count() > 0

    def test_search_sanitizes_union_attack(self):
        """Verify UNION injection doesn't expose data"""
        malicious_input = "' UNION SELECT password FROM users --"
        result = search_users(malicious_input)

        # Should not contain password data
        for user in result:
            assert 'password' not in str(user).lower()

    def test_search_uses_parameterized_query(self):
        """Verify implementation uses parameterized query (whitebox)"""
        # Static analysis check - ensure code uses parameters not concatenation
        with open('src/search.py', 'r') as f:
            code = f.read()
            # Should use execute(query, (param,)) not f"...{param}..."
            assert 'execute(' in code
            assert 'f"SELECT' not in code  # No f-string queries
            assert 'f\'SELECT' not in code
```

**Pattern 2: Negative Security Testing** (Test what SHOULDN'T work)

```javascript
describe('Authentication Security', () => {
  it('should reject weak passwords', async () => {
    const weakPasswords = [
      'password',      // Common password
      '12345678',      // Sequential numbers
      'abc12345',      // No uppercase or special chars
      'Pass1',         // Too short
    ];

    for (const weak of weakPasswords) {
      await expect(
        register({ email: 'test@example.com', password: weak })
      ).rejects.toThrow('Password does not meet strength requirements');
    }
  });

  it('should enforce rate limiting on login attempts', async () => {
    const credentials = { email: 'test@example.com', password: 'wrong' };

    // First 5 attempts should get "invalid credentials"
    for (let i = 0; i < 5; i++) {
      await expect(login(credentials)).rejects.toThrow('Invalid credentials');
    }

    // 6th attempt should be rate limited
    await expect(login(credentials)).rejects.toThrow('Too many attempts');
  });

  it('should invalidate session on logout', async () => {
    const { token } = await login(validCredentials);
    await logout(token);

    // Token should no longer work
    await expect(
      fetchProfile(token)
    ).rejects.toThrow('Unauthorized');
  });
});
```

**Pattern 3: Security Regression Prevention**

```python
def test_cve_2023_12345_fixed():
    """
    Regression test for CVE-2023-12345: Path traversal vulnerability.

    Vulnerability: File download endpoint didn't sanitize filename,
    allowing access to arbitrary files via path traversal.

    Fix: Added filename whitelist validation in commit abc123.

    This test ensures vulnerability doesn't reappear during refactoring.
    """
    malicious_filenames = [
        '../../../etc/passwd',
        '..\\..\\..\\windows\\system32\\config\\sam',
        'allowed_file.pdf/../../../etc/passwd',
    ]

    for filename in malicious_filenames:
        with pytest.raises(ValidationError, match='Invalid filename'):
            download_file(filename)
```

### Cross-SOP Security Integration

**When to Reference Other SOPs** (Fallback Chain: Project → User → Plugin):

1. **For Security Test Patterns**: See `testing-guide.md` → "AI-Specific TDD Enforcement" → Security Testing subsection
   - Comprehensive test suite generation from threat models
   - TDD workflow for security features
   - Coverage requirements for security-critical code (100%)

2. **For Error Handling Security**: See `architecture-patterns.md` → "Error Handling Patterns"
   - Secure error messages (don't leak stack traces, DB info)
   - Exception hierarchies for security failures
   - Fail-secure patterns (default deny, explicit allow)

3. **For Frontend Security**: See `frontend-guidelines.md` → "Security" section
   - XSS prevention (CSP, auto-escaping templates)
   - CSRF protection (tokens, SameSite cookies)
   - Secure storage (no sensitive data in localStorage)

4. **For Git Security Hooks**: See `git-and-deployment.md` → "Pre-commit Security Gates"
   - Secret scanning automation
   - Dependency vulnerability blocking
   - SAST integration in CI/CD

5. **For Simplicity in Security**: Apply KISS principle from Core Principles
   - Use vetted libraries vs custom crypto
   - Prefer simple, proven patterns vs complex "more secure" designs
   - Security through simplicity (less code = less attack surface)

**AI Agent Note**: Security is a cross-cutting concern. ALWAYS reference specialized SOPs for domain-specific patterns. Security testing references testing-guide.md, secure architecture references architecture-patterns.md, etc. Don't reinvent security patterns.

---

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

---

## AI Security Anti-Patterns

> **Purpose**: Concrete examples of WRONG and RIGHT security approaches with evidence-based rationale. AI models learn better from examples than abstract rules.

### Anti-Pattern 1: Trusting "Internal" Input Sources

**DON'T:**

```python
# Assuming internal API responses are safe
def process_user_data(user_id: int):
    # Fetch from internal service - no validation
    user_data = internal_api.get_user(user_id)

    # Direct database query with unvalidated data
    query = f"SELECT * FROM orders WHERE user_email = '{user_data['email']}'"
    results = db.execute(query)
    return results
```

**Why This is Wrong:**
- Internal services can be compromised (supply chain attack)
- Attacker who compromises user service can inject malicious data
- No defense-in-depth if one layer breached

**DO:**

```python
# Validate ALL input, even from internal sources
def process_user_data(user_id: int):
    # Fetch from internal service
    user_data = internal_api.get_user(user_id)

    # VALIDATE even internal data
    validated_email = EmailStr(user_data['email'])  # Pydantic validation

    # Use parameterized query
    query = "SELECT * FROM orders WHERE user_email = ?"
    results = db.execute(query, (validated_email,))
    return results
```

**Why This Works:**
- Defense-in-depth: validation at every boundary
- Mitigates supply chain attacks
- Prevents injection even if internal service compromised

**Evidence**: OWASP Top 10 2021 (A03:2021 Injection) requires validation at all trust boundaries, not just external inputs.

---

### Anti-Pattern 2: Weak Password Storage

**DON'T:**

```javascript
// Storing passwords with MD5 or SHA-256 (too fast, vulnerable to rainbow tables)
const hashPassword = (password) => {
  return crypto.createHash('md5').update(password).digest('hex');
};

// Or even worse - plain text
const storePassword = (password) => {
  db.users.insert({ password: password });  // ❌ NEVER DO THIS
};
```

**Why This is Wrong:**
- MD5/SHA-256 are TOO FAST (millions of hashes per second on GPU)
- Vulnerable to rainbow table attacks
- No salt = same password = same hash (pattern leakage)

**DO:**

```javascript
// Use bcrypt (slow, salted, industry standard)
const bcrypt = require('bcrypt');

const hashPassword = async (password) => {
  // Cost factor 12 = ~250ms to hash (makes brute force infeasible)
  const saltRounds = 12;
  return await bcrypt.hash(password, saltRounds);
};

// Or use Argon2 (even better - OWASP recommended)
const argon2 = require('argon2');

const hashPasswordArgon2 = async (password) => {
  return await argon2.hash(password, {
    type: argon2.argon2id,  // Hybrid (CPU + memory hard)
    memoryCost: 65536,      // 64 MiB
    timeCost: 3,            // 3 iterations
    parallelism: 4          // 4 threads
  });
};
```

**Why This Works:**
- bcrypt/Argon2 are DELIBERATELY SLOW (defeats brute force)
- Automatic salting (unique hash per password)
- Resistant to GPU/ASIC attacks (Argon2 especially)

**Evidence**: OWASP Password Storage Cheat Sheet recommends Argon2id > bcrypt > scrypt > PBKDF2. NEVER use MD5/SHA for passwords.

---

### Anti-Pattern 3: Logging Sensitive Data

**DON'T:**

```python
# Logging complete request with sensitive data
@app.route('/api/login', methods=['POST'])
def login():
    logger.info(f"Login attempt: {request.json}")  # ❌ Logs password!

    user = authenticate(request.json['username'], request.json['password'])

    if user:
        logger.info(f"User {user.id} logged in with token: {user.token}")  # ❌ Logs token!
        return {"token": user.token}

    logger.error(f"Failed login for {request.json['username']} with password {request.json['password']}")  # ❌❌❌
    return {"error": "Invalid credentials"}, 401
```

**Why This is Wrong:**
- Passwords in logs = security breach if logs compromised
- Tokens in logs = session hijacking vulnerability
- Logs often stored unencrypted, shipped to third parties (Sentry, Datadog)

**DO:**

```python
# Log only non-sensitive identifiers and outcomes
@app.route('/api/login', methods=['POST'])
def login():
    username = request.json.get('username')
    password = request.json.get('password')

    # Log attempt WITHOUT sensitive data
    logger.info("login_attempt", extra={"username": username})

    user = authenticate(username, password)

    if user:
        # Log success WITHOUT token
        logger.info("login_success", extra={"user_id": user.id, "ip": request.remote_addr})
        return {"token": user.token}

    # Log failure WITHOUT password
    logger.warning("login_failure", extra={
        "username": username,
        "ip": request.remote_addr,
        "reason": "invalid_credentials"
    })
    return {"error": "Invalid credentials"}, 401
```

**Why This Works:**
- Sufficient context for debugging (username, user_id, IP, outcome)
- No sensitive data exposure (password, token excluded)
- Safe to ship logs to external services

**Evidence**: GDPR/PCI-DSS prohibit logging sensitive data. OWASP Logging Guide: "Never log authentication credentials or session tokens."

---

### Anti-Pattern 4: Client-Side Security Validation Only

**DON'T:**

```javascript
// Frontend validation only (easily bypassed)
function submitPayment(amount, userId) {
  // Validation only in browser - attacker can bypass
  if (amount > 1000) {
    alert("Maximum payment is $1000");
    return;
  }

  // Send to server - NO server-side validation
  fetch('/api/payment', {
    method: 'POST',
    body: JSON.stringify({ amount, userId })
  });
}
```

**Why This is Wrong:**
- Attacker bypasses frontend (curl, Postman, modified JavaScript)
- No server-side validation = arbitrary payment amounts
- Client-side validation is UX, NOT security

**DO:**

```javascript
// Frontend validation for UX
function submitPayment(amount, userId) {
  if (amount > 1000) {
    alert("Maximum payment is $1000");
    return;
  }

  fetch('/api/payment', {
    method: 'POST',
    body: JSON.stringify({ amount, userId })
  });
}

// CRITICAL: Server-side validation (NEVER trust client)
@app.route('/api/payment', methods=['POST'])
def process_payment():
    data = request.json

    # MUST validate on server
    if not isinstance(data['amount'], (int, float)):
        return {"error": "Invalid amount type"}, 400

    if data['amount'] <= 0:
        return {"error": "Amount must be positive"}, 400

    if data['amount'] > 1000:
        return {"error": "Amount exceeds limit"}, 400

    # MUST verify user authorization
    if not current_user.id == data['userId']:
        return {"error": "Unauthorized"}, 403

    # Process payment...
```

**Why This Works:**
- Defense-in-depth: frontend UX + backend security
- Server validation cannot be bypassed
- Protects against malicious clients

**Evidence**: OWASP Top 10 2021 (A04:2021 Insecure Design) - "Validation must occur on trusted system, not client."

---

### Anti-Pattern 5: Hardcoded Secrets in Code

**DON'T:**

```python
# Hardcoded API keys (visible in source control)
DATABASE_URL = "postgresql://admin:SuperSecret123@db.example.com/prod"
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
STRIPE_API_KEY = "sk_live_51H..."

def connect_database():
    return psycopg2.connect(DATABASE_URL)
```

**Why This is Wrong:**
- Secrets in git history FOREVER (even if deleted later)
- Visible to anyone with repo access
- Leaked in public repos = instant breach
- Cannot rotate without code change + deployment

**DO:**

```python
# Load secrets from environment variables (12-factor app pattern)
import os
from dotenv import load_dotenv

load_dotenv()  # Load from .env file (gitignored)

DATABASE_URL = os.getenv("DATABASE_URL")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_KEY")
STRIPE_API_KEY = os.getenv("STRIPE_API_KEY")

# Validate required secrets on startup
if not all([DATABASE_URL, AWS_SECRET_KEY, STRIPE_API_KEY]):
    raise RuntimeError("Missing required environment variables")

def connect_database():
    return psycopg2.connect(DATABASE_URL)
```

**Even Better: Use Secrets Management**

```python
# Production: Use AWS Secrets Manager, HashiCorp Vault, etc.
import boto3

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return response['SecretString']

DATABASE_URL = get_secret("prod/database/url")
```

**Why This Works:**
- Secrets not in source control
- Different secrets per environment (dev/staging/prod)
- Can rotate secrets without code changes
- Centralized audit trail (who accessed which secret)

**Evidence**: OWASP Top 10 2021 (A05:2021 Security Misconfiguration). Pre-commit hooks detect secrets (git-secrets, trufflehog).

---

### Anti-Pattern 6: Insufficient Error Information Hiding

**DON'T:**

```python
# Leaking stack traces and database info to users
@app.errorhandler(Exception)
def handle_error(e):
    # ❌ Exposes internal details to attacker
    return {
        "error": str(e),
        "stack_trace": traceback.format_exc(),
        "database": "PostgreSQL 14.2 on db-prod-01.internal",
        "file": e.__traceback__.tb_frame.f_code.co_filename,
        "line": e.__traceback__.tb_lineno
    }, 500
```

**Why This is Wrong:**
- Stack traces reveal internal paths, library versions
- Database version info aids exploitation
- File paths expose project structure
- Helps attacker refine their attack

**DO:**

```python
# Hide internal details, log for debugging
import logging

logger = logging.getLogger(__name__)

@app.errorhandler(Exception)
def handle_error(e):
    # Log full details internally (for developers)
    logger.error("Internal error",
        exc_info=True,
        extra={
            "error_type": type(e).__name__,
            "user_id": getattr(current_user, 'id', None),
            "request_id": request.headers.get('X-Request-ID')
        }
    )

    # Return generic error to user (no internal details)
    if isinstance(e, ValidationError):
        return {"error": "Invalid input provided"}, 400
    elif isinstance(e, AuthenticationError):
        return {"error": "Authentication failed"}, 401
    else:
        # Generic 500 error
        return {"error": "An internal error occurred"}, 500
```

**Why This Works:**
- Full details logged internally for debugging
- Generic errors to users (no information leakage)
- Error categorization for appropriate responses

**Evidence**: OWASP Top 10 2021 (A05:2021 Security Misconfiguration) - "Error handling should not reveal internal details."

---

## Security Testing Requirements

> **Purpose**: Systematic security testing that integrates with TDD workflow. References testing-guide.md for TDD methodology, applies security-specific patterns.

### Security Test Coverage Requirements

**Minimum Coverage Standards:**

| Code Type | Security Test Coverage | Rationale |
|-----------|----------------------|-----------|
| **Authentication/Authorization** | 100% | Breach = complete system compromise |
| **Input Validation** | 100% | Primary injection defense |
| **Cryptographic Operations** | 100% | Failure = data exposure |
| **Payment Processing** | 100% | Financial impact, regulatory compliance |
| **User-Facing APIs** | 95% | High exposure to attacks |
| **Internal APIs** | 85% | Lower exposure but still critical |

**Cross-Reference**: See `testing-guide.md` → "Coverage Enforcement for AI Agents" for general coverage requirements. Security-critical code requires 100% coverage (overrides standard 80%).

### OWASP Top 10 Test Checklist

For each OWASP category relevant to your feature, implement systematic tests:

**A01:2021 - Broken Access Control**

```python
class TestAccessControl:
    def test_user_cannot_access_other_users_data(self):
        """Horizontal privilege escalation prevention"""
        user1 = create_user()
        user2 = create_user()

        # User1 tries to access User2's data
        with pytest.raises(ForbiddenError):
            get_user_profile(user2.id, authenticated_as=user1)

    def test_regular_user_cannot_access_admin_endpoints(self):
        """Vertical privilege escalation prevention"""
        regular_user = create_user(role='user')

        with pytest.raises(ForbiddenError):
            delete_all_users(authenticated_as=regular_user)

    def test_unauthenticated_access_denied(self):
        """Authentication requirement"""
        with pytest.raises(UnauthorizedError):
            get_user_profile(user_id=123, authenticated_as=None)
```

**A02:2021 - Cryptographic Failures**

```javascript
describe('Password Security', () => {
  it('should hash passwords with bcrypt (not plaintext)', async () => {
    const password = 'MySecurePass123!';
    const user = await createUser({ email: 'test@example.com', password });

    // Password should be hashed
    expect(user.password_hash).not.toBe(password);
    expect(user.password_hash.length).toBeGreaterThan(20);
    expect(user.password_hash).toMatch(/^\$2[aby]\$/); // bcrypt format
  });

  it('should use different salts for same password', async () => {
    const password = 'SamePassword123!';
    const user1 = await createUser({ email: 'user1@example.com', password });
    const user2 = await createUser({ email: 'user2@example.com', password });

    // Same password, different hashes (salted)
    expect(user1.password_hash).not.toBe(user2.password_hash);
  });
});
```

**A03:2021 - Injection**

```python
def test_sql_injection_prevention():
    """Verify parameterized queries prevent SQL injection"""
    # Reference: security-and-performance.md OWASP A03:2021

    malicious_inputs = [
        "'; DROP TABLE users; --",
        "' OR '1'='1",
        "' UNION SELECT password FROM users --",
        "admin'--",
    ]

    for malicious in malicious_inputs:
        # Should return empty or error, not execute SQL
        result = search_users(malicious)
        assert isinstance(result, list)
        assert len(result) == 0

        # Verify users table still exists
        assert User.query.count() > 0
```

### Security Test Automation Integration

**Pre-Commit Security Test Gate:**

```bash
# From git-and-deployment.md SOP - security test enforcement

#!/bin/bash
# .git/hooks/pre-commit

# Run security-specific tests
pytest tests/security/ -v --tb=short

if [ $? -ne 0 ]; then
  echo "❌ COMMIT BLOCKED: Security tests failing"
  echo "Run 'pytest tests/security/ -v' to see failures"
  exit 1
fi

# Run SAST scanner
semgrep --config=auto --error

if [ $? -ne 0 ]; then
  echo "❌ COMMIT BLOCKED: Security vulnerabilities detected"
  exit 1
fi

echo "✅ Security tests passed, SAST clean"
```

### Penetration Testing Guidance

**When to Perform Manual Penetration Testing:**

1. **Before production launch** - Full security audit
2. **After major security feature changes** - Authentication, authorization, payment processing
3. **Quarterly for high-risk systems** - Financial, healthcare, government

**Automated Security Scanning (Continuous):**

```bash
# DAST (Dynamic Application Security Testing)
zap-cli quick-scan --self-contained https://staging.example.com

# Dependency scanning
npm audit --audit-level=moderate
snyk test --severity-threshold=high

# Container scanning (if using Docker)
trivy image myapp:latest --severity HIGH,CRITICAL
```

### Security Incident Response Testing

**Test disaster recovery scenarios:**

```python
def test_security_breach_response():
    """Verify incident response procedures work"""

    # Simulate: attacker obtains database dump
    simulate_database_breach()

    # Verify: sessions invalidated
    old_sessions = Session.query.filter(Session.created_at < datetime.now()).all()
    for session in old_sessions:
        assert not session.is_valid()

    # Verify: users notified (check notification queue)
    notifications = get_pending_notifications()
    assert len(notifications) == User.query.count()
    assert all('security breach' in n.message.lower() for n in notifications)

    # Verify: forced password reset on next login
    users = User.query.all()
    assert all(u.requires_password_reset for u in users)
```

**Cross-Reference**: See `architecture-patterns.md` → "Error Handling Patterns" for secure error handling. See `testing-guide.md` → "AI-Specific TDD Enforcement" for TDD methodology applied to security features.

---

## Related Standard Operating Procedures

**For comprehensive development guidance, reference these SOPs via fallback chain:**

1. `.rptc/sop/[name].md` - Project-specific overrides
2. `~/.claude/global/sop/[name].md` - User global defaults
3. `${CLAUDE_PLUGIN_ROOT}/sop/[name].md` - Plugin defaults

**Cross-SOP Integration:**

- **Security Testing Methodology**: See `testing-guide.md` for TDD workflow, coverage requirements, test-driven generation patterns applied to security features
- **Secure Architecture Patterns**: See `architecture-patterns.md` for error handling security, fail-secure patterns, exception hierarchies
- **Security in Git Workflow**: See `git-and-deployment.md` for pre-commit security gates, secret scanning, dependency audit automation, CI/CD security integration
- **Simplicity in Security**: Apply KISS/YAGNI/DRY principles from Core Principles (prefer vetted libraries vs custom crypto, simple proven patterns vs complex designs)
- **Frontend Security**: See `frontend-guidelines.md` for XSS prevention, CSRF protection, CSP headers, secure client-side storage

**AI Agent Note**: Security is a cross-cutting concern that touches every SOP. ALWAYS reference the specialized SOP for domain-specific patterns. Security testing references testing-guide.md, secure architecture references architecture-patterns.md, etc. Don't reinvent security patterns that already exist in specialized SOPs.

---

## Changelog

**Version 2.0.0 - AI-Specific Security Enforcement** (Phase 1 Foundation)
- Added AI-Specific Security Enforcement section (322% vulnerability reduction research)
- Added Security Validation Workflow (4-phase threat modeling → secure implementation)
- Added CRITICAL security validation checkpoint (pre-commit gates)
- Added AI Security Testing Patterns (3 systematic patterns with code examples)
- Added AI Security Anti-Patterns (6 common mistakes with DON'T/DO/Why/Evidence)
- Added Security Testing Requirements (OWASP Top 10 test checklist, coverage requirements)
- Enhanced cross-SOP references (testing-guide.md, architecture-patterns.md, git-and-deployment.md)
- Integrated with Core Principles (KISS/YAGNI in security design)
- OWASP Top 10 2021 alignment verification

**Version 1.0.0 - Foundation** (Original)
- OWASP Top 10 2021 reference guide
- Authentication and authorization patterns
- Input validation examples
- Performance optimization techniques
- Monitoring and observability guidance

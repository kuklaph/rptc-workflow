# AI Coding Best Practices: Working Effectively with AI-Generated Code

## Table of Contents

1. [Quick Start: TL;DR](#quick-start-tldr)
2. [Why AI-Generated Code Differs](#why-ai-generated-code-differs)
3. [Prompting Strategy for Quality Code](#prompting-strategy-for-quality-code)
4. [Pre-Generation Checklist](#pre-generation-checklist)
5. [Red Flags: Reject Immediately](#red-flags-reject-immediately)
6. [When to Override These Guidelines](#when-to-override-these-guidelines)
7. [Integration With RPTC Workflow](#integration-with-rptc-workflow)
8. [Before/After Examples](#beforeafter-examples)
9. [Conclusion](#conclusion)
10. [References](#references)

---

## Quick Start: TL;DR

**One-Sentence Guide**: Read this before accepting AI-generated code; skim Quick Start if rushed, dive deep when diagnosing quality issues.

### 3 Key Principles

1. **Simplicity First**: AI defaults to complex solutions; explicitly demand simplicity in every prompt
2. **Reuse Over Reinvention**: Search existing code before creating new abstractions
3. **Verify Everything**: AI has systematic blind spots in security, testing, and architecture

### 5 Critical Red Flags

Reject immediately if you see:

1. **Abstract base classes / factories for single use case** - Premature abstraction
2. **Middleware / event-driven patterns for simple operations** - Over-engineered architecture
3. **Security code without input validation or parameterized queries** - Security vulnerabilities
4. **Test files with 100% pass rate but missing edge cases** - False confidence
5. **3+ layers of indirection for straightforward logic** - Unnecessary complexity

### When to Use This Guide

- **Before accepting AI code**: Run through pre-generation checklist (Section 4)
- **Code review**: Check for red flags (Section 5)
- **Troubleshooting**: Diagnose why AI code feels "wrong" (Section 2)
- **Team onboarding**: Share with developers new to AI-assisted coding

---

## Why AI-Generated Code Differs

### Systematic Blind Spots

Research from Phases 1-4 identified consistent patterns in AI-generated code:

- **Over-abstraction**: 60-80% more code than necessary for the same functionality
- **Code duplication**: 8× normal duplication rates without explicit guidance
- **Security gaps**: 322% more vulnerabilities compared to code with security checklists
- **Testing quality**: High coverage percentages but poor edge case detection

These aren't random errors—they're systematic biases baked into AI training data.

### Over-Engineering Bias

AI models default to enterprise patterns even for simple problems:

**Why This Happens:**
- Training data dominated by published libraries (which prioritize extensibility over simplicity)
- Pattern matching without context (sees "validation" → suggests validation framework)
- Complexity as proxy for sophistication (more code = better solution)
- Premature optimization for "future needs" that may never materialize

**Common Examples:**
- Factory patterns for objects with one variant
- Abstract base classes with single implementation
- Custom validation frameworks instead of using Zod/Pydantic
- Event-driven architecture for simple CRUD operations
- Repository pattern with single data source

### Impact on Code Quality

The over-engineering bias creates real problems:

**Increased Maintenance Burden:**
- More code = more bugs to fix
- Each abstraction layer is a potential failure point
- Changes require modifying multiple files instead of one

**Harder Debugging:**
- Abstraction layers hide actual behavior
- Stack traces cross 5+ files for simple operations
- Mental model complexity grows exponentially

**Reduced Readability:**
- Junior developers can't understand code on first reading
- Clever solutions replace explicit logic
- "How does this work?" becomes common question

**False Confidence:**
- Tests pass but miss critical edge cases
- High coverage percentage masks poor test quality
- Security vulnerabilities hidden behind working features

### Root Cause Analysis

AI models learn from what's published online:

- Open-source libraries emphasize **extensibility** (support unknown future use cases)
- Documentation teaches **general patterns** (work for many scenarios)
- Published code optimized for **unknown audiences** (enterprise scale by default)

Your codebase needs **simplicity** (solve today's problem), **specific patterns** (match your domain), and **appropriate scale** (current requirements).

**Key Insight**: AI doesn't know you have 100 users, not 10 million. You must explicitly constrain scope.

---

## Prompting Strategy for Quality Code

### Use Extended Thinking Modes

Claude Code offers three thinking levels—use them strategically:

| Mode | Token Budget | Best For | Example Task |
|------|--------------|----------|--------------|
| **Standard** | ~4K tokens | Quick tasks, low ambiguity | Add logging to function |
| **Think Hard** | ~10K tokens | Medium complexity, multiple factors | Design API endpoint |
| **Ultrathink** | ~32K tokens | Complex planning, architecture | Plan multi-system integration |

**Decision Matrix:**
- Standard: <2 integration points, established patterns exist
- Think Hard: 2-5 integration points, moderate ambiguity
- Ultrathink: >5 integration points, architectural decisions required

**How to Specify:**
```plaintext
"Use think hard mode: Design a caching layer for the API..."
```

### Explicit Simplicity Directives

AI won't default to simple—you must demand it:

**Effective Phrases:**
- "Write the SIMPLEST possible solution"
- "Prefer explicit over clever"
- "Avoid abstractions until 3+ use cases exist"
- "Would a junior developer understand this on first reading?"
- "Optimize for readability, not extensibility"

**Before/After Example:**

❌ **Without directive**: "Create a user authentication system"
→ AI generates 200+ lines with factories, strategies, abstract base classes

✅ **With directive**: "Create the SIMPLEST user authentication using bcrypt. No abstractions until we need multiple hash algorithms."
→ AI generates 15 lines with direct bcrypt calls

### Examine Existing Code First (Surgical Coding)

Force AI to search before creating:

**Effective Prompts:**
- "Find 3 similar implementations in this codebase first"
- "Can this be done by modifying ONE existing file?"
- "What patterns already exist for this problem?"
- "Show me how the existing code handles similar cases"

**Example Workflow:**
```plaintext
User: "I need to add rate limiting to the API"

Better prompt:
"First, search the codebase for 'rate limit' or 'throttle'.
If patterns exist, extend them. If not, use the SIMPLEST
approach with express-rate-limit package. No custom middleware."
```

This prevents reinventing functionality that already exists.

### Audience Constraint Technique

Frame the task for a specific skill level:

**Junior Developer Audience:**
- "Explain like I'm a junior developer with 6 months experience"
- "Use no abstractions I haven't seen before in this codebase"
- "Write code that's obvious without reading documentation"

**Example:**
```plaintext
❌ "Create a flexible caching abstraction"
✅ "Create simple caching using Map. Junior dev should understand it immediately. Add Redis later if needed."
```

**Why This Works**: AI adjusts complexity to match audience. Junior developers need explicit code, not clever abstractions.

---

## Pre-Generation Checklist

**Use this checklist BEFORE accepting ANY AI-generated code.**

### The 4-Point Verification

- [ ] **Simplicity Check**: Is this the simplest solution? Could I solve this with half the code?
- [ ] **Reuse Check**: Did AI search for existing patterns? Are we reinventing the wheel?
- [ ] **Abstraction Check**: Are abstractions justified by 3+ actual use cases (not speculative)?
- [ ] **Understandability Check**: Would a junior developer understand this on first reading?

### How to Apply

**If ANY check fails:**
1. **Reject immediately** - Don't try to fix over-engineered code
2. **Request revision** with specific simplicity directive
3. **Provide examples** of existing patterns to match
4. **Reduce scope** - maybe AI is solving a bigger problem than you asked for

**Example Rejection:**
```plaintext
❌ AI generated: Custom validation framework (60 lines)

Your response:
"This fails the Simplicity Check and Reuse Check. We already use
Zod in this codebase. Rewrite using Zod schema. Should be <15 lines."
```

### Common Failure Patterns

**Simplicity Check Failures:**
- Abstract classes with single implementation
- Builder pattern for objects with <5 properties
- Custom framework instead of library

**Reuse Check Failures:**
- Created new utility when one exists in `/lib/utils`
- Custom error handling instead of using app's error handler
- Reinvented authentication instead of using existing auth middleware

**Abstraction Check Failures:**
- Strategy pattern for unchanging behavior
- Factory for single object type
- Interface with one implementation

**Understandability Check Failures:**
- Requires reading 3+ files to understand one function
- Uses obscure language features without comments
- Clever one-liners instead of explicit loops

---

## Red Flags: Reject Immediately

### Complexity Red Flags

**Abstract Base Classes with Single Implementation**
```typescript
❌ abstract class HashStrategy { ... }
   class BcryptHashStrategy implements HashStrategy { ... }
   // Only one implementation exists - premature abstraction
```

**Factory Patterns for Objects with One Variant**
```typescript
❌ class UserFactory {
     static create(type: string): User { ... }
   }
   // Only 'standard' user type exists - unnecessary factory
```

**Strategy Pattern for Unchanging Behavior**
```typescript
❌ interface SortStrategy { sort(items: any[]): any[] }
   // Sorting algorithm never changes - just use Array.sort()
```

**Builder Pattern for Simple Objects**
```typescript
❌ new UserBuilder()
     .setName('John')
     .setEmail('john@example.com')
     .build();
   // User has 3 properties - just use object literal
```

**Middleware for Simple Sequential Logic**
```typescript
❌ // 5 middleware functions for what should be 10 lines
   app.use(validateInput);
   app.use(checkAuth);
   app.use(loadUser);
   app.use(processRequest);
   app.use(formatResponse);
```

### Security Red Flags

**String Concatenation for SQL Queries**
```sql
❌ const query = `SELECT * FROM users WHERE id = ${userId}`;
   // SQL injection vulnerability
```

**Missing Input Validation at Boundaries**
```typescript
❌ app.post('/api/users', (req, res) => {
     const user = req.body; // No validation - accepts malicious input
     database.save(user);
   });
```

**Hardcoded Secrets (Even "Placeholders")**
```typescript
❌ const API_KEY = 'placeholder_key_123';
   // Will be committed and forgotten - use env vars from start
```

**Auth Without Rate Limiting**
```typescript
❌ app.post('/login', async (req, res) => {
     // No rate limiting - vulnerable to brute force
     const user = await authenticate(req.body);
   });
```

**Missing HTTPS/Secure Headers**
```typescript
❌ app.listen(3000); // No HTTPS enforcement
   // No helmet() middleware for security headers
```

### Over-Engineering Red Flags

**Event-Driven Architecture for CRUD Operations**
```typescript
❌ eventBus.publish('USER_CREATED', userData);
   // Simple create operation doesn't need events
```

**Microservices for <3 Bounded Contexts**
```typescript
❌ // Separate services for users, posts, comments
   // These are tightly coupled - monolith is simpler
```

**Repository Pattern with Single Data Source**
```typescript
❌ class UserRepository {
     // Only uses Postgres - no abstraction needed yet
   }
```

**Saga Pattern for Non-Distributed Transactions**
```typescript
❌ // Orchestrating local database operations with saga
   // Just use database transactions
```

**CQRS for Read-Heavy Simple Domains**
```typescript
❌ // Separate read/write models for basic CRUD
   // Adds complexity without scaling benefit
```

### Testing Red Flags

**100% Coverage But No Edge Cases**
```typescript
❌ test('creates user', () => {
     const user = createUser({ name: 'John', email: 'john@example.com' });
     expect(user.name).toBe('John');
   });
   // Missing: null name, invalid email, duplicate email, SQL injection
```

**Only Happy Path Tests**
```typescript
❌ // 10 tests, all succeed
   // Zero tests for errors, timeouts, invalid input
```

**Mocks More Complex Than Real Implementation**
```typescript
❌ const mockDatabase = {
     query: jest.fn()
       .mockImplementationOnce(() => Promise.resolve([]))
       .mockImplementationOnce(() => Promise.reject(new Error()))
       .mockImplementationOnce(() => Promise.resolve([{ id: 1 }]));
   };
   // Mock is harder to understand than real database call
```

**Tests That Don't Fail When Code Removed**
```typescript
❌ test('validates email', () => {
     expect(true).toBe(true); // Passes even if validation removed
   });
```

---

## When to Override These Guidelines

### Legitimate Complexity Is Justified

Not all complexity is bad. Override guidelines when:

**Business Domain Is Inherently Complex**
- Financial calculations with regulatory requirements
- Medical algorithms with safety-critical logic
- Tax computation with jurisdiction-specific rules
- Insurance underwriting with complex decision trees

**Regulatory Compliance Requires Specific Patterns**
- Audit trails for financial transactions (event sourcing may be required)
- HIPAA-compliant data encryption (specific encryption patterns mandated)
- SOC2 compliance (certain architectural patterns required)

**Scale Requirements Demand Optimization**
- 1M+ requests/second (caching layers, load balancing required)
- Real-time processing with <10ms latency (premature optimization actually needed)
- Handling 100GB+ datasets (specialized data structures required)

**Migration from Legacy System Dictates Interface**
- Strangler fig pattern for gradual replacement (temporary dual systems)
- Adapter pattern for incompatible interfaces (technical debt reduction)
- Facade pattern for complex third-party APIs (isolation necessary)

### How to Document Overrides

When complexity IS justified, document it:

**In-Code Rationale:**
```typescript
// COMPLEXITY JUSTIFIED: PCI-DSS compliance requires separate
// encryption strategies for card data (AES-256) vs PII (tokenization)
abstract class EncryptionStrategy {
  // ... (pattern required by compliance, not over-engineering)
}
```

**In Architecture Decision Records:**
```markdown
# ADR-023: Event Sourcing for Transaction Audit Trail

**Status**: Accepted

**Context**: SEC regulations require complete audit trail of all
financial transactions with immutable history.

**Decision**: Implement event sourcing for transaction domain.

**Consequences**: Adds complexity but required for compliance.
Simpler approaches attempted and rejected by auditors.
```

**In `.context/architecture-decisions.md`:**
- Document specific requirement (regulation, performance benchmark, migration constraint)
- Include "simpler approach tried and failed" note
- Reference external requirement (link to regulation, benchmark results)

### Red Flag Override Example

```typescript
// COMPLEXITY JUSTIFIED: Multi-region deployment (EU, US, APAC)
// requires region-specific encryption keys per GDPR Art. 32
class RegionalEncryptionFactory {
  create(region: string): EncryptionStrategy {
    // Factory pattern required - different encryption per region
  }
}
```

**Why This Override Is Valid:**
- Legal requirement (GDPR) not speculative future need
- 3+ actual implementations (EU, US, APAC keys)
- Simpler approach (single encryption) violates regulation
- Documented with specific article reference

---

## Integration With RPTC Workflow

### Research Phase: Pattern Discovery

**Apply Best Practices:**
- **Search for existing patterns** before proposing new solutions
- Use `rg "validation" -t ts` to find how codebase currently validates
- Document **simplicity constraints** found in existing code
- Identify **anti-patterns** to avoid (document in research findings)

**Example Research Task:**
```plaintext
/rptc:research "How does our codebase currently handle API authentication?"

Expected output:
- Lists existing auth middleware
- Shows usage patterns across 5 endpoints
- Identifies simplicity: all use same JWT approach
- Recommendation: extend existing middleware, don't create new
```

**Red Flag Detection in Research:**
- If existing code uses factories, document WHY (may be technical debt)
- Note over-engineered areas to refactor (not replicate)
- Highlight simple patterns to emulate

### Planning Phase: Simplicity Checkpoints

**Apply Best Practices:**
- Include **simplicity checkpoint** in test strategy
- Specify "examine existing code first" requirement explicitly
- Define **architecture constraints** upfront (no new abstractions without approval)
- Add **red flag checklist** to acceptance criteria

**Example Plan Section:**
```markdown
## Test Strategy

### Code Quality Gates
- [ ] Simplicity check: <50 lines per new function
- [ ] Reuse check: Extends existing patterns (not new framework)
- [ ] Abstraction check: All abstractions have 3+ use cases
- [ ] Red flag check: Zero items from Section 5 of AI_CODING_BEST_PRACTICES.md

### Pre-Implementation Requirements
1. Search codebase for existing solutions
2. Identify simplest possible approach
3. Get approval before introducing new patterns
```

### TDD Phase: Quality Enforcement

**Apply Best Practices:**
- **RED Phase**: Write tests for edge cases, not just happy path
- **GREEN Phase**: Run red flag check BEFORE accepting AI implementation
- **REFACTOR Phase**: Simplify toward minimal working code
- **VERIFY Phase**: Ensure edge cases covered (not just coverage percentage)

**Integration Points:**
```plaintext
RED Phase:
→ Ensure tests cover Section 5 scenarios (SQL injection, missing validation, etc.)

GREEN Phase:
→ Run Pre-Generation Checklist (Section 4) before accepting AI code
→ If red flags detected, reject and re-prompt with simplicity directive

REFACTOR Phase:
→ Remove unnecessary abstractions
→ Consolidate duplicate code
→ Simplify 3+ layer indirection to direct calls

VERIFY Phase:
→ Check test quality (not just coverage %)
→ Ensure edge cases from red flags list are tested
```

### Quality Gates: Automated Verification

**Code Review Agent** (executes after TDD phase):
- Runs **complexity analysis** (cyclomatic complexity, nesting depth)
- Detects **over-abstraction** (abstract classes with single implementation)
- Flags **unnecessary patterns** (factories with one variant)
- References this guide's Section 5 in findings

**Security Agent** (executes after efficiency review):
- Checks for **security red flags** from Section 5
- Validates **input validation** exists at boundaries
- Verifies **parameterized queries** (no string concatenation)
- Confirms **secrets in env vars** (not hardcoded)

**Pre-Commit Hooks** (automated enforcement):
- Blocks commits with obvious anti-patterns
- Runs linters configured to detect red flags
- Requires test coverage of edge cases
- Enforces conventional commit messages

---

## Before/After Examples

### Example 1: Simple Feature - Authentication Helper

**Scenario**: Hash and verify user passwords

**Before (AI Default - 45 lines):**
```typescript
// Abstract factory with strategy pattern for single hash algorithm
abstract class HashStrategy {
  abstract hash(input: string): Promise<string>;
  abstract verify(input: string, hash: string): Promise<boolean>;
}

class BcryptHashStrategy implements HashStrategy {
  async hash(input: string): Promise<string> {
    return bcrypt.hash(input, 10);
  }

  async verify(input: string, hash: string): Promise<boolean> {
    return bcrypt.compare(input, hash);
  }
}

class HashFactory {
  private strategies: Map<string, HashStrategy> = new Map();

  register(name: string, strategy: HashStrategy): void {
    this.strategies.set(name, strategy);
  }

  create(name: string): HashStrategy {
    const strategy = this.strategies.get(name);
    if (!strategy) throw new Error(`Unknown strategy: ${name}`);
    return strategy;
  }
}

export class PasswordService {
  private hashFactory: HashFactory;

  constructor() {
    this.hashFactory = new HashFactory();
    this.hashFactory.register('bcrypt', new BcryptHashStrategy());
  }

  async hashPassword(password: string): Promise<string> {
    return this.hashFactory.create('bcrypt').hash(password);
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return this.hashFactory.create('bcrypt').verify(password, hash);
  }
}
```

**After (Surgical Coding - 8 lines):**
```typescript
// Simple bcrypt wrapper - no abstraction until we need multiple algorithms
export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

**Why Better**:
- **82% less code** (45 → 8 lines)
- **No premature abstraction** (will add factory when second algorithm needed)
- **Immediately clear behavior** (no navigating classes to understand)
- **Junior developer friendly** (obvious what functions do)

**Red Flags Eliminated**:
- ✅ Abstract base class with single implementation
- ✅ Factory pattern for single variant
- ✅ 3+ layers of indirection (factory → strategy → bcrypt)

---

### Example 2: Medium Feature - API Input Validation

**Scenario**: Validate user registration endpoint

**Before (AI Default - 60 lines with custom validation framework):**
```typescript
// Custom validation framework for single API endpoint
abstract class ValidationRule<T> {
  abstract validate(value: T): ValidationResult;
}

class ValidationResult {
  constructor(public isValid: boolean, public errors: string[]) {}
}

class EmailValidationRule extends ValidationRule<string> {
  validate(value: string): ValidationResult {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return new ValidationResult(
      emailRegex.test(value),
      emailRegex.test(value) ? [] : ['Invalid email format']
    );
  }
}

class StringLengthValidationRule extends ValidationRule<string> {
  constructor(private min: number, private max: number) { super(); }

  validate(value: string): ValidationResult {
    const isValid = value.length >= this.min && value.length <= this.max;
    return new ValidationResult(
      isValid,
      isValid ? [] : [`Length must be between ${this.min} and ${this.max}`]
    );
  }
}

class ValidationChain<T> {
  private rules: ValidationRule<T>[] = [];

  addRule(rule: ValidationRule<T>): this {
    this.rules.push(rule);
    return this;
  }

  validate(value: T): ValidationResult {
    const errors: string[] = [];
    for (const rule of this.rules) {
      const result = rule.validate(value);
      if (!result.isValid) {
        errors.push(...result.errors);
      }
    }
    return new ValidationResult(errors.length === 0, errors);
  }
}

// Usage in route
const emailChain = new ValidationChain<string>()
  .addRule(new EmailValidationRule())
  .addRule(new StringLengthValidationRule(5, 100));

const result = emailChain.validate(req.body.email);
if (!result.isValid) {
  return res.status(400).json({ errors: result.errors });
}
```

**After (Using Zod - 12 lines):**
```typescript
// Use battle-tested validation library (already in dependencies)
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email().min(5).max(100),
  password: z.string().min(8).max(128),
  name: z.string().min(1).max(50)
});

// Validation in route handler
const result = userSchema.safeParse(req.body);
if (!result.success) {
  return res.status(400).json({ errors: result.error.errors });
}
```

**Why Better**:
- **80% less code** (60 → 12 lines)
- **Battle-tested library** (Zod used by millions, custom framework untested)
- **Better error messages** (Zod provides detailed path-based errors)
- **TypeScript inference** (automatic type safety from schema)
- **Easier to extend** (adding fields is one line, not new validation classes)

**Red Flags Eliminated**:
- ✅ Custom framework instead of library (Reuse Check failure)
- ✅ Abstract base classes for simple validation
- ✅ Builder pattern (ValidationChain) for straightforward logic

---

### Example 3: Complex Feature - State Management

**Scenario**: In-memory user state for small app

**Before (AI Default - 120+ lines with custom event bus):**
```typescript
// Full event-driven architecture for simple CRUD state
interface Event {
  type: string;
  payload: any;
  timestamp: Date;
}

interface EventHandler {
  handle(event: Event): void;
}

class EventBus {
  private handlers: Map<string, EventHandler[]> = new Map();
  private eventHistory: Event[] = [];

  subscribe(eventType: string, handler: EventHandler): void {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, []);
    }
    this.handlers.get(eventType)!.push(handler);
  }

  publish(event: Event): void {
    this.eventHistory.push(event);
    const handlers = this.handlers.get(event.type) || [];
    handlers.forEach(handler => handler.handle(event));
  }

  getHistory(): Event[] {
    return [...this.eventHistory];
  }
}

class UserStateHandler implements EventHandler {
  private state: Map<string, User> = new Map();

  handle(event: Event): void {
    switch (event.type) {
      case 'USER_CREATED':
        this.state.set(event.payload.id, event.payload);
        break;
      case 'USER_UPDATED':
        this.state.set(event.payload.id, event.payload);
        break;
      case 'USER_DELETED':
        this.state.delete(event.payload.id);
        break;
    }
  }

  getUser(id: string): User | undefined {
    return this.state.get(id);
  }

  getAllUsers(): User[] {
    return Array.from(this.state.values());
  }
}

// Usage (requires event bus setup, handler registration, event publishing)
const eventBus = new EventBus();
const userHandler = new UserStateHandler();
eventBus.subscribe('USER_CREATED', userHandler);
eventBus.subscribe('USER_UPDATED', userHandler);
eventBus.subscribe('USER_DELETED', userHandler);

// Creating a user requires publishing event
eventBus.publish({
  type: 'USER_CREATED',
  payload: { id: '1', name: 'John' },
  timestamp: new Date()
});

// ... (80+ more lines of event sourcing boilerplate)
```

**After (Simple Class - 25 lines):**
```typescript
// Simple in-memory state management (add persistence when needed)
class UserStore {
  private users: Map<string, User> = new Map();

  create(user: User): void {
    this.users.set(user.id, user);
  }

  update(id: string, updates: Partial<User>): void {
    const user = this.users.get(id);
    if (!user) throw new Error('User not found');
    this.users.set(id, { ...user, ...updates });
  }

  delete(id: string): void {
    this.users.delete(id);
  }

  get(id: string): User | undefined {
    return this.users.get(id);
  }

  list(): User[] {
    return Array.from(this.users.values());
  }
}

// Usage (straightforward CRUD operations)
const userStore = new UserStore();
userStore.create({ id: '1', name: 'John' });
```

**Why Better**:
- **79% less code** (120 → 25 lines)
- **No event sourcing overhead** (add when you actually need audit trail)
- **Direct method calls** (create/update/delete obvious)
- **Easy to add persistence** (swap Map for database when needed)
- **Testable without mocking event bus**

**Red Flags Eliminated**:
- ✅ Event-driven architecture for CRUD operations
- ✅ Custom event bus for non-distributed system
- ✅ 3+ layers of indirection (eventBus → handler → state)
- ✅ Over-engineering for speculative "future needs"

**When to Use Event-Driven (Valid Override)**:
- Audit trail required by regulation (financial transactions)
- Multiple bounded contexts need coordination (microservices)
- Real-time notifications to multiple systems
- Event replay needed for debugging

For simple state management, start simple. Add events when you have concrete requirement.

---

## Conclusion

### Key Takeaways

1. **AI generates quality code but with systematic biases toward complexity** - Training data from published libraries prioritizes extensibility over simplicity
2. **Explicit prompting strategies drastically improve output quality** - "Write the SIMPLEST solution" produces 60-80% less code
3. **Pre-generation checklists prevent common pitfalls** - Four checks (simplicity, reuse, abstraction, understandability) catch most issues
4. **Red flags enable fast rejection of problematic patterns** - Abstract classes with single implementation, factories with one variant, etc.
5. **RPTC workflow integrates these practices at every phase** - Research finds patterns, Planning enforces constraints, TDD verifies quality

### Immediate Actions

**Before Your Next AI Coding Session:**
- [ ] Bookmark this guide for reference during code reviews
- [ ] Add simplicity directive to your next prompt ("Write the SIMPLEST solution")
- [ ] Run pre-generation checklist (Section 4) on next AI-generated code
- [ ] Share with team members working with AI tools

**During Code Review:**
- [ ] Check for red flags from Section 5
- [ ] Ask "Is this the simplest solution?"
- [ ] Verify abstractions have 3+ actual use cases
- [ ] Ensure tests cover edge cases, not just happy path

**When Diagnosing Issues:**
- [ ] Review Section 2 (Why AI Code Differs) to identify systematic patterns
- [ ] Check if over-engineering is root cause (60-80% more code than needed)
- [ ] Look for reinvented functionality that already exists

### Measuring Success

Track these metrics before/after applying principles:

**Code Volume Reduction:**
- Measure lines of code for new features
- Target: 60-80% reduction after applying simplicity directives
- Example: Authentication feature 45 lines → 8 lines

**Abstraction Count:**
- Count factories, abstract classes, strategies, builders
- Target: Only use when 3+ actual implementations exist
- Example: Remove 5 factories that had single variant

**Test Quality Improvement:**
- Measure edge cases covered (not just coverage %)
- Target: 5+ edge cases per feature (errors, invalid input, boundary conditions)
- Example: Validation tests cover null, overflow, injection, type errors

**Onboarding Speed:**
- Time for junior developer to understand feature
- Target: <30 minutes to understand without asking questions
- Example: State management code self-explanatory in 10 minutes

### Further Reading

**Research Findings:**
- `.rptc/research/` directory - Phases 1-4 research documents
- Phase 1: AI over-engineering patterns and quantified impacts
- Phase 2: Security blind spots and vulnerability statistics
- Phase 3: Prompting strategy effectiveness studies
- Phase 4: Best practice integration results

**RPTC Documentation:**
- `docs/RPTC_WORKFLOW_GUIDE.md` - Complete workflow overview
- `docs/PROJECT_TEMPLATE.md` - Project initialization with AI guidelines
- `sop/` directory - Standard Operating Procedures

**Standard Operating Procedures:**
- `sop/architecture-patterns.md` - Anti-pattern prohibition list and surgical coding
- `sop/security-and-performance.md` - Security verification checklist
- `sop/testing-guide.md` - Test quality requirements and edge case coverage

---

## References

### Research Documents

- **Phase 1 Research**: AI Over-Engineering Findings
  - 60-80% code volume reduction with simplicity directives
  - Factory pattern overuse (single variant implementations)
  - Abstract class proliferation without justification

- **Phase 2 Research**: Security Blind Spots
  - 322% more vulnerabilities without security checklists
  - Missing input validation at API boundaries
  - String concatenation in SQL queries

- **Phase 3 Research**: Prompting Strategy Effectiveness
  - Extended thinking modes improve architectural decisions
  - "Junior developer" audience constraint reduces complexity
  - Surgical coding approach prevents code duplication

- **Phase 4 Research**: Best Practice Integration
  - Pre-generation checklists reduce revision cycles by 75%
  - Red flag detection prevents 90% of over-engineering
  - RPTC workflow phases enforce quality gates automatically

### RPTC Standard Operating Procedures

- **`sop/architecture-patterns.md`** - Surgical coding, anti-pattern prohibition
- **`sop/security-and-performance.md`** - Security verification, input validation
- **`sop/testing-guide.md`** - Edge case coverage, test quality standards
- **`sop/languages-and-style.md`** - Language-specific conventions
- **`sop/git-and-deployment.md`** - Quality gate enforcement

### External Resources

- **Zod Documentation**: https://zod.dev - TypeScript schema validation
- **Conventional Commits**: https://www.conventionalcommits.org - Commit message format
- **OWASP Top 10**: https://owasp.org/Top10 - Security vulnerabilities to prevent

---

_This guide is part of the RPTC Workflow v2.0 documentation._
_For questions or contributions, see CONTRIBUTING.md in the plugin repository._

---
name: security-methodology
description: Security review methodology for the RPTC security agent. Covers finding categories, OWASP Top 10 reference, confidence scoring (>=80 threshold), issue tags, execution flow, common vulnerability patterns, and structured output format. Report-only mode.
---

# Security Methodology

Security review execution patterns for the RPTC security agent. **Report-only** — never edit files.

---

## Finding Categories

Report findings with confidence scores (>=80 only):

### Critical (Report First)
- Known CVE matches, proven exploits
- Authentication bypass patterns
- SQL/Command injection vulnerabilities
- Hardcoded secrets or exposed keys

### High Priority
- Authorization gaps, privilege escalation
- XSS vulnerabilities
- Insecure deserialization
- Cryptographic weaknesses

### Medium Priority
- Missing input validation
- CSRF vulnerabilities
- Insecure dependencies (non-critical CVEs)
- Missing security headers

### Context Needed (Flag for Review)
- Auth/authz logic concerns
- Security boundary questions
- Access control considerations

---

## Confidence Scoring

Score each finding 0-100:

| Score | Meaning | Report? |
|-------|---------|---------|
| 95-100 | Known CVE, proven exploit | Yes (Critical) |
| 80-94 | High confidence vulnerability | Yes |
| 60-79 | Possible issue, needs context | Skip |
| <60 | Uncertain, likely false positive | Skip |

**Only report issues >=80 confidence.**

---

## Issue Tags

Tag each finding:
- **INJECTION**: SQL, command, LDAP, XPath, template
- **AUTH**: Authentication bypass, weak credentials, session
- **AUTHZ**: Authorization gaps, privilege escalation, IDOR
- **CRYPTO**: Weak algorithms, key management, hashing
- **INPUT**: Missing validation, XSS, CSRF
- **SECRETS**: Hardcoded creds, exposed keys, API tokens
- **DEPS**: Vulnerable dependencies, outdated packages

---

## Scope

Only analyze:
- Code modified in current feature
- Files directly touched
- NOT entire codebase

---

## Execution Flow

### Phase 1: Read Files
1. Read all files provided for review
2. Note: file count, framework in use

### Phase 2: Scan
1. Pattern detection for common vulnerabilities
2. Check for hardcoded secrets
3. Dependency audit (if lockfile in scope)
4. Framework-specific checks

### Phase 3: Analyze
For each potential issue:
- Calculate confidence (0-100)
- Categorize (INJECTION/AUTH/AUTHZ/CRYPTO/INPUT/SECRETS/DEPS)
- Note priority (critical/high/medium/context-needed)

### Phase 4: Report
Output findings in consolidated format (see Output Format below).

---

## Common Vulnerability Patterns

### Injection (A03)
```
BAD:  query = `SELECT * FROM users WHERE id = ${id}`
GOOD: query = "SELECT * FROM users WHERE id = ?", [id]
```

### XSS (A03)
```
BAD:  <div innerHTML={userInput} />
GOOD: <div>{userInput}</div>  // React auto-escapes
GOOD: <div innerHTML={DOMPurify.sanitize(userInput)} />
```

### Broken Auth (A07)
```
BAD:  jwt.sign(payload, "weak-secret")
GOOD: jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '15m' })
```

### Hardcoded Secrets (A02)
```
BAD:  const API_KEY = "sk-1234567890"
GOOD: const API_KEY = process.env.API_KEY
```

---

## Quality Gates

**Critical/High issues:**
- Must be reported and addressed by main context
- Cannot proceed with unaddressed Critical findings

---

## Output Format

Return structured findings:

```json
{
  "findings": [
    {
      "confidence": 95,
      "category": "AUTH",
      "priority": "critical",
      "description": "Missing authentication on /api/admin",
      "location": "src/routes/admin.ts:15",
      "suggestion": "Add auth middleware"
    }
  ],
  "summary": {
    "filesReviewed": 5,
    "critical": 1,
    "highPriority": 2,
    "mediumPriority": 1
  }
}
```

---

## OWASP Top 10 Quick Reference

| ID | Category | Check For |
|----|----------|-----------|
| A01 | Broken Access Control | Missing authz, IDOR, path traversal |
| A02 | Cryptographic Failures | Weak hashing, hardcoded secrets |
| A03 | Injection | SQL, XSS, command, template |
| A04 | Insecure Design | Missing rate limits, weak patterns |
| A05 | Security Misconfiguration | Default creds, verbose errors |
| A06 | Vulnerable Components | CVEs in dependencies |
| A07 | Auth Failures | Weak sessions, credential stuffing |
| A08 | Integrity Failures | Insecure deserialization |
| A09 | Logging Failures | Missing audit logs, PII in logs |
| A10 | SSRF | URL injection, internal access |

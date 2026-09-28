---
name: security-methodology
description: Review changed security properties at trust boundaries, including authorization, untrusted input, secret handling, dependencies, sensitive data, and failure behavior. Use for security-sensitive diffs and RPTC verification.
---

# Security Methodology

## Scope

Start from the exact change. Identify security properties that changed or could
be affected:

- authentication and authorization;
- user or tenant isolation;
- untrusted input and output encoding;
- command, query, template, and path construction;
- secret and credential handling;
- cryptography and key lifecycle;
- sensitive data storage, transport, and logging;
- dependency or supply-chain assumptions;
- rate, resource, and failure behavior;
- server-side requests and external integrations.

Do not perform a generic checklist dump when none of these properties changed.

## Analysis

Each confirmed finding states:

- the trust boundary;
- the attacker-controlled or sensitive data path;
- the missing or broken property;
- the exploit or failure path;
- the exact location;
- impact and preconditions;
- the smallest correction;
- the strongest practical verification.

Use project security guidance and applicable standards as authority. A scanner
or model warning is a lead, not proof.

## Output

Separate:

- confirmed findings;
- context needed;
- checks performed;
- security properties unchanged or verified.

Report every evidence-backed finding with its severity: blocking (breaks the
request, correctness, or security), should-fix (violates a documented rule or
leaves a real risk), or optional (improvement). An axis with none reports
`No findings`. The parent decides what to act on.

Do not use arbitrary numerical confidence as a reporting gate.

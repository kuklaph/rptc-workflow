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

For each candidate issue:

1. name the trust boundary;
2. trace attacker-controlled or sensitive data;
3. identify the missing or broken property;
4. show the exploit or failure path;
5. cite the exact location;
6. state impact and preconditions;
7. propose the smallest correction;
8. name the strongest practical verification.

Use project security guidance and applicable standards as authority. A scanner
or model warning is a lead, not proof.

## Output

Separate:

- confirmed findings;
- context needed;
- checks performed;
- security properties unchanged or verified.

Do not use arbitrary numerical confidence as a reporting gate.

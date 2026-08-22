# Security and performance

Use this SOP when a change affects trust boundaries, sensitive data, external
input, authorization, cryptography, dependencies, resource use, latency, or
operational reliability.

Project-specific security and performance policy overrides this file.

## Security review starts from changed properties

Do not run a generic checklist and call the change secure. Identify what
security property changed:

- who may perform an action;
- what input crosses a trust boundary;
- what data is stored, exposed, logged, or transmitted;
- what secret or credential is used;
- what external service or dependency is trusted;
- what failure must remain safe.

State the property as a predicate and name the strongest feasible evidence.

## Boundaries

Validate untrusted data once where it enters the system:

- HTTP and RPC requests;
- CLI arguments and environment variables;
- files and configuration;
- database results from weakly typed boundaries;
- external API responses;
- messages, events, and webhooks.

Parse raw input into a named internal type. Inside the validated boundary, rely
on the type and avoid scattered duplicate checks.

Reject unexpected fields or values when permissive parsing creates ambiguity or
security risk.

## Authorization

Authentication identifies an actor. Authorization decides whether that actor
may perform this action on this resource.

Verify authorization at the operation boundary, not only in the UI.

For every changed protected action, test:

- the intended actor succeeds;
- an unauthenticated actor fails;
- an authenticated but unauthorized actor fails;
- ownership and tenant boundaries are enforced;
- failure does not disclose protected data.

Prefer default deny and explicit permission grants.

## Injection and interpreters

Treat user-controlled data as data, not executable syntax.

- Use parameterized database queries.
- Pass process arguments as an argument vector rather than a constructed shell
  command.
- Use structured APIs for HTML, templates, paths, URLs, and queries.
- Avoid evaluating generated code or configuration.
- Normalize and constrain paths before filesystem access.

When an interpreter cannot be avoided, document the accepted grammar and test
malicious boundary cases.

## Secrets and sensitive data

- Keep credentials out of source, logs, prompts, examples, and generated
  artifacts.
- Use the project's existing secret store or environment mechanism.
- Minimize the lifetime and scope of credentials.
- Redact tokens, session identifiers, personal data, and private keys from
  error reports.
- Do not invent custom encryption or password hashing.

A secret scan is evidence only when the repository actually configures and runs
one. Do not claim a scan occurred because a generic command was suggested.

## Cryptography

Use maintained platform or library primitives. Preserve algorithm, key,
rotation, nonce, and compatibility requirements already defined by the project.

Do not redesign cryptography as part of an unrelated change.

For password storage, use the project's approved password-hashing library and
parameters. Encryption and hashing solve different problems.

## Dependencies and supply chain

Before adding or materially changing a dependency:

1. establish why existing code or platform APIs are insufficient;
2. inspect ownership, maintenance, release history, license, and transitive
   impact;
3. pin or constrain versions according to project policy;
4. run the repository's configured dependency or lockfile checks;
5. document new runtime, build, or network trust.

Do not run package-manager audit commands blindly when the repository does not
use them or when their result cannot be interpreted in context.

## Errors and logging

Errors must preserve enough context to diagnose the failure without exposing
secrets or protected data.

- Return stable public errors at external boundaries.
- Keep detailed internal diagnostics in the configured logging system.
- Do not log credentials, authorization headers, session cookies, personal
  data, or full untrusted payloads by default.
- Preserve causes when wrapping errors.
- Fail closed when an authorization or validation decision cannot be made.

## Security verification

Choose evidence that matches the changed property:

- focused unit or integration tests;
- an API request as authorized and unauthorized actors;
- a browser or CLI drive through the real path;
- a static rule already configured by the project;
- a dependency scan already used by CI;
- a review of the exact diff and affected callers.

Report each material security claim as `VERIFIED`, `NOT VERIFIED`, or
`INCONCLUSIVE`. A typecheck or passing happy-path test is not proof of
authorization, input safety, or secret handling.

## Performance starts with measurement

Do not optimize from source inspection alone.

1. Define the user-visible or operational metric.
2. Capture a representative baseline.
3. Identify the dominant cost from a trace, profile, query plan, benchmark, or
   repeatable timing harness.
4. Change one supported mechanism.
5. Measure with the same harness.
6. Keep the change only when the improvement exceeds noise and correctness
   checks remain green.

Useful metrics include latency distributions, throughput, memory growth, CPU
time, query count, payload size, startup time, and resource saturation.

## Performance design

Prefer removing work before making work faster:

- avoid unused computation and unnecessary I/O;
- reduce repeated parsing, queries, renders, and network calls;
- batch fixed-overhead operations when semantics allow it;
- cache only with an explicit invalidation rule;
- move non-critical work off an interactive path;
- use data structures and indexes that match access patterns;
- bound queues, retries, concurrency, and memory.

Every optimization should state its trade-off, such as memory, staleness,
complexity, load, or tail behavior.

## Completion

For security- or performance-sensitive work, report:

- the property or metric;
- baseline or failing evidence;
- the change;
- passing or post-change evidence;
- regressions checked;
- remaining uncertainty.

Do not claim compliance with a standard unless the required scope was actually
assessed.

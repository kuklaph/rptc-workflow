# Flexible Testing Guide

**Purpose**: Guidance for testing AI-generated code and non-deterministic systems using flexible assertions

**Version**: 2.0.0 (Phase 5 Enhancement - Flexible Assertions)
**Created**: 2025-01-25
**Status**: ✅ COMPLETE - Ready for Production Use

**Applies To**: `/rptc:tdd`, `/rptc:plan`, Master Feature Planner Agent, AI code review workflows

**Dependencies**:
- `testing-guide.md` (foundational TDD principles)
- `architecture-patterns.md` (code quality standards)

**Completion Status**:
- [x] Section 1: Core Problem Statement (Step 6a)
- [x] Section 2: When to Use Flexible vs Exact Assertions (Step 6a)
- [x] Section 3: Flexible Assertion Patterns (Steps 6b-6c)
- [x] Section 4: Language-Specific Examples (Step 6c)
- [x] Section 5: Integration with RPTC TDD Workflow (Step 6d)
- [x] Section 6: Safety Mechanisms & Anti-Patterns (Step 6a)
- [x] Section 7: Practical Decision Trees (Step 6d)

---

## Table of Contents

1. [Core Problem Statement](#1-core-problem-statement)
2. [When to Use Flexible vs Exact Assertions](#2-when-to-use-flexible-vs-exact-assertions)
3. [Flexible Assertion Patterns](#3-flexible-assertion-patterns)
4. [Language-Specific Examples](#4-language-specific-examples)
5. [Integration with RPTC TDD Workflow](#5-integration-with-rptc-tdd-workflow)
6. [Safety Mechanisms & Anti-Patterns](#6-safety-mechanisms--anti-patterns)
7. [Practical Decision Trees](#7-practical-decision-trees)

---

## 1. Core Problem Statement

### The Challenge: AI Non-Determinism in Code Generation

Traditional Test-Driven Development (TDD) operates under a fundamental assumption:

**TDD Assumption**: `same_input → same_output` (deterministic behavior)

This assumption breaks when testing AI-generated code or AI agents:

**AI Reality**: `same_input → {output_1, output_2, ..., output_n}` (non-deterministic set of valid outputs)

### Why Traditional Assertions Fail

AI systems produce variation due to:
- **Temperature settings**: Controlled randomness in token selection
- **Model updates**: Backend model versioning changes behavior
- **Sampling strategies**: Top-p, top-k, nucleus sampling introduce variation
- **Context windows**: Different context lengths affect outputs
- **Timing dependencies**: Async operations, parallel processing order

**Even at temperature=0**, AI outputs vary due to floating-point precision, model updates, and infrastructure changes.

### Concrete Example: The Failing Test

```python
# Test written with AI-generated output (Run 1)
def test_generate_user_summary():
    summary = generate_summary(user_data)
    assert summary == "AI testing requires flexibility. Traditional assertions fail for valid variations."

# Same test, different execution (Run 2)
# Actual output: "Testing AI code demands flexible assertions. Exact matches reject valid alternative phrasings."
# Result: TEST FAILS ❌

# Both summaries are semantically correct.
# Exact string matching rejects valid variation.
# Developer wastes time investigating a "false positive" failure.
```

### The Tension: Rigor vs. Brittleness

**Need for Rigor**: Tests must catch regressions, bugs, and quality degradation. Permissive tests provide false confidence.

**Need for Flexibility**: Tests must accept valid variations in non-deterministic outputs. Brittle tests waste developer time on false failures.

**This guide resolves the tension** by providing:
1. **Four flexible assertion patterns** for common AI variation types
2. **Clear decision criteria** for when to use flexibility vs. exactness
3. **Safety mechanisms** preventing abuse and quality erosion

### When This Guide Applies

**Use flexible assertions for**:
- AI-generated text (summaries, comments, documentation)
- Code variations (variable names, formatting, equivalent implementations)
- Non-deterministic outputs (ML predictions, probabilistic algorithms)
- User-facing content where exact wording isn't contractual

**DO NOT use flexible assertions for**:
- Security-critical validations (authentication, authorization, input sanitization)
- API contracts and file formats (external integrations depend on exactness)
- Performance benchmarks (SLAs, timing requirements)
- Regulatory compliance outputs (financial calculations, medical data)
- Cryptographic operations (hashing, encryption, signing)

**Principle**: Flexible assertions are a precision tool for handling inherent non-determinism, **not** a quality compromise or excuse for sloppy testing.

---

## 2. When to Use Flexible vs Exact Assertions

### Decision Framework

Use this decision tree to determine the appropriate assertion strategy:

```
START: Is the output deterministic?
  │
  ├─ YES → Use exact assertions (traditional TDD)
  │         ✅ Examples: Database IDs, mathematical calculations, fixed-format outputs
  │         ✅ Reason: Predictable outputs should have predictable tests
  │
  └─ NO → Is variation acceptable?
      │
      ├─ NO → Can variation be eliminated?
      │   │
      │   ├─ YES → Redesign for determinism BEFORE testing
      │   │         ✅ Strategies:
      │   │            - Use fixed random seeds
      │   │            - Constrain prompts with few-shot examples
      │   │            - Remove unnecessary randomness
      │   │            - Use mocking for external API calls
      │   │
      │   └─ NO → Use exact assertions with ranges/thresholds
      │             ✅ Examples:
      │                - Performance: `assert execution_time < 1.0`
      │                - Approximations: `assert abs(result - expected) < 0.01`
      │             ⚠️  WARNING: Define thresholds based on requirements, not convenience
      │
      └─ YES → What type of variation exists?
          │
          ├─ Semantic (wording, formatting, synonyms)
          │   → Pattern 1: Semantic Similarity Evaluation
          │     📖 Use cases: AI-generated comments, error messages, documentation
          │     🎯 Threshold: Cosine similarity >0.85 (adjust based on criticality)
          │     ⚙️  Tools: sentence-transformers, OpenAI embeddings, spaCy
          │
          ├─ Behavioral (implementation details vary, outcome identical)
          │   → Pattern 2: Behavioral Correctness Assessment
          │     📖 Use cases: Variable naming, algorithm choice, code structure
          │     🎯 Approach: Black-box testing (input → output)
          │     ⚙️  Focus: Test behavior, ignore internal implementation
          │
          ├─ Reasoning (explanation quality, not exact wording)
          │   → Pattern 3: Quality of Reasoning Verification
          │     📖 Use cases: AI explanations, justifications, code comments
          │     🎯 Criteria: Key concepts present, no contradictions, logical coherence
          │     ⚙️  Method: Checklist-based validation
          │
          └─ Multiple Valid Paths (several correct solutions exist)
              → Pattern 4: Multiple Valid Solution Path Support
                📖 Use cases: Unordered collections, algorithm alternatives, API supersets
                🎯 Approach: Test membership in valid solution set
                ⚙️  Strategy: Enumerate acceptable solutions, pass if any match

CRITICAL SAFETY CHECK:
If ANY of these conditions apply, STOP and use exact assertions:
  ⛔ Security-critical operations (auth, validation, sanitization)
  ⛔ External contracts (APIs, file formats, protocols)
  ⛔ Performance SLAs (response times, throughput)
  ⛔ Regulatory compliance (finance, healthcare, legal)
  ⛔ Cryptographic operations (hashing, encryption)
```

### Decision Examples

#### Example 1: AI-Generated Code Comment

**Scenario**: Testing AI-generated function documentation

**Question**: Is output deterministic?
- **Answer**: NO - AI produces comment wording variations

**Question**: Is variation acceptable?
- **Answer**: YES - Semantic meaning matters, not exact wording

**Question**: What type of variation?
- **Answer**: Semantic (synonyms, phrasing)

**Decision**: ✅ Use **Pattern 1: Semantic Similarity Evaluation**

**Implementation**:
```python
def test_function_documentation():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI generates valid comment variations
    - Pattern: Semantic Similarity (Pattern 1)
    - Threshold: >0.85 cosine similarity
    - Failure Action: If flaky, constrain prompt with examples
    """
    doc = generate_function_doc(function_code)
    expected = "Calculates user discount based on loyalty tier and purchase history"
    assert semantic_similarity(doc, expected) > 0.85
```

---

#### Example 2: User Authentication Logic

**Scenario**: Testing login authentication

**Question**: Is output deterministic?
- **Answer**: YES - Authentication should be deterministic

**Question**: Is this security-critical?
- **Answer**: YES

**Decision**: ⛔ Use **EXACT assertions** - No flexibility allowed

**Implementation**:
```python
def test_login_authentication():
    """
    EXACT ASSERTION REQUIRED:
    Security-critical. Authentication must be deterministic.
    Any variation indicates a bug.
    """
    result = authenticate_user("user@example.com", "correct_password")
    assert result.authenticated is True
    assert result.user_id == 123
    assert "admin" in result.roles  # Exact role check
```

---

#### Example 3: Performance Benchmark

**Scenario**: Testing API response time

**Question**: Is output deterministic?
- **Answer**: NO - Response times vary based on load, network, etc.

**Question**: Is variation acceptable?
- **Answer**: NO - Performance requirements are contractual

**Question**: Can variation be eliminated?
- **Answer**: NO - Inherent in distributed systems

**Decision**: ✅ Use **exact assertions with thresholds**

**Implementation**:
```python
def test_api_response_time():
    """
    THRESHOLD-BASED EXACT ASSERTION:
    Performance SLA: <500ms p95 response time
    Threshold based on contract, not convenience.
    """
    response_times = [call_api() for _ in range(100)]
    p95 = percentile(response_times, 95)
    assert p95 < 0.5  # 500ms SLA - EXACT threshold
```

---

#### Example 4: AI-Generated Test Cases

**Scenario**: Testing AI's ability to generate comprehensive test cases

**Question**: Is output deterministic?
- **Answer**: NO - AI produces different valid test case sets

**Question**: Is variation acceptable?
- **Answer**: YES - Multiple valid test case approaches exist

**Question**: What type of variation?
- **Answer**: Multiple Valid Paths - Different test strategies are equally valid

**Decision**: ✅ Use **Pattern 4: Multiple Valid Solution Path Support**

**Implementation**:
```python
def test_ai_generated_test_coverage():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Multiple valid test case strategies exist
    - Pattern: Multiple Valid Paths (Pattern 4)
    - Criteria: Must cover all edge cases (enumerated)
    - Failure Action: Check if new edge case discovered
    """
    test_cases = ai_generate_test_cases(function_spec)
    required_edge_cases = {
        "null_input", "empty_string", "negative_number",
        "max_boundary", "min_boundary", "invalid_type"
    }
    covered_cases = {tc.edge_case_type for tc in test_cases}
    assert required_edge_cases.issubset(covered_cases)
```

---

### Key Principles for Decision-Making

1. **Default to Exact**: When in doubt, use exact assertions. Add flexibility only when non-determinism is proven.

2. **Document Rationale**: Every flexible assertion MUST explain why flexibility is needed.

3. **Security First**: Security, compliance, and contracts ALWAYS require exact assertions.

4. **Fail Fast on Patterns**: If flexible tests become flaky, it indicates prompt quality issues. Fix the root cause, don't loosen thresholds.

5. **Baseline Exact Tests**: Critical paths should have at least one exact test, even if flexible tests also exist.

---

## 3. Flexible Assertion Patterns

**Status**: 🚧 Implementation in progress (Steps 6b-6c)

This section will document four patterns for flexible assertions, each addressing a specific type of variation in AI-generated outputs.

### 3.1 Semantic Similarity Evaluation

**Status**: ✅ Implemented in Step 6b

#### What is This Pattern?

Semantic Similarity Evaluation validates that AI-generated text outputs convey the same **meaning and information** as expected, even when exact wording, phrasing, or formatting differs. Instead of character-by-character string matching, this pattern uses vector embeddings to compare the semantic content of text.

**Core Principle**: Information equivalence matters more than stylistic choices.

**Key Distinction**: This pattern tests "do both texts mean the same thing?" rather than "are both texts identical?"

#### When to Use This Pattern

Use Semantic Similarity Evaluation when:
- **AI-generated text**: Comments, documentation, explanations, summaries
- **Natural language outputs**: User-facing messages, email templates, report narratives
- **Error message wording**: When error type and severity are correct, but wording varies
- **Markdown formatting variations**: Headers (`#` vs `##`), bullets (`-` vs `*`), emphasis (`_italic_` vs `*italic*`)
- **Translation or paraphrasing tasks**: Multiple valid phrasings exist
- **Documentation generation**: AI produces valid docs with different phrasing

**Real-World Scenarios**:
- Testing AI-generated code comments: `// Calculate total` vs `// Compute sum`
- Validating chatbot responses: "I cannot process that request" vs "I'm unable to handle that request"
- Checking generated documentation: Active voice vs passive voice variations
- Verifying markdown output: Different but equivalent formatting choices

#### When NOT to Use This Pattern

**DO NOT use for**:
- **Factual data**: Numbers, dates, names, IDs, counts (use exact assertions)
- **Structured data**: JSON, XML, CSV (use format validators)
- **API responses**: Schema-defined outputs (use exact field validation)
- **Security-critical strings**: Error codes, authentication tokens, validation messages
- **Version strings or identifiers**: Semantic version numbers, UUIDs, SKUs
- **Legal or compliance text**: Terms of service, privacy policies, regulatory disclosures
- **Code identifiers**: Variable names, function signatures, class names (use behavioral testing instead)

**Critical Safety Rule**: If the text contains facts (numbers, dates, proper nouns), extract and validate facts separately with exact assertions. Only apply semantic similarity to stylistic elements.

#### How It Works (Conceptually)

**Step-by-Step Process**:

1. **Text Preprocessing**:
   - Normalize whitespace (optional: lowercase, remove punctuation)
   - Tokenize text into words/subwords
   - Handle special cases (URLs, code blocks, markdown syntax)

2. **Embedding Generation**:
   - Convert both expected and actual text to dense vector representations
   - Vectors capture semantic meaning in high-dimensional space (typically 384-1536 dimensions)
   - Similar meanings → similar vector positions (geometric proximity)

3. **Similarity Calculation**:
   - Compute cosine similarity between vectors: `similarity = (A · B) / (||A|| × ||B||)`
   - Result ranges from -1 (opposite) to 1 (identical), typically 0 to 1 for natural text
   - Higher values = more similar meaning

4. **Threshold Comparison**:
   - Assert: `similarity > threshold` (typically 0.85 for high confidence)
   - Threshold defines acceptable semantic distance

**Mathematical Foundation**:
```
Cosine Similarity = cos(θ) where θ is angle between vectors
- 1.0: Perfect alignment (identical meaning)
- 0.9-0.99: Very high similarity (paraphrases, synonyms)
- 0.85-0.89: High similarity (acceptable variations)
- 0.70-0.84: Moderate similarity (related but different)
- <0.70: Low similarity (likely different meanings)
```

#### Decision Criteria

**Use Semantic Similarity when**:
- Multiple valid phrasings express the same information
- Human reviewers would accept the variation without concern
- Content and meaning matter more than exact form
- Style guide permits variation (active/passive voice, synonym choices)
- Output is user-facing natural language

**Use Exact Assertions when**:
- Exact format is required by specification
- Text contains factual data (numbers, dates, names)
- External systems depend on specific wording
- Legal, regulatory, or contractual requirements mandate exact text
- Security depends on precise string matching

**Decision Questions**:
1. "Would a human accept both versions as equivalent?" → YES = use semantic similarity
2. "Does this text contain facts that must be exact?" → YES = extract facts, use exact assertions on facts
3. "Is this text part of an API contract or legal document?" → YES = use exact assertions
4. "Would changing synonyms break functionality?" → YES = use exact assertions

#### Comparison to Exact Assertions

| Aspect | Exact Assertions | Semantic Similarity |
|--------|------------------|---------------------|
| **Validation Type** | Character-by-character match | Meaning equivalence |
| **Accepts Synonyms** | ❌ No ("calculate" ≠ "compute") | ✅ Yes (semantically equivalent) |
| **Accepts Rephrasing** | ❌ No (different word order fails) | ✅ Yes (same meaning passes) |
| **Factual Accuracy** | ✅ Perfect (exact values enforced) | ⚠️ Must validate separately |
| **Security Critical** | ✅ Safe (no ambiguity) | ❌ Unsafe (approximation risk) |
| **Performance** | ✅ Fast (string comparison) | ⚠️ Slower (embedding generation) |
| **Deterministic** | ✅ Yes (always same result) | ⚠️ Depends on embedding model |
| **Use Case** | Structured data, facts, contracts | Natural language, style variations |

**Key Insight**: Exact assertions are a subset of semantic similarity (exact matches always have 1.0 similarity). Use semantic similarity to **expand** acceptable outputs, not replace rigor.

#### Implementation Guidance

##### Threshold Selection

**Recommended Thresholds** (based on NLP research):

- **>0.90**: Very high confidence - paraphrases, minor synonym changes
  - Use for: Critical user-facing messages where meaning must be precise
  - Example: "Payment successful" vs "Payment completed successfully"

- **>0.85**: High confidence - acceptable variations, standard threshold
  - Use for: General AI-generated text, code comments, documentation
  - Example: "Calculate discount based on tier" vs "Compute discount using loyalty level"

- **>0.75**: Moderate confidence - related content, broader variations
  - Use for: Exploratory testing, validating topic consistency
  - Example: "User authentication failed" vs "Login credentials were incorrect"

- **<0.75**: Low confidence - likely different meanings
  - Avoid using as acceptance threshold (too permissive)

**Data-Driven Threshold Tuning**:
1. Generate 50-100 outputs with your AI system
2. Manually classify: "acceptable variation" vs "unacceptable deviation"
3. Calculate similarity scores for both groups
4. Set threshold at minimum similarity of acceptable variations
5. Validate: No unacceptable deviations exceed threshold

##### Tooling Recommendations

**Python** (pytest):

```python
# Option 1: sentence-transformers (local, fast, no API costs)
from sentence_transformers import SentenceTransformer, util

model = SentenceTransformer('all-MiniLM-L6-v2')  # 384-dim embeddings

def semantic_similarity(text1: str, text2: str) -> float:
    """Calculate cosine similarity between two texts."""
    embeddings = model.encode([text1, text2])
    similarity = util.cos_sim(embeddings[0], embeddings[1])
    return float(similarity[0][0])

# Usage in test
def test_ai_generated_comment():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI generates valid comment variations
    - Pattern: Semantic Similarity (Pattern 1)
    - Threshold: >0.85 (based on pilot testing with 100 comments)
    - Failure Action: If flaky, review prompt stability
    """
    comment = generate_code_comment(function_ast)
    expected = "Calculate user discount based on loyalty tier"

    similarity = semantic_similarity(comment, expected)
    assert similarity > 0.85, f"Similarity {similarity:.3f} below threshold 0.85"
```

**Installation**: `pip install sentence-transformers`

**Pros**: Local execution, no API costs, fast inference, good accuracy
**Cons**: Requires 200MB+ model download, slightly lower accuracy than GPT embeddings

---

**Python** (OpenAI Embeddings API):

```python
# Option 2: OpenAI embeddings (highest accuracy, API cost)
import openai
import numpy as np

def get_embedding(text: str, model="text-embedding-3-small") -> list[float]:
    """Get embedding vector from OpenAI API."""
    response = openai.embeddings.create(input=[text], model=model)
    return response.data[0].embedding

def cosine_similarity(vec1: list[float], vec2: list[float]) -> float:
    """Calculate cosine similarity between two vectors."""
    vec1_np = np.array(vec1)
    vec2_np = np.array(vec2)
    return np.dot(vec1_np, vec2_np) / (np.linalg.norm(vec1_np) * np.linalg.norm(vec2_np))

# Usage in test
def test_ai_documentation_generation():
    """Uses OpenAI embeddings for highest accuracy."""
    doc = generate_function_docs(function_code)
    expected = "Authenticates user credentials and returns session token"

    emb1 = get_embedding(doc)
    emb2 = get_embedding(expected)
    similarity = cosine_similarity(emb1, emb2)

    assert similarity > 0.88, f"Doc similarity {similarity:.3f} too low"
```

**Pros**: Highest accuracy, 1536-dim embeddings, handles complex semantics
**Cons**: API costs (~$0.0001 per 1K tokens), network latency, requires API key

---

**JavaScript/TypeScript** (Jest):

```typescript
// Option 1: TensorFlow.js + Universal Sentence Encoder
import * as use from '@tensorflow-models/universal-sentence-encoder';
import * as tf from '@tensorflow/tfjs';

let model: use.UniversalSentenceEncoder;

beforeAll(async () => {
  model = await use.load();
});

async function semanticSimilarity(text1: string, text2: string): Promise<number> {
  const embeddings = await model.embed([text1, text2]);
  const embedArray = await embeddings.array();

  // Cosine similarity
  const dotProduct = embedArray[0].reduce((sum, val, i) => sum + val * embedArray[1][i], 0);
  const mag1 = Math.sqrt(embedArray[0].reduce((sum, val) => sum + val * val, 0));
  const mag2 = Math.sqrt(embedArray[1].reduce((sum, val) => sum + val * val, 0));

  return dotProduct / (mag1 * mag2);
}

// Usage in test
describe('AI Code Generation', () => {
  it('generates semantically correct documentation', async () => {
    /**
     * FLEXIBLE ASSERTION RATIONALE:
     * - Why: AI doc generator produces valid variations
     * - Pattern: Semantic Similarity (Pattern 1)
     * - Threshold: >0.85
     * - Failure Action: Check for prompt drift
     */
    const doc = await generateDocumentation(functionCode);
    const expected = "Validates email format and returns boolean result";

    const similarity = await semanticSimilarity(doc, expected);
    expect(similarity).toBeGreaterThan(0.85);
  });
});
```

**Installation**: `npm install @tensorflow-models/universal-sentence-encoder @tensorflow/tfjs`

**Pros**: Works in browser and Node.js, no API dependencies
**Cons**: Large model size (50MB+), slower initial load

---

**Option 2: OpenAI API (Node.js)**:

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function semanticSimilarity(text1: string, text2: string): Promise<number> {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: [text1, text2]
  });

  const emb1 = response.data[0].embedding;
  const emb2 = response.data[1].embedding;

  // Cosine similarity
  const dotProduct = emb1.reduce((sum, val, i) => sum + val * emb2[i], 0);
  const mag1 = Math.sqrt(emb1.reduce((sum, val) => sum + val * val, 0));
  const mag2 = Math.sqrt(emb2.reduce((sum, val) => sum + val * val, 0));

  return dotProduct / (mag1 * mag2);
}

// Usage in test
test('AI summary generation has semantic fidelity', async () => {
  const summary = generateSummary(article);
  const expected = "AI testing requires flexibility to handle non-deterministic outputs";

  const similarity = await semanticSimilarity(summary, expected);
  expect(similarity).toBeGreaterThan(0.87);
});
```

#### Common Pitfalls and How to Avoid Them

**Pitfall 1: Using Similarity for Factual Data**

❌ **Wrong**:
```python
# Expected: "User has 5 active orders"
# Actual: "User has several active orders"
# Similarity: 0.92 → PASSES but "several" ≠ 5 (factual error)
assert semantic_similarity(summary, "User has 5 active orders") > 0.85
```

✅ **Correct**:
```python
# Extract facts separately
order_count = extract_number(summary, context="orders")
assert order_count == 5  # Exact fact validation

# Validate style separately
assert "order" in summary.lower()
assert "active" in summary.lower()
```

---

**Pitfall 2: Overly Permissive Thresholds**

❌ **Wrong**:
```python
# Threshold too low - accepts unrelated content
assert semantic_similarity(output, expected) > 0.60  # Too permissive
```

✅ **Correct**:
```python
# Data-driven threshold based on pilot testing
assert semantic_similarity(output, expected) > 0.85  # Validated threshold
```

**Guideline**: If you find yourself lowering thresholds to make tests pass, you have a prompt quality problem, not a threshold problem.

---

**Pitfall 3: No Baseline Exact Test**

❌ **Wrong**:
```python
# Only flexible test, no regression detection
def test_generate_summary():
    assert semantic_similarity(generate_summary(data), expected) > 0.80
```

✅ **Correct**:
```python
def test_summary_contains_key_facts_exact():
    """Baseline: Facts must be exact."""
    summary = generate_summary(data)
    assert "5 orders" in summary
    assert "Q4 2024" in summary

def test_summary_style_flexible():
    """Flexible: Style can vary."""
    summary = generate_summary(data)
    assert semantic_similarity(summary, expected_style) > 0.85
```

---

**Pitfall 4: Ignoring Embedding Model Limitations**

**Issue**: Embedding models may not capture domain-specific semantics (medical, legal, technical jargon).

**Solution**:
- Test with domain-specific text samples first
- Consider fine-tuned models for specialized domains
- Validate that model distinguishes critical domain differences
- Example: Ensure model differentiates "benign tumor" vs "malignant tumor" (medical)

---

**Pitfall 5: Comparing Long Texts Without Structure Validation**

❌ **Wrong**:
```python
# 500-word document comparison - structure lost
assert semantic_similarity(long_doc, expected_long_doc) > 0.85
```

✅ **Correct**:
```python
# Validate structure first, then compare sections
assert has_sections(long_doc, ["Introduction", "Methods", "Results"])

for section in ["Introduction", "Methods", "Results"]:
    actual_section = extract_section(long_doc, section)
    expected_section = extract_section(expected_long_doc, section)
    similarity = semantic_similarity(actual_section, expected_section)
    assert similarity > 0.85, f"{section} similarity too low: {similarity:.3f}"
```

#### Safety Considerations

1. **Always Separate Facts from Style**: Extract factual claims (numbers, dates, names) and validate with exact assertions. Apply semantic similarity only to stylistic elements.

2. **Document Threshold Justification**: Explain how threshold was chosen (pilot testing, research, domain requirements). Arbitrary thresholds indicate insufficient rigor.

3. **Monitor Threshold Drift**: If similarity scores trend downward over time, it indicates prompt quality degradation. Fix the prompt, don't lower the threshold.

4. **Validate Embedding Model Behavior**: Test that your chosen embedding model correctly distinguishes critical differences in your domain (e.g., "increase" vs "decrease", "allow" vs "deny").

5. **Baseline Exact Tests Are Mandatory**: Critical paths must have at least one exact test for regression detection, even if flexible tests also exist.

6. **Never Use for Security-Critical Text**: Authentication messages, authorization decisions, input validation errors must use exact assertions.

#### Integration with RPTC Workflow

When planning in `/rptc:plan`:
```markdown
## Test Strategy for AI Comment Generation

**Assertion Strategy**: Semantic Similarity (Pattern 1)
**Rationale**: AI generates valid comment variations; exact wording not specified
**Threshold**: >0.85 cosine similarity (sentence-transformers)
**Baseline**: Exact test validates function signature presence in comment
```

When implementing in `/rptc:tdd`:
```python
def test_ai_comment_exact_baseline():
    """Baseline: Comment must reference function name."""
    comment = generate_comment(function_ast)
    assert "calculate_discount" in comment.lower()

def test_ai_comment_semantic_quality():
    """Flexible: Comment meaning must match expected description."""
    comment = generate_comment(function_ast)
    expected = "Calculate user discount based on loyalty tier and purchase history"
    assert semantic_similarity(comment, expected) > 0.85
```

---

### 3.2 Behavioral Correctness Assessment

**Status**: ✅ Implemented in Step 6b

#### What is This Pattern?

Behavioral Correctness Assessment validates that code achieves its intended **objective and outcomes** regardless of how it's implemented internally. This pattern treats code as a black box, testing observable behavior (inputs → outputs, side effects) while ignoring implementation details (variable names, algorithm choice, code structure).

**Core Principle**: "What it does" matters more than "how it does it."

**Key Distinction**: This pattern tests "does the code produce correct results?" rather than "does the code use the expected implementation?"

#### When to Use This Pattern

Use Behavioral Correctness Assessment when:
- **Variable naming variations**: AI chooses semantically equivalent but different variable names
- **Algorithm alternatives**: Multiple valid approaches exist (iterative vs recursive, different sorting algorithms)
- **Code structure differences**: Same logic, different organization (single function vs helpers, different control flow)
- **Argument/property order**: Order doesn't affect semantics (JSON object properties, function kwargs)
- **Refactoring validation**: Ensuring refactored code maintains behavior
- **AI-generated code**: Testing code from AI assistants that may use different implementation patterns

**Real-World Scenarios**:
- Testing AI-generated sorting function: Accepts quicksort, mergesort, or any valid sorting algorithm
- Validating data transformation: `items` vs `order_items` variable names don't matter
- Checking API integration: Function signature varies but API calls are correct
- Verifying calculation logic: Different math expression forms produce same result

#### When NOT to Use This Pattern

**DO NOT use for**:
- **Performance-critical code**: Specific algorithm required (e.g., O(n log n) vs O(n²))
- **Security implementations**: Encryption/hashing algorithms must be exact (e.g., AES-256, bcrypt)
- **Required design patterns**: Architecture mandates specific implementation (e.g., Strategy pattern, Factory pattern)
- **Debugging/profiling hooks**: Internal variable names matter for tooling
- **Interface contracts**: Function signatures, parameter names part of public API
- **Legacy compatibility**: Specific implementation required for backward compatibility

**Critical Safety Rule**: Behavioral testing doesn't exempt you from testing error conditions. Error types, critical error messages, and exception handling must still be validated exactly.

#### How It Works (Conceptually)

**Black-Box Testing Methodology**:

1. **Define Expected Behavior**:
   - Input specifications (valid inputs, edge cases, invalid inputs)
   - Output specifications (expected results, error conditions)
   - Side effects (database writes, API calls, file operations, state changes)

2. **Test Public Interface**:
   - Call function/method with test inputs
   - Capture outputs and observable side effects
   - Ignore internal implementation details

3. **Verify Correctness**:
   - Assert output matches expected result
   - Verify side effects occurred as expected
   - Validate error conditions handled correctly

4. **Implementation-Agnostic Validation**:
   - Don't inspect variable names
   - Don't check algorithm choice (unless performance-critical)
   - Don't enforce code structure
   - Focus solely on observable behavior

**Testing Hierarchy**:
```
Public Interface (TEST THIS)
  ↓
  Inputs → [Black Box] → Outputs
  ↓                      ↓
Side Effects         Results
  ↓                      ↓
✅ Verify            ✅ Verify

Internal Implementation (IGNORE THIS)
  ↓
  Variable names, algorithm choice, code structure
  ↓
  ❌ Don't test
```

#### Decision Criteria

**Use Behavioral Testing when**:
- Multiple implementation approaches are equally valid
- Testing what code accomplishes, not how it's written
- Validating refactoring (ensure behavior unchanged)
- AI-generated code with implementation variations
- Public API behavior more important than internals

**Use Implementation-Specific Testing when**:
- Performance characteristics matter (Big-O complexity)
- Security requires specific algorithm (encryption standards)
- Architecture mandates design pattern (framework requirements)
- Legacy compatibility depends on implementation details
- Compliance requires audit trail of specific algorithm

**Decision Questions**:
1. "Do multiple implementation approaches achieve the same result?" → YES = use behavioral testing
2. "Does the specification mandate a specific algorithm?" → YES = test implementation specifics
3. "Is this a public API where behavior is the contract?" → YES = use behavioral testing
4. "Does performance depend on the specific algorithm used?" → YES = test implementation specifics

#### Comparison to Implementation-Specific Testing

| Aspect | Behavioral Testing | Implementation Testing |
|--------|-------------------|------------------------|
| **Focus** | What code does | How code does it |
| **Accepts Variations** | ✅ Yes (algorithm, structure, names) | ❌ No (specific implementation required) |
| **Refactoring Safe** | ✅ Yes (tests still pass) | ❌ No (may break after refactor) |
| **Detects Bugs** | ✅ Output/behavior bugs | ✅ Implementation bugs |
| **Performance** | ⚠️ May miss inefficiency | ✅ Catches performance regressions |
| **Brittleness** | ✅ Resilient (fewer false failures) | ⚠️ Brittle (breaks on internal changes) |
| **Security** | ⚠️ May miss weak algorithms | ✅ Enforces secure implementations |
| **Use Case** | Public APIs, AI code, refactoring | Performance-critical, security, compliance |

**Key Insight**: Behavioral testing enables flexibility without sacrificing correctness. It's the default for most application code; use implementation testing only when algorithm/structure matters for security, performance, or compliance.

#### Implementation Guidance

##### Testing Strategy Patterns

**Pattern 1: Input-Output Validation**

Test function produces correct output for given input, regardless of internal logic.

```python
# AI generates either implementation - both valid

# Implementation A (iterative)
def calculate_sum(numbers):
    total = 0
    for num in numbers:
        total += num
    return total

# Implementation B (functional)
def calculate_sum(numbers):
    from functools import reduce
    return reduce(lambda acc, num: acc + num, numbers, 0)

# Behavioral test (works for both)
def test_calculate_sum_behavior():
    """Tests behavior, not implementation."""
    assert calculate_sum([1, 2, 3, 4]) == 10
    assert calculate_sum([]) == 0
    assert calculate_sum([-1, 1]) == 0
    assert calculate_sum([100]) == 100
```

---

**Pattern 2: Side Effect Verification**

Test observable side effects (database writes, API calls) without inspecting how they're produced.

```python
# AI generates different variable names, same behavior

# Implementation A
def create_user_account(email, password):
    user_id = generate_id()
    hashed_pwd = hash_password(password)
    db.insert('users', {'id': user_id, 'email': email, 'password': hashed_pwd})
    send_email(email, 'Welcome!')
    return user_id

# Implementation B
def create_user_account(email, password):
    account_id = generate_id()
    encrypted_password = hash_password(password)
    db.insert('users', {'id': account_id, 'email': email, 'password': encrypted_password})
    send_email(email, 'Welcome!')
    return account_id

# Behavioral test (works for both)
def test_create_user_account_behavior(db_mock, email_mock):
    """Tests side effects, not variable names."""
    user_id = create_user_account('test@example.com', 'secret123')

    # Verify database write (don't care about variable names)
    assert db_mock.insert.called_once()
    call_args = db_mock.insert.call_args
    assert call_args[0] == 'users'
    assert call_args[1]['email'] == 'test@example.com'
    assert len(call_args[1]['password']) > 20  # Hashed

    # Verify email sent
    assert email_mock.send.called_once_with('test@example.com', 'Welcome!')

    # Verify ID returned
    assert isinstance(user_id, str)
    assert len(user_id) > 0
```

---

**Pattern 3: State Transition Validation**

Test that code moves system from state A to state B, regardless of how.

```python
# AI generates different approaches to state management

# Implementation A (direct mutation)
class ShoppingCart:
    def __init__(self):
        self.items = []

    def add_item(self, product, quantity):
        self.items.append({'product': product, 'quantity': quantity})

# Implementation B (immutable updates)
class ShoppingCart:
    def __init__(self):
        self._items = []

    def add_item(self, product, quantity):
        new_item = {'product': product, 'qty': quantity}
        self._items = self._items + [new_item]

# Behavioral test (works for both)
def test_shopping_cart_add_item():
    """Tests state transitions, not implementation."""
    cart = ShoppingCart()

    # Initial state
    assert len(cart.items) == 0  # Or cart._items, depending on implementation

    # Action
    cart.add_item('Widget', 2)

    # Final state verification
    assert len(cart.items) == 1
    assert cart.items[0]['product'] == 'Widget'
    assert cart.items[0].get('quantity') == 2 or cart.items[0].get('qty') == 2
```

**Note**: For robust behavioral testing with property variations, use normalization functions or test behaviors at a higher abstraction level.

---

**Pattern 4: Error Condition Verification**

Test that errors are raised correctly, even if error message wording varies slightly.

```python
# AI generates different but valid error messages

# Implementation A
def withdraw(account, amount):
    if amount > account.balance:
        raise ValueError(f"Insufficient funds: requested {amount}, available {account.balance}")
    account.balance -= amount

# Implementation B
def withdraw(account, amount):
    if amount > account.balance:
        raise ValueError(f"Cannot withdraw {amount}: balance is {account.balance}")
    account.balance -= amount

# Behavioral test (works for both)
def test_withdraw_insufficient_funds():
    """Tests error behavior, accepts message variations."""
    account = Account(balance=100)

    with pytest.raises(ValueError) as exc_info:
        withdraw(account, 150)

    # Verify error type (exact)
    assert isinstance(exc_info.value, ValueError)

    # Verify error message contains key information (flexible)
    error_msg = str(exc_info.value).lower()
    assert 'insufficient' in error_msg or 'cannot' in error_msg
    assert '150' in error_msg  # Requested amount
    assert '100' in error_msg  # Available balance
```

##### Tooling Recommendations

**Python** (pytest with mocking):

```python
import pytest
from unittest.mock import Mock, patch, call

def test_data_pipeline_behavior():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI may structure pipeline differently (functions vs classes)
    - Pattern: Behavioral Correctness (Pattern 2)
    - Criteria: Input data correctly transformed to output
    - Failure Action: Check if transformation logic changed
    """
    # Setup
    input_data = [
        {'name': 'Alice', 'age': 30},
        {'name': 'Bob', 'age': 25}
    ]

    # Execute (don't care how it's implemented)
    result = transform_pipeline(input_data)

    # Verify behavior (output is correct)
    assert len(result) == 2
    assert all('name_upper' in item for item in result)
    assert result[0]['name_upper'] == 'ALICE'
    assert result[1]['name_upper'] == 'BOB'
    assert all('age' in item for item in result)

# Testing with side effects (using mocks)
@patch('api.external_service.call')
def test_integration_behavior(mock_api_call):
    """Tests that external API called correctly, not how."""
    mock_api_call.return_value = {'status': 'success', 'id': 123}

    result = process_order(order_data)

    # Verify API called with correct parameters
    mock_api_call.assert_called_once()
    call_args = mock_api_call.call_args[0][0]
    assert call_args['customer_id'] == 456
    assert call_args['items'] == order_data['items']

    # Verify result processed correctly
    assert result['external_id'] == 123
    assert result['status'] == 'confirmed'
```

**Installation**: pytest comes with unittest.mock (Python 3.3+)

---

**JavaScript/TypeScript** (Jest with mocking):

```typescript
import { jest } from '@jest/globals';

describe('Behavioral Correctness Tests', () => {
  it('processes payment regardless of implementation', async () => {
    /**
     * FLEXIBLE ASSERTION RATIONALE:
     * - Why: Payment processor may use different internal logic
     * - Pattern: Behavioral Correctness (Pattern 2)
     * - Criteria: Payment recorded and receipt generated
     * - Failure Action: Verify side effects still occur
     */
    const mockDb = {
      insert: jest.fn().mockResolvedValue({ id: 'txn_123' }),
    };

    const mockEmailer = {
      send: jest.fn().mockResolvedValue(true),
    };

    // Execute
    const result = await processPayment(
      { amount: 99.99, customer: 'cust_456' },
      mockDb,
      mockEmailer
    );

    // Verify database write
    expect(mockDb.insert).toHaveBeenCalledTimes(1);
    expect(mockDb.insert).toHaveBeenCalledWith(
      expect.objectContaining({
        amount: 99.99,
        customer: 'cust_456',
        status: 'completed',
      })
    );

    // Verify email sent
    expect(mockEmailer.send).toHaveBeenCalledTimes(1);
    expect(mockEmailer.send).toHaveBeenCalledWith(
      expect.objectContaining({
        to: expect.any(String),
        subject: expect.stringContaining('Payment Confirmation'),
      })
    );

    // Verify return value
    expect(result).toEqual(
      expect.objectContaining({
        transaction_id: expect.any(String),
        status: 'completed',
      })
    );
  });

  it('validates input transformation behavior', () => {
    // AI may implement with map, forEach, reduce, or for loop
    const input = [1, 2, 3, 4, 5];
    const result = doubleAndFilter(input);

    // Test behavior: doubles all numbers, filters >5
    expect(result).toEqual([6, 8, 10]);
    // Don't test implementation (map vs forEach vs reduce)
  });
});
```

**Key Jest Matchers for Behavioral Testing**:
- `expect.objectContaining({...})`: Partial object match (ignores extra properties)
- `expect.arrayContaining([...])`: Partial array match (ignores order if unordered)
- `expect.any(Type)`: Type check without exact value
- `expect.stringContaining(substring)`: Substring match for flexible text

---

**Property-Based Testing** (Hypothesis for Python):

```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers(), min_size=0, max_size=100))
def test_sort_behavior(numbers):
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Multiple valid sorting algorithms exist
    - Pattern: Behavioral Correctness (Pattern 2)
    - Criteria: Output is sorted, contains all inputs
    - Failure Action: Check if sorting logic broke
    """
    result = sort_function(numbers)

    # Behavioral properties (algorithm-agnostic)
    assert len(result) == len(numbers)  # No elements lost
    assert sorted(numbers) == result  # Correctly sorted
    assert set(result) == set(numbers)  # All unique values present

# Property: Idempotence
@given(st.lists(st.integers()))
def test_sort_idempotence(numbers):
    """Sorting twice yields same result as sorting once."""
    once = sort_function(numbers)
    twice = sort_function(once)
    assert once == twice
```

**Installation**: `pip install hypothesis`

**Benefit**: Property-based testing naturally focuses on behavior (properties that should hold) rather than implementation.

#### Common Pitfalls and How to Avoid Them

**Pitfall 1: Testing Internal Variable Names**

❌ **Wrong**:
```python
def test_calculate_discount_implementation():
    # Inspecting internal variable names
    import inspect
    source = inspect.getsource(calculate_discount)
    assert 'discount_rate' in source  # Breaks if renamed
    assert 'for' in source  # Breaks if using list comprehension
```

✅ **Correct**:
```python
def test_calculate_discount_behavior():
    """Tests behavior, not variable names."""
    assert calculate_discount(100, 0.2) == 80.0
    assert calculate_discount(50, 0.5) == 25.0
    assert calculate_discount(100, 0) == 100.0
```

---

**Pitfall 2: Over-Specifying Mock Call Arguments**

❌ **Wrong**:
```python
# Too specific - breaks if argument order changes
mock_api.call.assert_called_with('POST', '/users', {'name': 'Alice'}, timeout=30, headers={'Auth': 'token'})
```

✅ **Correct**:
```python
# Focus on critical arguments only
mock_api.call.assert_called_once()
args, kwargs = mock_api.call.call_args
assert args[0] == 'POST'  # Method
assert args[1] == '/users'  # Endpoint
assert 'name' in args[2] and args[2]['name'] == 'Alice'  # Payload
# Don't check timeout/headers unless critical
```

---

**Pitfall 3: Ignoring Performance When It Matters**

❌ **Wrong**:
```python
def test_search_behavior():
    """Accepts any search algorithm, even O(n²)."""
    result = search_function(large_dataset, target)
    assert result == expected
    # Problem: Doesn't catch if AI used linear search instead of binary search
```

✅ **Correct**:
```python
def test_search_behavior():
    """Tests behavior."""
    result = search_function(dataset, target)
    assert result == expected

def test_search_performance():
    """Separate test for performance requirements."""
    import time
    large_dataset = list(range(1_000_000))
    start = time.time()
    search_function(large_dataset, 999_999)
    elapsed = time.time() - start
    assert elapsed < 0.01  # Must complete in <10ms (implies O(log n))
```

**Guideline**: Behavioral testing for correctness, separate performance tests for efficiency.

---

**Pitfall 4: Not Testing Error Conditions Exactly**

❌ **Wrong**:
```python
def test_validation_error():
    """Too permissive on error handling."""
    try:
        process_data(invalid_input)
        assert False  # Should have raised
    except Exception:
        pass  # Any exception accepted
```

✅ **Correct**:
```python
def test_validation_error():
    """Error type must be exact, message can vary."""
    with pytest.raises(ValueError) as exc_info:
        process_data(invalid_input)

    # Exact error type
    assert type(exc_info.value) == ValueError

    # Flexible message (key information present)
    assert 'invalid' in str(exc_info.value).lower()
    assert 'input' in str(exc_info.value).lower()
```

---

**Pitfall 5: Relying on Behavioral Testing for Security Code**

❌ **Wrong**:
```python
def test_password_hashing_behavior():
    """Accepts any hashing algorithm."""
    hashed = hash_password('secret123')
    assert len(hashed) > 20  # Just checks length
    assert hashed != 'secret123'  # Just checks it's hashed
    # Problem: Doesn't verify secure algorithm used (bcrypt, Argon2)
```

✅ **Correct**:
```python
def test_password_hashing_algorithm():
    """Security code requires exact algorithm."""
    hashed = hash_password('secret123')

    # Verify bcrypt format (exact)
    assert hashed.startswith('$2b$') or hashed.startswith('$2a$')
    assert len(hashed) == 60  # bcrypt hash length

    # Verify cost factor (exact)
    cost = int(hashed.split('$')[2])
    assert cost >= 12  # Minimum secure cost
```

#### Safety Considerations

1. **Error Types Are Always Exact**: While error messages can vary, error types (ValueError, TypeError, AuthenticationError) must be exact. This ensures error handling code works correctly.

2. **Performance-Critical Paths Need Separate Tests**: Behavioral testing doesn't catch algorithmic complexity issues. Add explicit performance tests for SLA-critical code.

3. **Security Implementations Require Exact Algorithms**: Hashing, encryption, authentication must use specific algorithms. Don't use behavioral testing for security code.

4. **Public APIs May Require Exact Signatures**: If function signatures are part of a public API contract, test parameter names and order exactly (not behaviorally).

5. **Side Effects Must Be Comprehensive**: When testing side effects (DB writes, API calls), ensure all critical side effects are verified, not just outputs.

6. **Baseline Exact Tests for Critical Paths**: Even with behavioral testing, maintain at least one exact regression test for mission-critical functionality.

#### Integration with RPTC Workflow

When planning in `/rptc:plan`:
```markdown
## Test Strategy for AI-Generated Data Processor

**Assertion Strategy**: Behavioral Correctness (Pattern 2)
**Rationale**: Multiple valid implementation approaches; behavior is the contract
**Critical Behaviors**:
  - Input validation (exact error types)
  - Data transformation correctness (exact output)
  - Side effects (DB writes, API calls)
**Non-Critical**:
  - Variable naming
  - Algorithm choice (as long as O(n log n) or better)
  - Code structure
**Baseline**: Exact test for core transformation logic with known input/output
```

When implementing in `/rptc:tdd`:
```python
def test_data_processor_exact_baseline():
    """Baseline: Known input produces known output."""
    result = process_data({'id': 1, 'value': 100})
    assert result == {'id': 1, 'value': 100, 'processed': True, 'timestamp': ANY}

def test_data_processor_behavior():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI may structure processing differently
    - Pattern: Behavioral Correctness (Pattern 2)
    - Criteria: All required fields present, transformation correct
    - Failure Action: Check if transformation logic changed
    """
    result = process_data(test_input)

    # Verify required fields present (don't care about extras)
    assert 'id' in result
    assert 'value' in result
    assert 'processed' in result

    # Verify transformation correct
    assert result['processed'] is True
    assert result['value'] == test_input['value']

def test_data_processor_error_handling():
    """Error conditions remain exact."""
    with pytest.raises(ValueError, match="Invalid input: missing 'id'"):
        process_data({'value': 100})  # Missing id
```

---

### 3.3 Quality of Reasoning Verification

**Status**: ✅ Implemented in Step 6c

#### What is This Pattern?

Quality of Reasoning Verification validates that AI-generated **explanations, justifications, and reasoning processes** are logically sound, coherent, and complete, even when exact wording or step ordering varies. This pattern assesses whether an explanation contains the necessary logical components and avoids fallacies, rather than requiring identical phrasing.

**Core Principle**: Soundness of logic matters more than specific wording or step sequencing.

**Key Distinction**: This pattern tests "is the reasoning valid and complete?" rather than "does the reasoning match word-for-word?"

#### When to Use This Pattern

Use Quality of Reasoning Verification when:
- **AI-generated explanations**: Code comments explaining "why" decisions were made
- **Documentation**: Technical documentation with rationale sections
- **Reasoning traces**: Agent workflows showing decision-making process
- **Educational content**: Tutorials, guides, or learning materials
- **Code review comments**: AI-generated suggestions with justifications
- **Architectural decisions**: Design rationale documents
- **Troubleshooting guides**: Problem diagnosis explanations

**Real-World Scenarios**:
- Testing AI-generated refactoring justification: "Refactor for performance" vs "Optimize to reduce complexity"
- Validating architectural decision records: Different phrasing, same technical rationale
- Checking code comment quality: Various ways to explain same algorithm choice
- Verifying error message explanations: Multiple valid ways to describe the problem

#### When NOT to Use This Pattern

**DO NOT use for**:
- **Factual data**: Specific numbers, dates, names, measurements (use exact assertions)
- **API documentation**: Exact parameter descriptions required for integration
- **Legal disclaimers**: Precise wording legally required
- **Error codes**: Specific codes must match documentation exactly
- **Security warnings**: Critical security information requires exact messaging
- **Compliance documentation**: Regulatory language must be precise
- **Mathematical proofs**: Step-by-step derivations require exactness

**Critical Safety Rule**: If reasoning contains factual claims (metrics, benchmarks, specific values), extract and validate facts separately with exact assertions. Apply reasoning verification only to the logical structure and coherence.

#### How It Works (Conceptually)

**Checklist-Based Validation Process**:

1. **Concept Coverage Check**:
   - Define required concepts that must be mentioned
   - Verify all key concepts appear in reasoning (case-insensitive keyword search)
   - Example: Refactoring justification must mention "complexity", "maintainability", or "performance"

2. **Logical Consistency Check**:
   - Scan for contradictions (simultaneous affirmation and negation)
   - Detect common fallacies (absolute language, circular reasoning, appeals to authority)
   - Example: Flag "always fails" combined with "sometimes works"

3. **Coherence Assessment**:
   - Verify reasoning steps connect logically (cause → effect relationships)
   - Check that conclusion follows from premises
   - Example: "Code is complex" → "Should refactor" (valid), "Code is complex" → "Ship immediately" (incoherent)

4. **Completeness Validation**:
   - Ensure all required reasoning components present
   - Check for missing critical considerations
   - Example: Performance optimization must consider tradeoffs

**Validation Hierarchy**:
```
Required Concepts (MUST be present)
  ↓
  ✅ Verify: All key concepts mentioned
  ↓
Logical Fallacies (MUST be absent)
  ↓
  ✅ Verify: No contradictions, absolutes, or circular logic
  ↓
Coherence (Logical flow)
  ↓
  ✅ Verify: Conclusion follows from premises
  ↓
Factual Claims (Validate separately)
  ↓
  ✅ Extract: Numbers, names, references
  ✅ Verify: With exact assertions
```

#### Decision Criteria

**Use Reasoning Verification when**:
- Explanation content and logic matter, not exact phrasing
- Multiple valid ways exist to express the same reasoning
- AI generates justifications or rationale
- Wording variations don't change logical validity
- Educational/documentation content with inherent variation

**Use Exact Assertions when**:
- Legal or compliance documentation requires precise language
- API documentation must match implementation exactly
- Error messages part of public API contract
- Specific terminology legally or technically mandated
- Reasoning contains critical facts that must be exact

**Decision Questions**:
1. "Does the reasoning contain the same logical components?" → YES = use reasoning verification
2. "Are the factual claims in the reasoning accurate?" → Validate separately with exact assertions
3. "Is this legal, compliance, or API documentation?" → YES = use exact assertions
4. "Would a domain expert accept both explanations as valid?" → YES = use reasoning verification

#### Comparison to Exact Assertions

| Aspect | Reasoning Verification | Exact Assertions |
|--------|----------------------|------------------|
| **Focus** | Logical soundness, concept coverage | Precise wording, exact phrasing |
| **Accepts Synonyms** | ✅ Yes ("optimize" ≈ "improve performance") | ❌ No (different words fail) |
| **Accepts Reordering** | ✅ Yes (reasoning steps can be reordered) | ❌ No (order must match) |
| **Factual Accuracy** | ⚠️ Must validate separately | ✅ Perfect (exact values enforced) |
| **Logical Fallacies** | ✅ Detects (checks for contradictions) | ⚠️ May miss (only checks exact match) |
| **Flexibility** | ✅ High (multiple valid explanations) | ❌ Low (one valid explanation) |
| **Use Case** | AI explanations, educational content | Legal docs, API contracts |

**Key Insight**: Reasoning verification catches logical errors (contradictions, fallacies) that exact assertions might miss, while accepting valid phrasing variations.

#### Implementation Guidance

##### Checklist Design

**Step 1: Define Required Concepts**

Identify domain-specific concepts that MUST appear in valid reasoning:

```python
# Example: Refactoring justification checklist
required_concepts = [
    'complexity',      # Why: Must address complexity
    'maintain',        # Why: Must consider maintainability
    'test',           # Why: Must acknowledge testability impact
]

# Example: Security decision checklist
required_security_concepts = [
    'authentication',  # Must mention auth mechanism
    'authorization',   # Must address access control
    'encryption',      # Must consider data protection
]
```

**Step 2: Define Prohibited Fallacies**

List logical fallacies to detect and reject:

```python
fallacy_patterns = [
    # Absolute language (overgeneralization)
    (r'\b(always|never|everyone|no one|all|none)\b', 'absolute language'),

    # Appeal to authority without evidence
    (r'\b(obviously|clearly|everyone knows|it is known)\b', 'appeal to authority'),

    # Circular reasoning
    (r'\bbecause\s+(?:it|this)\s+is\s+(?:it|this)\b', 'circular reasoning'),
]
```

**Step 3: Build Validation Function**

```python
import re
from typing import List, Tuple

class ReasoningValidator:
    """Validates quality of AI-generated reasoning."""

    def __init__(self, reasoning: str):
        self.reasoning = reasoning
        self.reasoning_lower = reasoning.lower()
        self.issues = []

    def requires_concepts(self, concepts: List[str]) -> 'ReasoningValidator':
        """Verify required concepts are present."""
        for concept in concepts:
            if concept.lower() not in self.reasoning_lower:
                self.issues.append(f"Missing required concept: {concept}")
        return self

    def prohibits_fallacies(self, patterns: List[Tuple[str, str]] = None) -> 'ReasoningValidator':
        """Check for logical fallacies."""
        if patterns is None:
            patterns = [
                (r'\b(always|never|everyone|no one)\b', 'absolute language'),
                (r'\b(obviously|clearly)\b', 'appeal to authority'),
            ]

        for pattern, name in patterns:
            if re.search(pattern, self.reasoning_lower):
                self.issues.append(f"Potential fallacy: {name}")
        return self

    def requires_coherence(self, premise_keywords: List[str], conclusion_keywords: List[str]) -> 'ReasoningValidator':
        """Verify conclusion follows from premises."""
        has_premise = any(kw.lower() in self.reasoning_lower for kw in premise_keywords)
        has_conclusion = any(kw.lower() in self.reasoning_lower for kw in conclusion_keywords)

        if has_conclusion and not has_premise:
            self.issues.append("Conclusion without supporting premises")
        return self

    def is_valid(self) -> bool:
        """Returns True if reasoning passes all checks."""
        return len(self.issues) == 0

    def get_issues(self) -> List[str]:
        """Returns list of validation issues."""
        return self.issues
```

##### Tooling Recommendations

**Python** (pytest):

```python
import pytest

def test_refactoring_reasoning_quality():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI generates valid refactoring justifications with wording variations
    - Pattern: Quality of Reasoning Verification (Pattern 3)
    - Criteria: Key concepts present, no fallacies, logical coherence
    - Failure Action: Check if reasoning became illogical or incomplete
    """
    ai_reasoning = (
        "We should refactor this code because it has high cyclomatic complexity "
        "(complexity of 15), making it difficult to maintain and test. "
        "The current structure violates the Single Responsibility Principle."
    )

    validator = (
        ReasoningValidator(ai_reasoning)
        .requires_concepts(['complexity', 'maintain', 'test'])
        .prohibits_fallacies()
        .requires_coherence(
            premise_keywords=['complexity', 'difficult'],
            conclusion_keywords=['refactor', 'should']
        )
    )

    assert validator.is_valid(), f"Reasoning issues found: {validator.get_issues()}"
```

**JavaScript/TypeScript** (Jest):

```typescript
class ReasoningValidator {
  private reasoning: string;
  private reasoningLower: string;
  private issues: string[] = [];

  constructor(reasoning: string) {
    this.reasoning = reasoning;
    this.reasoningLower = reasoning.toLowerCase();
  }

  requiresConcepts(concepts: string[]): this {
    for (const concept of concepts) {
      if (!this.reasoningLower.includes(concept.toLowerCase())) {
        this.issues.push(`Missing required concept: ${concept}`);
      }
    }
    return this;
  }

  prohibitsFallacies(): this {
    const fallacies = [
      { pattern: /\b(always|never|everyone|no one)\b/i, name: 'absolute language' },
      { pattern: /\b(obviously|clearly)\b/i, name: 'appeal to authority' },
    ];

    for (const { pattern, name } of fallacies) {
      if (pattern.test(this.reasoning)) {
        this.issues.push(`Potential fallacy: ${name}`);
      }
    }
    return this;
  }

  isValid(): boolean {
    return this.issues.length === 0;
  }

  getIssues(): string[] {
    return this.issues;
  }
}

test('validates AI reasoning quality', () => {
  /**
   * FLEXIBLE ASSERTION RATIONALE:
   * - Why: AI produces valid reasoning with phrasing variations
   * - Pattern: Quality of Reasoning Verification (Pattern 3)
   * - Criteria: Required concepts present, no fallacies
   * - Failure Action: Review if reasoning became unsound
   */
  const aiReasoning =
    "We should refactor this code because it has high complexity " +
    "(cyclomatic complexity of 15), making it difficult to maintain and test.";

  const validator = new ReasoningValidator(aiReasoning)
    .requiresConcepts(['complexity', 'maintain', 'test'])
    .prohibitsFallacies();

  expect(validator.isValid()).toBe(true);
  expect(validator.getIssues()).toEqual([]);
});
```

#### Common Pitfalls and How to Avoid Them

**Pitfall 1: Not Extracting Factual Claims**

❌ **Wrong**:
```python
# AI reasoning: "The function processes 100 requests per second on average"
# Expected: "The function processes many requests quickly"
# Similarity-based check passes, but "100 rps" fact lost
def test_performance_reasoning():
    reasoning = ai_explain_performance()
    assert semantic_similarity(reasoning, "Processes many requests quickly") > 0.85
    # Factual claim (100 rps) not validated!
```

✅ **Correct**:
```python
def test_performance_reasoning():
    reasoning = ai_explain_performance()

    # Validate factual claims separately
    throughput = extract_number(reasoning, context="requests per second")
    assert throughput == 100  # Exact fact validation

    # Validate reasoning structure
    validator = (
        ReasoningValidator(reasoning)
        .requires_concepts(['performance', 'throughput', 'requests'])
        .prohibits_fallacies()
    )
    assert validator.is_valid()
```

---

**Pitfall 2: Over-Permissive Concept Requirements**

❌ **Wrong**:
```python
# Too few required concepts - accepts incomplete reasoning
required_concepts = ['code']  # Too vague
# Accepts: "The code exists" (meaningless reasoning)
```

✅ **Correct**:
```python
# Comprehensive concept list ensures completeness
required_concepts = [
    'complexity',      # What problem exists
    'maintain',        # Why it matters
    'refactor',        # Proposed solution
]
# Rejects incomplete reasoning
```

---

**Pitfall 3: Ignoring Contradictions**

❌ **Wrong**:
```python
# Only checks concept presence, misses contradictions
validator.requires_concepts(['fast', 'slow'])  # Both present
# Passes even if reasoning says "it's fast and slow" (contradiction)
```

✅ **Correct**:
```python
def check_contradictions(reasoning: str) -> List[str]:
    """Detect contradictory statements."""
    contradictions = [
        (['fast', 'quick', 'rapid'], ['slow', 'sluggish']),
        (['increase', 'improve'], ['decrease', 'degrade']),
        (['secure', 'safe'], ['vulnerable', 'insecure']),
    ]

    issues = []
    reasoning_lower = reasoning.lower()
    for positive_terms, negative_terms in contradictions:
        has_positive = any(term in reasoning_lower for term in positive_terms)
        has_negative = any(term in reasoning_lower for term in negative_terms)
        if has_positive and has_negative:
            issues.append(f"Contradiction detected: {positive_terms[0]} vs {negative_terms[0]}")

    return issues
```

---

**Pitfall 4: Not Validating Premise-Conclusion Logic**

❌ **Wrong**:
```python
# Reasoning: "The sky is blue, therefore we should use Python"
# No logical connection, but concept check passes
validator.requires_concepts(['sky', 'blue', 'Python'])
# TEST PASSES (wrong!)
```

✅ **Correct**:
```python
# Validate that conclusion logically follows from premises
validator.requires_coherence(
    premise_keywords=['performance', 'bottleneck', 'slow'],
    conclusion_keywords=['optimize', 'refactor', 'improve']
)
# Ensures conclusion relates to premises
```

---

**Pitfall 5: Using Reasoning Verification for Security Explanations**

❌ **Wrong**:
```python
# Security reasoning with flexible validation
def test_security_decision_flexible():
    reasoning = ai_explain_security_choice()
    # Accepts variations that might omit critical security details
    assert 'encrypt' in reasoning.lower()  # Too weak
```

✅ **Correct**:
```python
def test_security_decision_exact():
    """Security reasoning requires exact details."""
    reasoning = ai_explain_security_choice()

    # Exact algorithm must be specified
    assert 'AES-256' in reasoning or 'ChaCha20' in reasoning

    # Exact key management must be mentioned
    assert 'key rotation' in reasoning.lower()
    assert 'HSM' in reasoning or 'key management' in reasoning.lower()

    # Reasoning structure still validated
    validator = ReasoningValidator(reasoning).requires_concepts([
        'encryption', 'key management', 'authentication'
    ])
    assert validator.is_valid()
```

#### Safety Considerations

1. **Factual Claims Require Exact Validation**: Always extract and validate numbers, dates, names, benchmarks separately with exact assertions.

2. **Security Reasoning Needs Exact Details**: While logical structure can vary, specific algorithms, protocols, and configurations must be exact.

3. **Contradictions Are Critical Failures**: Reasoning with logical contradictions should always fail, regardless of concept coverage.

4. **Domain-Specific Fallacies**: Add domain-specific fallacy patterns (e.g., in medical AI, detect "correlation implies causation" errors).

5. **Baseline Exact Tests for Critical Decisions**: Architecture decisions, security choices should have exact baseline tests in addition to reasoning verification.

6. **Version Control for Checklists**: Required concepts and fallacy patterns should be versioned and reviewed. Changes to checklists can mask quality regressions.

#### Integration with RPTC Workflow

When planning in `/rptc:plan`:
```markdown
## Test Strategy for AI Code Documentation

**Assertion Strategy**: Quality of Reasoning Verification (Pattern 3)
**Rationale**: AI generates valid explanations with wording variations
**Required Concepts**: ['complexity', 'maintainability', 'testability']
**Prohibited Fallacies**: Absolute language, unsupported claims
**Baseline**: Exact test validates factual claims (metrics, numbers) separately
```

When implementing in `/rptc:tdd`:
```python
def test_documentation_facts_exact():
    """Baseline: Factual claims must be exact."""
    doc = generate_code_documentation(function_code)
    assert "O(n log n)" in doc  # Exact complexity
    assert "15 lines" in doc    # Exact count

def test_documentation_reasoning_quality():
    """Flexible: Reasoning structure can vary."""
    doc = generate_code_documentation(function_code)

    validator = (
        ReasoningValidator(doc)
        .requires_concepts(['complexity', 'efficiency', 'algorithm'])
        .prohibits_fallacies()
    )
    assert validator.is_valid(), f"Issues: {validator.get_issues()}"
```

---

---

### 3.4 Multiple Valid Solution Path Support

**Status**: ✅ Implemented in Step 6c

#### What is This Pattern?

Multiple Valid Solution Path Support validates that AI-generated outputs match **any member of a predefined set of acceptable solutions**, rather than requiring a single exact output. This pattern acknowledges that many problems have multiple correct approaches, and testing should accept any valid solution.

**Core Principle**: Accept any valid approach from a defined set of possibilities.

**Key Distinction**: This pattern tests "is the output a member of the valid solution set?" rather than "does the output match the one expected solution?"

#### When to Use This Pattern

Use Multiple Valid Solution Path Support when:
- **Unordered collections**: Sets, lists where element order is semantically irrelevant
- **Multiple algorithms**: Different but equally correct approaches (quicksort vs mergesort vs heapsort)
- **API response supersets**: Actual response includes all required fields plus optional extras
- **Configuration equivalence**: Different config formats representing identical settings (JSON vs YAML)
- **Property order variations**: JSON object properties in different orders
- **Enum-style selections**: AI chooses from predefined valid options
- **Refactoring alternatives**: Multiple valid ways to structure same logic

**Real-World Scenarios**:
- Testing tag lists where order doesn't matter: `["ai", "python", "testing"]` vs `["testing", "ai", "python"]`
- Validating AI chooses valid algorithm: accepts quicksort, mergesort, or heapsort
- Checking API responses with optional fields: required fields present, extras allowed
- Verifying configuration files: JSON and YAML representations both valid

#### When NOT to Use This Pattern

**DO NOT use for**:
- **Ordered sequences**: When element order matters semantically (e.g., execution steps, time series)
- **Undefined solution space**: When you can't enumerate all valid solutions
- **Infinite solution sets**: When valid solutions are unbounded (use property-based testing instead)
- **Performance-critical choices**: When specific algorithm matters (use implementation testing)
- **Security configurations**: When specific settings required (use exact assertions)
- **Single correct answer**: When only one output is valid

**Critical Safety Rule**: The valid solution set must be complete and well-defined. Incomplete sets cause false negatives (reject valid outputs). Overly permissive sets cause false positives (accept invalid outputs).

#### How It Works (Conceptually)

**Set Membership Testing Process**:

1. **Define Valid Solution Set**:
   - Enumerate all acceptable solutions explicitly
   - Use set operations for unordered collections
   - Define validation predicates for infinite sets (reduced to property checks)

2. **Test Against Each Solution**:
   - Compare actual output to each valid solution
   - Use appropriate comparison method (equality, set membership, predicate evaluation)

3. **Pass if ANY Match**:
   - Test passes if actual output matches at least one valid solution
   - Order of checking doesn't matter (set membership is associative)

4. **Fail if NONE Match**:
   - Test fails only if actual output matches no valid solutions
   - Failure indicates unexpected output (not in known-valid set)

**Testing Hierarchy**:
```
Actual Output
  ↓
  Test: Output ∈ Valid Solutions Set?
  ↓
  ├─ YES → ✅ PASS (matches at least one valid solution)
  │
  └─ NO → ❌ FAIL (matches no valid solutions)

Valid Solutions Set:
  - Solution A (algorithm 1)
  - Solution B (algorithm 2)
  - ...
  - Solution N (algorithm N)
```

#### Decision Criteria

**Use Multiple Valid Paths when**:
- You can enumerate all valid solutions (finite set)
- Multiple correct approaches exist
- Order/structure variations don't affect correctness
- AI may choose from predefined valid options
- Testing for membership in known-valid set

**Use Exact Assertions when**:
- Only one solution is correct
- Order/structure matters semantically
- Performance requires specific approach
- Security mandates specific implementation
- External contract defines exact format

**Decision Questions**:
1. "Can you enumerate all valid solutions?" → YES = use multiple valid paths
2. "Are all enumerated solutions equally acceptable?" → YES = use multiple valid paths
3. "Is there only one correct answer?" → YES = use exact assertions
4. "Does order/structure affect correctness?" → YES = use exact assertions or behavioral testing

#### Comparison to Exact Assertions

| Aspect | Multiple Valid Paths | Exact Assertions |
|--------|---------------------|------------------|
| **Solution Count** | Multiple valid (predefined set) | Single valid solution |
| **Flexibility** | ✅ High (any valid solution accepted) | ❌ Low (only one accepted) |
| **Order Sensitivity** | ✅ Can ignore order (set comparison) | ⚠️ Order-dependent (list comparison) |
| **Implementation Choice** | ✅ Accepts alternatives | ❌ Requires specific choice |
| **Definition Effort** | ⚠️ Must enumerate all solutions | ✅ Define one solution |
| **False Negatives** | ⚠️ Risk if set incomplete | ✅ None (deterministic) |
| **Use Case** | Unordered data, multiple algorithms | Ordered data, single correct answer |

**Key Insight**: Multiple valid paths pattern is ideal when the solution space is finite and enumerable, but exact assertions are more precise when there's only one correct answer.

#### Implementation Guidance

##### Pattern 1: Set-Based Comparison (Unordered Collections)

**Use Case**: When element order doesn't matter (tags, categories, feature flags).

```python
def test_ai_generates_valid_tags():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Tag order is semantically irrelevant
    - Pattern: Multiple Valid Solution Paths (Pattern 4)
    - Criteria: Tags match expected set (order-independent)
    - Failure Action: Check if new tag added or tag missing
    """
    tags = ai_generate_tags(article)
    expected_tags = {"python", "testing", "ai", "automation"}

    # Set comparison ignores order
    assert set(tags) == expected_tags, f"Tag mismatch: {set(tags)} != {expected_tags}"
```

---

##### Pattern 2: Explicit Solution Enumeration (Multiple Algorithms)

**Use Case**: When AI may choose from several valid algorithms/approaches.

```python
def test_ai_sorting_algorithm_choice():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Multiple valid sorting algorithms exist
    - Pattern: Multiple Valid Solution Paths (Pattern 4)
    - Criteria: Chosen algorithm must be from valid set
    - Failure Action: Check if AI chose invalid/inefficient algorithm
    """
    algorithm = ai_choose_sorting_algorithm(data_characteristics)

    valid_algorithms = {
        'quicksort',    # O(n log n) average
        'mergesort',    # O(n log n) guaranteed
        'heapsort',     # O(n log n) in-place
        'timsort',      # O(n log n) with good real-world performance
    }

    assert algorithm in valid_algorithms, \
        f"Invalid algorithm choice: {algorithm} not in {valid_algorithms}"

    # Additional validation: verify algorithm actually works
    sorted_data = sort_with_algorithm(data, algorithm)
    assert sorted_data == sorted(data), "Chosen algorithm produced incorrect results"
```

---

##### Pattern 3: Superset/Subset Validation (API Responses)

**Use Case**: When actual output may include required fields plus optional extras.

```python
def test_api_response_contains_required_fields():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: API may include optional fields (non-breaking additions)
    - Pattern: Multiple Valid Solution Paths (Pattern 4)
    - Criteria: All required fields present, extras allowed
    - Failure Action: Check if required field missing
    """
    response = api_get_user(user_id=123)

    required_fields = {'user_id', 'name', 'email', 'created_at'}
    optional_fields = {'phone', 'address', 'preferences', 'avatar_url'}

    response_fields = set(response.keys())

    # Required fields must all be present (subset check)
    assert required_fields.issubset(response_fields), \
        f"Missing required fields: {required_fields - response_fields}"

    # Extra fields only allowed if in optional set (no unknown fields)
    extra_fields = response_fields - required_fields
    unknown_fields = extra_fields - optional_fields
    assert len(unknown_fields) == 0, \
        f"Unknown fields in response: {unknown_fields}"
```

---

##### Pattern 4: Predicate-Based Validation (Infinite Valid Sets)

**Use Case**: When valid solutions form a pattern rather than finite set.

```python
def test_ai_generates_valid_id():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Many valid ID formats exist (UUID, ULID, custom)
    - Pattern: Multiple Valid Solution Paths (Pattern 4)
    - Criteria: ID must match at least one valid format
    - Failure Action: Check if ID format invalid or insecure
    """
    user_id = ai_generate_user_id()

    # Define validity predicates for different formats
    def is_valid_uuid(id_str):
        import uuid
        try:
            uuid.UUID(id_str)
            return True
        except ValueError:
            return False

    def is_valid_ulid(id_str):
        # ULID: 26 characters, alphanumeric (Crockford's Base32)
        import re
        return bool(re.match(r'^[0-9A-HJKMNP-TV-Z]{26}$', id_str))

    def is_valid_custom_format(id_str):
        # Custom: user_<timestamp>_<random>
        import re
        return bool(re.match(r'^user_\d{10}_[a-f0-9]{8}$', id_str))

    # ID is valid if it matches ANY format
    validity_checks = [is_valid_uuid, is_valid_ulid, is_valid_custom_format]
    is_valid = any(check(user_id) for check in validity_checks)

    assert is_valid, f"ID '{user_id}' doesn't match any valid format"
```

##### Tooling Recommendations

**Python** (pytest):

```python
import pytest

def test_unordered_collection_equality():
    """Test set-based comparison for unordered data."""
    result = ai_extract_keywords(text)
    expected_keywords = {"machine", "learning", "python", "data"}

    assert set(result) == expected_keywords

def test_multiple_valid_implementations():
    """Test that AI chooses from valid implementation strategies."""
    implementation = ai_design_cache_strategy(requirements)

    valid_strategies = {
        'LRU',    # Least Recently Used
        'LFU',    # Least Frequently Used
        'FIFO',   # First In First Out
        'TTL',    # Time To Live
    }

    assert implementation.strategy in valid_strategies

# Using pytest.mark.parametrize for exhaustive testing
@pytest.mark.parametrize("valid_output", [
    {"status": "success", "data": {"id": 1}},
    {"status": "success", "data": {"id": 1}, "meta": {"timestamp": "2025-01-01"}},
    {"status": "success", "data": {"id": 1}, "warnings": []},
])
def test_multiple_valid_response_structures(valid_output):
    """Verify all valid output structures accepted."""
    # Simulate AI generating response
    actual = ai_format_response(data={'id': 1})

    # At minimum, must match required structure
    assert actual.get("status") == "success"
    assert actual.get("data") == {"id": 1}
```

**JavaScript/TypeScript** (Jest):

```typescript
describe('Multiple Valid Solution Path Support', () => {
  it('accepts unordered collections', () => {
    /**
     * FLEXIBLE ASSERTION RATIONALE:
     * - Why: Tag order doesn't matter
     * - Pattern: Multiple Valid Paths (Pattern 4)
     * - Criteria: Tags match expected set
     * - Failure Action: Check for missing/extra tags
     */
    const tags = aiGenerateTags(article);
    const expectedTags = new Set(['typescript', 'testing', 'jest', 'tdd']);

    expect(new Set(tags)).toEqual(expectedTags);
  });

  it('accepts multiple valid algorithms', () => {
    const algorithm = aiChooseSortingAlgorithm(dataCharacteristics);

    const validAlgorithms = new Set([
      'quicksort',
      'mergesort',
      'heapsort',
      'timsort',
    ]);

    expect(validAlgorithms.has(algorithm)).toBe(true);

    // Verify chosen algorithm works
    const sorted = sortWithAlgorithm(data, algorithm);
    expect(sorted).toEqual([...data].sort((a, b) => a - b));
  });

  it('accepts API responses with optional fields', () => {
    const response = apiGetUser(123);

    const requiredFields = new Set(['user_id', 'name', 'email']);
    const optionalFields = new Set(['phone', 'address', 'avatar_url']);

    const responseFields = new Set(Object.keys(response));

    // All required fields must be present
    requiredFields.forEach(field => {
      expect(responseFields.has(field)).toBe(true);
    });

    // Extra fields only from optional set
    const extraFields = [...responseFields].filter(f => !requiredFields.has(f));
    extraFields.forEach(field => {
      expect(optionalFields.has(field)).toBe(true);
    });
  });
});
```

#### Common Pitfalls and How to Avoid Them

**Pitfall 1: Incomplete Valid Solution Set**

❌ **Wrong**:
```python
# Only lists 2 valid algorithms, but AI might choose 4th valid one
valid_algorithms = {'quicksort', 'mergesort'}
assert chosen_algorithm in valid_algorithms
# Fails when AI chooses 'heapsort' (also valid!)
```

✅ **Correct**:
```python
# Exhaustively enumerate ALL valid algorithms
valid_algorithms = {
    'quicksort', 'mergesort', 'heapsort', 'timsort',
    'introsort', 'pdqsort',  # Add all acceptable choices
}
assert chosen_algorithm in valid_algorithms
```

**Guideline**: If you can't enumerate all valid solutions, use property-based testing or behavioral testing instead.

---

**Pitfall 2: Order-Dependent Comparison for Unordered Data**

❌ **Wrong**:
```python
# List comparison is order-sensitive
tags = ai_generate_tags(article)
assert tags == ["python", "testing", "ai"]
# Fails if AI returns ["ai", "python", "testing"] (same tags, different order)
```

✅ **Correct**:
```python
# Set comparison is order-independent
tags = ai_generate_tags(article)
assert set(tags) == {"python", "testing", "ai"}
# Passes regardless of order
```

---

**Pitfall 3: Not Validating Solution Quality**

❌ **Wrong**:
```python
# Accepts any valid algorithm, even if inefficient for data
valid_algorithms = {'bubblesort', 'quicksort', 'mergesort'}
assert chosen_algorithm in valid_algorithms
# Bubblesort is "valid" but O(n²) - unacceptable for large data
```

✅ **Correct**:
```python
# Define valid algorithms based on data characteristics
if len(data) > 10000:
    valid_algorithms = {'quicksort', 'mergesort', 'heapsort'}  # O(n log n) only
else:
    valid_algorithms = {'quicksort', 'mergesort', 'heapsort', 'insertion_sort'}

assert chosen_algorithm in valid_algorithms

# Additional performance validation
import time
start = time.time()
result = sort_with_algorithm(data, chosen_algorithm)
elapsed = time.time() - start
assert elapsed < 1.0, f"Sorting took {elapsed}s (too slow for {chosen_algorithm})"
```

---

**Pitfall 4: Overly Permissive Solution Set**

❌ **Wrong**:
```python
# Accepts too many solutions, including invalid ones
valid_status_codes = {200, 201, 202, 204, 400, 401, 403, 404, 500}
assert response.status_code in valid_status_codes
# Accepts errors (4xx, 5xx) as valid!
```

✅ **Correct**:
```python
# Only accept success codes
valid_success_codes = {200, 201, 202, 204}
assert response.status_code in valid_success_codes, \
    f"Expected success, got {response.status_code}"

# Separate test for expected error scenarios
def test_error_handling():
    with pytest.raises(ValueError):
        response = api_call_with_invalid_data()
    # Error handling is tested separately, not mixed with success cases
```

---

**Pitfall 5: Not Documenting Why Multiple Solutions Valid**

❌ **Wrong**:
```python
def test_output():
    assert result in {solution_a, solution_b, solution_c}
    # Why are these all valid? No explanation.
```

✅ **Correct**:
```python
def test_output():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Multiple sort algorithms valid (O(n log n) required, any acceptable)
    - Pattern: Multiple Valid Paths (Pattern 4)
    - Valid Solutions:
        - quicksort: Average O(n log n), good cache locality
        - mergesort: Guaranteed O(n log n), stable
        - heapsort: O(n log n), in-place
    - Criteria: Chosen algorithm must be O(n log n) or better
    - Failure Action: Check if AI chose suboptimal algorithm (e.g., bubble sort)
    """
    assert chosen_algorithm in {'quicksort', 'mergesort', 'heapsort'}
```

#### Safety Considerations

1. **Enumerate Exhaustively**: Valid solution set must include ALL acceptable solutions. Incomplete sets cause false negatives.

2. **Document Each Solution's Validity**: Explain why each solution in the set is acceptable. Undocumented solutions raise suspicion in code review.

3. **Validate Solution Quality**: Don't just check membership—verify chosen solution is appropriate for context (performance, security, correctness).

4. **Separate Error Cases**: Don't include error states in "valid solutions." Test errors separately with exact assertions.

5. **Performance Still Matters**: Even if multiple algorithms are "valid," test that chosen algorithm meets performance requirements.

6. **Security Critical Paths Need Exact**: Don't use multiple valid paths for security configurations. Security requires specific, auditable choices.

#### Integration with RPTC Workflow

When planning in `/rptc:plan`:
```markdown
## Test Strategy for AI Tag Generation

**Assertion Strategy**: Multiple Valid Solution Paths (Pattern 4)
**Rationale**: Tag order is semantically irrelevant; multiple orderings valid
**Valid Solutions**: Any permutation of {"python", "testing", "ai", "automation"}
**Criteria**: Generated tags must match expected set (order-independent)
**Baseline**: Exact test validates tag count and no duplicates
```

When implementing in `/rptc:tdd`:
```python
def test_tag_generation_exact_baseline():
    """Baseline: Tag count and uniqueness exact."""
    tags = ai_generate_tags(article)
    assert len(tags) == 4  # Exact count
    assert len(set(tags)) == 4  # No duplicates

def test_tag_generation_multiple_valid_orderings():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Tag order doesn't affect functionality
    - Pattern: Multiple Valid Paths (Pattern 4)
    - Criteria: Tags match expected set (order-independent)
    - Failure Action: Check for missing/extra tags
    """
    tags = ai_generate_tags(article)
    expected_tags = {"python", "testing", "ai", "automation"}

    assert set(tags) == expected_tags, \
        f"Tag set mismatch: {set(tags)} != {expected_tags}"
```

---

---

## 4. Language-Specific Examples

**Status**: ✅ Implemented in Step 6c

This section provides concrete, executable examples of flexible assertion patterns across multiple programming languages and testing frameworks.

### 4.1 Python (pytest)

**Setup Requirements**:
```bash
pip install pytest sentence-transformers  # For semantic similarity
# or
pip install pytest openai  # For OpenAI embeddings
```

#### Pattern 1: Semantic Similarity Evaluation

```python
# test_semantic_similarity.py
import pytest
from sentence_transformers import SentenceTransformer, util

# Global model instance (loaded once)
model = SentenceTransformer('all-MiniLM-L6-v2')

def semantic_similarity(text1: str, text2: str) -> float:
    """Calculate cosine similarity between two texts."""
    embeddings = model.encode([text1, text2])
    similarity = util.cos_sim(embeddings[0], embeddings[1])
    return float(similarity[0][0])

def test_ai_generated_documentation():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI generates valid doc variations with different phrasing
    - Pattern: Semantic Similarity (Pattern 1)
    - Threshold: >0.85 cosine similarity
    - Failure Action: Review if similarity drops, check prompt stability
    """
    doc = generate_function_documentation(sample_function)
    expected = "Validates email format and returns boolean result indicating validity"

    similarity = semantic_similarity(doc, expected)
    assert similarity > 0.85, f"Doc similarity {similarity:.3f} below threshold 0.85"

def test_ai_error_message_clarity():
    """Semantic similarity for error message variations."""
    error_msg = ai_generate_error_message(error_context)
    expected = "Invalid email format: must contain @ symbol and domain name"

    similarity = semantic_similarity(error_msg, expected)
    assert similarity > 0.80, f"Error message similarity {similarity:.3f} too low"
```

#### Pattern 2: Behavioral Correctness Assessment

```python
# test_behavioral_correctness.py
import pytest
from unittest.mock import Mock, patch

def test_data_processor_behavior():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI may implement with different variable names or structure
    - Pattern: Behavioral Correctness (Pattern 2)
    - Criteria: Input correctly transformed to output
    - Failure Action: Check if transformation logic changed
    """
    input_data = [
        {'name': 'Alice', 'age': 30},
        {'name': 'Bob', 'age': 25}
    ]

    # Execute (don't care how it's implemented internally)
    result = ai_generated_data_processor(input_data)

    # Verify behavioral correctness
    assert len(result) == 2
    assert all('name_upper' in item for item in result)
    assert result[0]['name_upper'] == 'ALICE'
    assert result[1]['name_upper'] == 'BOB'
    assert all('age' in item for item in result)

@patch('external_api.call')
def test_api_integration_side_effects(mock_api):
    """Test side effects, not implementation details."""
    mock_api.return_value = {'status': 'success', 'id': 123}

    result = ai_process_order(order_data)

    # Verify API called with correct parameters
    mock_api.assert_called_once()
    call_args = mock_api.call_args[0][0]
    assert call_args['customer_id'] == 456
    assert call_args['items'] == order_data['items']

    # Verify result
    assert result['external_id'] == 123
    assert result['status'] == 'confirmed'
```

#### Pattern 3: Quality of Reasoning Verification

```python
# test_reasoning_quality.py
import pytest
import re
from typing import List, Tuple

class ReasoningValidator:
    """Validates quality of AI-generated reasoning."""

    def __init__(self, reasoning: str):
        self.reasoning = reasoning
        self.reasoning_lower = reasoning.lower()
        self.issues = []

    def requires_concepts(self, concepts: List[str]) -> 'ReasoningValidator':
        """Verify required concepts are present."""
        for concept in concepts:
            if concept.lower() not in self.reasoning_lower:
                self.issues.append(f"Missing required concept: {concept}")
        return self

    def prohibits_fallacies(self, patterns: List[Tuple[str, str]] = None) -> 'ReasoningValidator':
        """Check for logical fallacies."""
        if patterns is None:
            patterns = [
                (r'\b(always|never|everyone|no one)\b', 'absolute language'),
                (r'\b(obviously|clearly)\b', 'appeal to authority'),
            ]

        for pattern, name in patterns:
            if re.search(pattern, self.reasoning_lower):
                self.issues.append(f"Potential fallacy: {name}")
        return self

    def requires_coherence(self, premise_keywords: List[str], conclusion_keywords: List[str]) -> 'ReasoningValidator':
        """Verify conclusion follows from premises."""
        has_premise = any(kw.lower() in self.reasoning_lower for kw in premise_keywords)
        has_conclusion = any(kw.lower() in self.reasoning_lower for kw in conclusion_keywords)

        if has_conclusion and not has_premise:
            self.issues.append("Conclusion without supporting premises")
        return self

    def is_valid(self) -> bool:
        return len(self.issues) == 0

    def get_issues(self) -> List[str]:
        return self.issues

def test_refactoring_justification_quality():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: AI generates valid refactoring rationale with phrasing variations
    - Pattern: Quality of Reasoning (Pattern 3)
    - Criteria: Key concepts present, no fallacies, logical coherence
    - Failure Action: Review if reasoning became illogical
    """
    reasoning = ai_explain_refactoring_decision(code_sample)

    validator = (
        ReasoningValidator(reasoning)
        .requires_concepts(['complexity', 'maintainability', 'testability'])
        .prohibits_fallacies()
        .requires_coherence(
            premise_keywords=['complex', 'difficult', 'hard'],
            conclusion_keywords=['refactor', 'simplify', 'improve']
        )
    )

    assert validator.is_valid(), f"Reasoning issues: {validator.get_issues()}"

def test_architectural_decision_reasoning():
    """Validate reasoning for architecture choices."""
    decision_doc = ai_generate_architecture_decision(requirements)

    validator = (
        ReasoningValidator(decision_doc)
        .requires_concepts(['scalability', 'performance', 'maintainability'])
        .prohibits_fallacies([
            (r'\b(always|never|all|none)\b', 'absolute language'),
            (r'\bguaranteed\b', 'overpromising'),
        ])
    )

    assert validator.is_valid(), f"ADR issues: {validator.get_issues()}"
```

#### Pattern 4: Multiple Valid Solution Path Support

```python
# test_multiple_valid_paths.py
import pytest

def test_unordered_tag_generation():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: Tag order is semantically irrelevant
    - Pattern: Multiple Valid Paths (Pattern 4)
    - Criteria: Tags match expected set (order-independent)
    - Failure Action: Check for missing/extra tags
    """
    tags = ai_generate_tags(article)
    expected_tags = {"python", "testing", "ai", "automation"}

    assert set(tags) == expected_tags, f"Tag mismatch: {set(tags)} != {expected_tags}"

def test_algorithm_choice():
    """AI chooses from valid algorithm set."""
    algorithm = ai_choose_sorting_algorithm(data_characteristics)

    valid_algorithms = {
        'quicksort',
        'mergesort',
        'heapsort',
        'timsort',
    }

    assert algorithm in valid_algorithms, \
        f"Invalid algorithm: {algorithm} not in {valid_algorithms}"

@pytest.mark.parametrize("valid_format", [
    "UUID",
    "ULID",
    "CUSTOM"
])
def test_id_generation_accepts_multiple_formats(valid_format):
    """Multiple ID formats are valid."""
    user_id = ai_generate_user_id(format_hint=valid_format)

    # Validation predicates
    import uuid
    import re

    is_uuid = lambda x: bool(re.match(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', x))
    is_ulid = lambda x: bool(re.match(r'^[0-9A-HJKMNP-TV-Z]{26}$', x))
    is_custom = lambda x: bool(re.match(r'^user_\d{10}_[a-f0-9]{8}$', x))

    validators = [is_uuid, is_ulid, is_custom]
    assert any(v(user_id) for v in validators), f"Invalid ID format: {user_id}"
```

---

### 4.2 JavaScript/TypeScript (Jest)

**Setup Requirements**:
```bash
npm install --save-dev jest @types/jest
npm install @tensorflow-models/universal-sentence-encoder @tensorflow/tfjs
# or
npm install openai  # For OpenAI embeddings
```

#### Pattern 1: Semantic Similarity Evaluation

```typescript
// semantic-similarity.test.ts
import * as use from '@tensorflow-models/universal-sentence-encoder';

let model: use.UniversalSentenceEncoder;

beforeAll(async () => {
  model = await use.load();
});

async function semanticSimilarity(text1: string, text2: string): Promise<number> {
  const embeddings = await model.embed([text1, text2]);
  const embedArray = await embeddings.array();

  // Cosine similarity
  const dotProduct = embedArray[0].reduce((sum, val, i) => sum + val * embedArray[1][i], 0);
  const mag1 = Math.sqrt(embedArray[0].reduce((sum, val) => sum + val * val, 0));
  const mag2 = Math.sqrt(embedArray[1].reduce((sum, val) => sum + val * val, 0));

  return dotProduct / (mag1 * mag2);
}

describe('Semantic Similarity Tests', () => {
  it('validates AI-generated documentation', async () => {
    /**
     * FLEXIBLE ASSERTION RATIONALE:
     * - Why: AI doc generator produces valid variations
     * - Pattern: Semantic Similarity (Pattern 1)
     * - Threshold: >0.85
     * - Failure Action: Check for prompt drift
     */
    const doc = await generateDocumentation(sampleFunction);
    const expected = "Validates email format and returns boolean result";

    const similarity = await semanticSimilarity(doc, expected);
    expect(similarity).toBeGreaterThan(0.85);
  });

  it('validates AI-generated error messages', async () => {
    const errorMsg = generateErrorMessage(errorContext);
    const expected = "Invalid email: must contain @ symbol and domain";

    const similarity = await semanticSimilarity(errorMsg, expected);
    expect(similarity).toBeGreaterThan(0.80);
  });
});
```

#### Pattern 2: Behavioral Correctness Assessment

```typescript
// behavioral-correctness.test.ts
import { jest } from '@jest/globals';

describe('Behavioral Correctness', () => {
  it('tests data transformation behavior', () => {
    /**
     * FLEXIBLE ASSERTION RATIONALE:
     * - Why: AI may use different implementation approaches
     * - Pattern: Behavioral Correctness (Pattern 2)
     * - Criteria: Correct input → output transformation
     * - Failure Action: Verify transformation logic
     */
    const input = [
      { name: 'Alice', age: 30 },
      { name: 'Bob', age: 25 }
    ];

    const result = aiGeneratedDataProcessor(input);

    // Test behavior, not implementation
    expect(result).toHaveLength(2);
    expect(result[0]).toHaveProperty('name_upper', 'ALICE');
    expect(result[1]).toHaveProperty('name_upper', 'BOB');
    expect(result.every(item => 'age' in item)).toBe(true);
  });

  it('tests API integration side effects', async () => {
    const mockApi = jest.fn().mockResolvedValue({ status: 'success', id: 123 });

    const result = await aiProcessOrder(orderData, mockApi);

    // Verify side effects
    expect(mockApi).toHaveBeenCalledTimes(1);
    expect(mockApi).toHaveBeenCalledWith(
      expect.objectContaining({
        customer_id: 456,
        items: orderData.items
      })
    );

    // Verify result
    expect(result).toMatchObject({
      external_id: 123,
      status: 'confirmed'
    });
  });
});
```

#### Pattern 3: Quality of Reasoning Verification

```typescript
// reasoning-validation.test.ts
class ReasoningValidator {
  private reasoning: string;
  private reasoningLower: string;
  private issues: string[] = [];

  constructor(reasoning: string) {
    this.reasoning = reasoning;
    this.reasoningLower = reasoning.toLowerCase();
  }

  requiresConcepts(concepts: string[]): this {
    for (const concept of concepts) {
      if (!this.reasoningLower.includes(concept.toLowerCase())) {
        this.issues.push(`Missing required concept: ${concept}`);
      }
    }
    return this;
  }

  prohibitsFallacies(): this {
    const fallacies = [
      { pattern: /\b(always|never|everyone|no one)\b/i, name: 'absolute language' },
      { pattern: /\b(obviously|clearly)\b/i, name: 'appeal to authority' },
    ];

    for (const { pattern, name } of fallacies) {
      if (pattern.test(this.reasoning)) {
        this.issues.push(`Potential fallacy: ${name}`);
      }
    }
    return this;
  }

  requiresCoherence(premiseKeywords: string[], conclusionKeywords: string[]): this {
    const hasPremise = premiseKeywords.some(kw => this.reasoningLower.includes(kw.toLowerCase()));
    const hasConclusion = conclusionKeywords.some(kw => this.reasoningLower.includes(kw.toLowerCase()));

    if (hasConclusion && !hasPremise) {
      this.issues.push('Conclusion without supporting premises');
    }
    return this;
  }

  isValid(): boolean {
    return this.issues.length === 0;
  }

  getIssues(): string[] {
    return this.issues;
  }
}

describe('Reasoning Quality Validation', () => {
  it('validates refactoring justification', () => {
    /**
     * FLEXIBLE ASSERTION RATIONALE:
     * - Why: AI produces valid reasoning with phrasing variations
     * - Pattern: Quality of Reasoning (Pattern 3)
     * - Criteria: Required concepts present, no fallacies
     * - Failure Action: Review if reasoning became unsound
     */
    const reasoning = aiExplainRefactoring(codeSample);

    const validator = new ReasoningValidator(reasoning)
      .requiresConcepts(['complexity', 'maintainability', 'testability'])
      .prohibitsFallacies()
      .requiresCoherence(
        ['complex', 'difficult'],
        ['refactor', 'improve']
      );

    expect(validator.isValid()).toBe(true);
    expect(validator.getIssues()).toEqual([]);
  });
});
```

#### Pattern 4: Multiple Valid Solution Path Support

```typescript
// multiple-valid-paths.test.ts
describe('Multiple Valid Solution Paths', () => {
  it('accepts unordered collections', () => {
    /**
     * FLEXIBLE ASSERTION RATIONALE:
     * - Why: Tag order doesn't matter
     * - Pattern: Multiple Valid Paths (Pattern 4)
     * - Criteria: Tags match expected set
     * - Failure Action: Check for missing/extra tags
     */
    const tags = aiGenerateTags(article);
    const expectedTags = new Set(['typescript', 'testing', 'jest', 'tdd']);

    expect(new Set(tags)).toEqual(expectedTags);
  });

  it('accepts multiple valid algorithms', () => {
    const algorithm = aiChooseSortingAlgorithm(dataCharacteristics);

    const validAlgorithms = new Set([
      'quicksort',
      'mergesort',
      'heapsort',
      'timsort',
    ]);

    expect(validAlgorithms.has(algorithm)).toBe(true);

    // Verify algorithm works
    const sorted = sortWithAlgorithm(data, algorithm);
    expect(sorted).toEqual([...data].sort((a, b) => a - b));
  });

  it('accepts API responses with optional fields', () => {
    const response = apiGetUser(123);

    const requiredFields = new Set(['user_id', 'name', 'email']);
    const optionalFields = new Set(['phone', 'address']);

    const responseFields = new Set(Object.keys(response));

    // All required fields present
    requiredFields.forEach(field => {
      expect(responseFields.has(field)).toBe(true);
    });

    // Extra fields only from optional set
    const extraFields = [...responseFields].filter(f => !requiredFields.has(f));
    extraFields.forEach(field => {
      expect(optionalFields.has(field)).toBe(true);
    });
  });
});
```

---

### 4.3 Go (testing package)

**Setup**: Go's standard `testing` package (no additional dependencies for basic patterns).

#### Conceptual Guidance for All Patterns

```go
// Pattern 1: Semantic Similarity
// Use custom assertion functions that compute similarity

func AssertSemanticSimilarity(t *testing.T, actual, expected string, threshold float64) {
    // Implementation options:
    // 1. Call Python script with sentence-transformers
    // 2. Use Go NLP library (e.g., go-nlp)
    // 3. Use external API (OpenAI embeddings)

    similarity := computeSimilarity(actual, expected)
    if similarity < threshold {
        t.Errorf("Semantic similarity %.3f below threshold %.3f", similarity, threshold)
    }
}

func TestAIGeneratedDocumentation(t *testing.T) {
    doc := generateDocumentation(sampleFunction)
    expected := "Validates email format and returns boolean result"

    AssertSemanticSimilarity(t, doc, expected, 0.85)
}
```

```go
// Pattern 2: Behavioral Correctness
// Focus on input → output, ignore implementation

func TestDataProcessorBehavior(t *testing.T) {
    input := []map[string]interface{}{
        {"name": "Alice", "age": 30},
        {"name": "Bob", "age": 25},
    }

    result := aiGeneratedDataProcessor(input)

    // Verify behavior
    if len(result) != 2 {
        t.Errorf("Expected 2 items, got %d", len(result))
    }

    if result[0]["name_upper"] != "ALICE" {
        t.Errorf("Expected ALICE, got %v", result[0]["name_upper"])
    }
}
```

```go
// Pattern 3: Quality of Reasoning
// Checklist-based validation

type ReasoningValidator struct {
    reasoning string
    issues    []string
}

func NewReasoningValidator(reasoning string) *ReasoningValidator {
    return &ReasoningValidator{
        reasoning: strings.ToLower(reasoning),
        issues:    []string{},
    }
}

func (rv *ReasoningValidator) RequiresConcepts(concepts []string) *ReasoningValidator {
    for _, concept := range concepts {
        if !strings.Contains(rv.reasoning, strings.ToLower(concept)) {
            rv.issues = append(rv.issues, fmt.Sprintf("Missing concept: %s", concept))
        }
    }
    return rv
}

func (rv *ReasoningValidator) IsValid() bool {
    return len(rv.issues) == 0
}

func TestRefactoringReasoning(t *testing.T) {
    reasoning := aiExplainRefactoring(codeSample)

    validator := NewReasoningValidator(reasoning).
        RequiresConcepts([]string{"complexity", "maintainability", "testability"})

    if !validator.IsValid() {
        t.Errorf("Reasoning issues: %v", validator.issues)
    }
}
```

```go
// Pattern 4: Multiple Valid Paths
// Set-based or predicate-based validation

func TestUnorderedTags(t *testing.T) {
    tags := aiGenerateTags(article)
    expectedTags := map[string]bool{
        "go": true, "testing": true, "tdd": true,
    }

    // Convert to map for order-independent comparison
    actualTags := make(map[string]bool)
    for _, tag := range tags {
        actualTags[tag] = true
    }

    // Compare maps
    if !reflect.DeepEqual(actualTags, expectedTags) {
        t.Errorf("Tag mismatch: got %v, want %v", actualTags, expectedTags)
    }
}

func TestMultipleValidAlgorithms(t *testing.T) {
    algorithm := aiChooseSortingAlgorithm(dataCharacteristics)

    validAlgorithms := map[string]bool{
        "quicksort": true,
        "mergesort": true,
        "heapsort":  true,
    }

    if !validAlgorithms[algorithm] {
        t.Errorf("Invalid algorithm: %s", algorithm)
    }
}
```

**Key Go Testing Patterns**:
- Use table-driven tests for behavioral correctness
- Create custom assertion helpers for complex validations
- Leverage `testing.T` for failure reporting
- Use `testify/assert` package for richer assertions (optional)

---

### 4.4 Rust (cargo test)

**Setup**: Rust's built-in test framework + optional crates.

```toml
# Cargo.toml
[dev-dependencies]
proptest = "1.0"  # For property-based testing
```

#### Conceptual Guidance for All Patterns

```rust
// Pattern 1: Semantic Similarity
// Use custom assertion macros or functions

fn assert_semantic_similarity(actual: &str, expected: &str, threshold: f64) {
    // Implementation options:
    // 1. Call external Python script
    // 2. Use Rust NLP crate (if available)
    // 3. HTTP call to embedding API

    let similarity = compute_similarity(actual, expected);
    assert!(
        similarity > threshold,
        "Similarity {:.3} below threshold {:.3}",
        similarity,
        threshold
    );
}

#[test]
fn test_ai_generated_documentation() {
    let doc = generate_documentation(&sample_function);
    let expected = "Validates email format and returns boolean result";

    assert_semantic_similarity(&doc, expected, 0.85);
}
```

```rust
// Pattern 2: Behavioral Correctness
// Focus on observable behavior

#[test]
fn test_data_processor_behavior() {
    let input = vec![
        ("Alice".to_string(), 30),
        ("Bob".to_string(), 25),
    ];

    let result = ai_generated_data_processor(&input);

    // Test behavior, not implementation
    assert_eq!(result.len(), 2);
    assert_eq!(result[0].name_upper, "ALICE");
    assert_eq!(result[1].name_upper, "BOB");
}
```

```rust
// Pattern 3: Quality of Reasoning
// Checklist-based validation with builder pattern

struct ReasoningValidator {
    reasoning: String,
    issues: Vec<String>,
}

impl ReasoningValidator {
    fn new(reasoning: &str) -> Self {
        Self {
            reasoning: reasoning.to_lowercase(),
            issues: Vec::new(),
        }
    }

    fn requires_concepts(mut self, concepts: &[&str]) -> Self {
        for concept in concepts {
            if !self.reasoning.contains(&concept.to_lowercase()) {
                self.issues.push(format!("Missing concept: {}", concept));
            }
        }
        self
    }

    fn prohibits_fallacies(mut self) -> Self {
        let fallacies = vec![
            (r"\b(always|never|everyone)\b", "absolute language"),
            (r"\b(obviously|clearly)\b", "appeal to authority"),
        ];

        // Regex checking implementation...
        self
    }

    fn is_valid(&self) -> bool {
        self.issues.is_empty()
    }

    fn get_issues(&self) -> &[String] {
        &self.issues
    }
}

#[test]
fn test_refactoring_reasoning() {
    let reasoning = ai_explain_refactoring(&code_sample);

    let validator = ReasoningValidator::new(&reasoning)
        .requires_concepts(&["complexity", "maintainability", "testability"])
        .prohibits_fallacies();

    assert!(
        validator.is_valid(),
        "Reasoning issues: {:?}",
        validator.get_issues()
    );
}
```

```rust
// Pattern 4: Multiple Valid Paths
// Use HashSet for unordered collections

use std::collections::HashSet;

#[test]
fn test_unordered_tags() {
    let tags = ai_generate_tags(&article);
    let expected_tags: HashSet<_> = ["rust", "testing", "tdd"].iter().cloned().collect();

    let actual_tags: HashSet<_> = tags.iter().cloned().collect();

    assert_eq!(actual_tags, expected_tags);
}

#[test]
fn test_multiple_valid_algorithms() {
    let algorithm = ai_choose_sorting_algorithm(&data_characteristics);

    let valid_algorithms: HashSet<_> =
        ["quicksort", "mergesort", "heapsort"].iter().cloned().collect();

    assert!(
        valid_algorithms.contains(algorithm.as_str()),
        "Invalid algorithm: {}",
        algorithm
    );
}

// Property-based testing for Pattern 4
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_sort_behavior_any_algorithm(input in prop::collection::vec(any::<i32>(), 0..100)) {
        let algorithm = ai_choose_sorting_algorithm(&input);
        let result = sort_with_algorithm(&input, &algorithm);

        // Verify behavioral properties
        prop_assert_eq!(result.len(), input.len());
        prop_assert!(result.windows(2).all(|w| w[0] <= w[1]));
    }
}
```

**Key Rust Testing Patterns**:
- Use property-based testing (proptest) for behavioral correctness
- Leverage Rust's type system for compile-time guarantees
- Create custom assertion macros for reusable checks
- Use builder pattern for complex validators

---

### 4.5 Cross-Language Principles

**Common Patterns Across All Languages**:

1. **Semantic Similarity**: Always requires external library or API
   - Python: sentence-transformers, OpenAI API
   - JavaScript: TensorFlow.js, OpenAI API
   - Go/Rust: External API calls or Python integration

2. **Behavioral Correctness**: Focus on test structure, not language features
   - Test public interface only
   - Mock external dependencies
   - Verify side effects and state changes

3. **Quality of Reasoning**: Checklist-based validation is universal
   - Concept presence checking (string contains)
   - Fallacy pattern detection (regex)
   - Coherence validation (logical flow)

4. **Multiple Valid Paths**: Use set operations or enumeration
   - Python: `set()` operations
   - JavaScript: `Set()` class
   - Go: map-based comparison
   - Rust: `HashSet<T>`

**Integration Tips**:

- **CI/CD**: Run language-specific test suites in parallel
- **Coverage**: Aim for 80%+ coverage on critical paths
- **Documentation**: Document flexible assertion rationale in code comments
- **Review**: Require higher scrutiny for flexible assertions

---

---

## 5. Integration with RPTC TDD Workflow

**Status**: ✅ Completed in Step 6d

This section documents how flexible assertions integrate seamlessly with RPTC's Research → Plan → TDD → Commit workflow.

### 5.1 Planning Phase Integration (`/rptc:plan`)

When creating implementation plans that involve AI-generated outputs or non-deterministic code, specify the testing strategy upfront.

#### When to Identify Flexible Assertion Needs

During planning, flag features requiring flexible assertions if they involve:

1. **AI-Generated Content**
   - Text generation (summaries, descriptions, explanations)
   - Code documentation/comments
   - Error message composition
   - User-facing natural language output

2. **Non-Deterministic Behavior**
   - ML model predictions with acceptable variation
   - Randomized algorithms (if variation is acceptable)
   - Parallel processing with non-deterministic ordering

3. **Implementation Flexibility**
   - Algorithm choice not specified (multiple valid approaches)
   - Internal variable naming (behavior matters, names don't)
   - Code formatting/style (when not enforced by linter)

#### Plan Documentation Template

Add to your `.rptc/plans/feature-name.md` file:

```markdown
## Test Strategy

### Flexible Assertion Requirements

**Feature Component**: [e.g., AI-generated product descriptions]

**Variation Type**: [Semantic | Behavioral | Reasoning | Multiple Valid Paths]

**Pattern Selected**: Pattern [1-4] - [Pattern Name]

**Rationale**: [Why exact assertions won't work]
- Example: "AI generates product descriptions with valid synonym variations"
- Example: "Error messages use different phrasing but convey same meaning"

**Threshold**: [Specific acceptance criteria]
- Semantic similarity: >0.85 cosine similarity
- Behavioral: Input X → Output Y (ignore implementation details)
- Reasoning: Checklist: [key concept 1], [key concept 2], [logical coherence]
- Multiple paths: Accept any of [solution A, solution B, solution C]

**Safety Check**:
- [ ] NOT security-critical (authentication, authorization, sanitization)
- [ ] NOT external contract (API, file format, protocol)
- [ ] NOT performance-critical (SLA, benchmark)
- [ ] NOT regulatory/compliance requirement

**Baseline Exact Test**: [Describe at least one exact test for regression detection]
```

#### Example Plan Entry

```markdown
## Test Strategy

### Flexible Assertion Requirements

**Feature Component**: User notification message generation

**Variation Type**: Semantic

**Pattern Selected**: Pattern 1 - Semantic Similarity Evaluation

**Rationale**: AI generates notification messages with valid phrasing variations
- "Your order has been shipped" vs "We've shipped your order"
- Both convey identical information, exact match unnecessary

**Threshold**: Cosine similarity >0.88 (high confidence)

**Safety Check**:
- [x] NOT security-critical (no auth/validation logic)
- [x] NOT external contract (internal user notifications only)
- [x] NOT performance-critical (message generation <100ms acceptable)
- [x] NOT regulatory requirement

**Baseline Exact Test**:
- Test notification contains user ID (exact match)
- Test notification contains order number (exact match)
- Test notification semantic similarity >0.88 (flexible match)
```

---

### 5.2 TDD Phase Integration (`/rptc:tdd`)

Flexible assertions follow the standard RED-GREEN-REFACTOR cycle with additional documentation requirements.

#### RED Phase: Write Flexible Test First

**Template for Flexible Assertion Test**:

```python
def test_feature_with_flexible_assertion():
    """
    FLEXIBLE ASSERTION RATIONALE:
    - Why: [Reason variation is acceptable - reference plan section]
    - Pattern: [Pattern number and name from Section 3]
    - Threshold: [Specific acceptance criteria]
    - Baseline Exact: See test_feature_exact_baseline()
    - Failure Action: [What to do if test becomes flaky]
      Example: "Review prompt stability, check if similarity drops below 0.80"

    Plan Reference: .rptc/plans/[feature-name].md#test-strategy
    """
    # Arrange
    input_data = create_test_input()

    # Act
    actual_output = ai_generate_output(input_data)

    # Assert (Flexible)
    expected_output = "Expected semantic meaning here"
    similarity = semantic_similarity(actual_output, expected_output)
    assert similarity > 0.85, (
        f"Semantic similarity {similarity:.3f} below threshold 0.85. "
        f"Actual: {actual_output[:100]}... "
        f"Expected: {expected_output[:100]}..."
    )

    # Assert (Exact - for facts/data)
    assert actual_output.user_id == expected_user_id  # Extract facts, test exactly
```

**Required Components**:

1. **Docstring with rationale** - Must explain why flexibility needed
2. **Pattern reference** - Link to Section 3 pattern documentation
3. **Threshold specification** - Explicit acceptance criteria
4. **Baseline exact reference** - Point to companion exact test
5. **Failure action** - Guide for when test fails
6. **Plan reference** - Link to planning decision

#### GREEN Phase: Implement to Pass Flexible Threshold

**Focus on**:
- Meeting semantic/behavioral requirements (not exact output matching)
- Staying above threshold (don't game the test - if threshold is 0.85, don't aim for exactly 0.86)
- Validating facts separately with exact assertions

**Anti-Pattern Warning**:
```python
# ❌ BAD - Gaming the threshold
def generate_output(input_data):
    # Hard-codes output to barely pass similarity threshold
    return copy_expected_output_with_minor_variation()

# ✅ GOOD - Genuine implementation
def generate_output(input_data):
    # Implements actual logic, naturally produces variation
    return ai_model.generate(input_data, temperature=0.7)
```

#### REFACTOR Phase: Optimize Without Breaking Flexibility

During refactoring:
- **Maintain threshold passage** - Don't optimize in ways that reduce output quality
- **Monitor threshold margin** - If similarity drops from 0.95 to 0.86, investigate
- **Check baseline exact tests** - Ensure refactoring doesn't break regressions

**Health Check Command** (add to refactor checklist):
```bash
# Run tests with verbose output to see similarity scores
pytest -v --tb=short test_flexible_assertions.py

# Look for threshold proximity warnings (similarity close to minimum)
# Example: similarity=0.86 on threshold=0.85 → investigate quality degradation
```

---

### 5.3 Quality Gate Integration

RPTC's efficiency and security review agents provide specialized guidance on flexible assertions.

#### Efficiency Review Checklist

When reviewing code with flexible assertions, the Master Efficiency Agent checks:

- [ ] **Is flexibility justified?**
  - Could prompt engineering eliminate variation? (If yes, improve prompt first)
  - Is variation inherent to AI, or a quality issue masquerading as flexibility?
  - Does the plan document rationale clearly?

- [ ] **Is threshold appropriate?**
  - Too permissive (>0.70)? May accept low-quality outputs
  - Too strict (>0.95)? May reject valid variations unnecessarily
  - Recommended range: 0.85-0.92 for semantic similarity

- [ ] **Are baseline exact tests present?**
  - Critical paths MUST have at least one exact test
  - Flexible tests should complement, not replace, exact tests
  - Ratio check: Flexible tests should be <30% of total test suite

- [ ] **Is documentation complete?**
  - Every flexible assertion has rationale comment
  - Plan references flexible testing strategy
  - Thresholds explicitly documented (not magic numbers)

- [ ] **Does flexibility mask a quality problem?**
  - Test frequently fails then passes on retry → prompt instability issue
  - Threshold continuously drifts downward → quality degradation
  - Multiple developers question why test is flexible → reconsider necessity

**Efficiency Agent Guidance**:
> "Flexible assertions are precision tools for inherent non-determinism, not permission to write permissive tests. Default to exact assertions unless variation is proven necessary and acceptable."

#### Security Review Checklist

When reviewing code with flexible assertions, the Master Security Agent verifies:

- [ ] **No security-critical flexible assertions**
  - Authentication logic: Exact assertions only
  - Authorization checks: Exact assertions only
  - Input validation/sanitization: Exact assertions only
  - Cryptographic operations: Exact assertions only
  - Payment processing: Exact assertions only

- [ ] **API contracts use exact validation**
  - External API responses: Schema validation (exact structure)
  - File format generation: Exact format validation
  - Protocol compliance: Exact message structure

- [ ] **Compliance requirements use exact tests**
  - Financial calculations: Exact to required precision
  - Regulatory outputs: Exact matching of required fields
  - Audit logs: Exact format and required fields

- [ ] **Error handling remains strict**
  - Error types: Exact exception class checks
  - Critical error messages: Exact matching (security errors)
  - Non-critical error wording: Flexible allowed (UX messages)

**Security Agent Guidance**:
> "Security cannot be approximate. If a test validates anything security-critical, it MUST use exact assertions. When in doubt, default to exact."

---

### 5.4 Commit Phase Documentation (`/rptc:commit`)

Before committing code with flexible assertions, ensure documentation completeness.

#### Pre-Commit Checklist

- [ ] **Plan documentation updated**
  - `.rptc/plans/[feature].md` describes flexible assertion strategy
  - Rationale for flexibility documented in plan
  - Threshold selection explained

- [ ] **Test code includes rationale**
  - Every flexible assertion has docstring explaining why
  - Pattern reference included (Section 3.X reference)
  - Failure action documented

- [ ] **Baseline exact tests present**
  - Critical paths have at least one exact test
  - Baseline test referenced in flexible test docstring
  - Cross-reference comment: `# See test_feature_exact_baseline()`

- [ ] **Code review artifacts prepared**
  - Flexible assertions highlighted in PR description
  - Efficiency and security review completed
  - Test output showing threshold margins included

#### Commit Message Template

When committing code with flexible assertions:

```
feat(feature-name): implement [feature] with flexible assertions

- Implements [feature] using AI-generated [output type]
- Uses Pattern [X]: [Pattern Name] for test validation
- Threshold: [specific criteria, e.g., >0.85 cosine similarity]
- Baseline exact tests: [list test names]

Rationale for flexibility:
- AI generates [output type] with valid variations in [aspect]
- Exact assertions would reject [valid variation examples]
- Security review: ✅ Not security-critical
- Efficiency review: ✅ Flexibility justified, threshold appropriate

Plan reference: .rptc/plans/[feature-name].md#test-strategy
```

---

### 5.5 Workflow Integration Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ RPTC WORKFLOW WITH FLEXIBLE ASSERTIONS                          │
└─────────────────────────────────────────────────────────────────┘

/rptc:research (if needed)
  ↓
  Identify AI/non-deterministic components
  Document variation characteristics
  ↓
/rptc:plan
  ↓
  Specify flexible assertion needs in plan
  ├─ Variation type identified
  ├─ Pattern selected (1-4)
  ├─ Threshold defined
  ├─ Safety checks completed
  └─ Baseline exact tests planned
  ↓
/rptc:tdd
  ↓
  RED: Write flexible test with rationale
  │    └─ Includes: why, pattern, threshold, baseline ref, failure action
  ↓
  GREEN: Implement to meet threshold
  │      └─ Avoid gaming threshold, validate facts separately
  ↓
  REFACTOR: Optimize while maintaining quality
  │          └─ Monitor threshold margins, check baseline tests
  ↓
  Quality Gates:
  ├─ Efficiency Review
  │  ├─ Flexibility justified?
  │  ├─ Threshold appropriate?
  │  ├─ Baseline exact tests present?
  │  └─ Doesn't mask quality issues?
  │
  └─ Security Review
     ├─ No security-critical flexible assertions?
     ├─ API contracts exact?
     ├─ Compliance requirements exact?
     └─ Error handling strict?
  ↓
/rptc:commit
  ↓
  Documentation complete:
  ├─ Plan updated with strategy
  ├─ Test rationale documented
  ├─ Baseline exact tests present
  └─ Commit message explains flexibility
  ↓
✅ COMPLETE
```

---

### 5.6 RPTC Command References

**See Also**:
- **`/rptc:plan`** (`commands/plan.md`) - Planning phase integration, test strategy specification
- **`/rptc:tdd`** (`commands/tdd.md`) - TDD cycle execution, Phase 1d verification guidance
- **`/rptc:commit`** (`commands/commit.md`) - Documentation verification before commit
- **Master Efficiency Agent** (`agents/master-efficiency-agent.md`) - Quality review of flexible assertions
- **Master Security Agent** (`agents/master-security-agent.md`) - Security validation of test strategies

**SOPs**:
- **`testing-guide.md`** - Foundational TDD principles, test coverage requirements
- **`architecture-patterns.md`** - Code quality standards, documentation conventions

---

## 6. Safety Mechanisms & Anti-Patterns

### Philosophical Position

**Thesis**: Flexible assertions are a precision tool for handling inherent non-determinism in AI systems, **not** a quality compromise or excuse for permissive testing.

**When to Use**: Non-deterministic outputs where variation is acceptable and inherent (AI-generated text, implementation variations, reasoning explanations).

**When NOT to Use**: Security-critical operations, external contracts, performance SLAs, regulatory compliance, cryptographic operations.

### Core Principles

1. **Security First**: Authentication, authorization, input validation, and payment processing ALWAYS require exact assertions. No exceptions.

2. **Default to Exact**: Use exact assertions unless non-determinism is proven and acceptable. Flexibility is opt-in, not default.

3. **Document Everything**: Every flexible assertion MUST include a comment explaining:
   - **Why** flexibility is needed
   - **Which pattern** is used (1-4)
   - **What threshold** is considered acceptable
   - **What to do** if test becomes flaky

4. **Baseline Exact Tests Required**: Critical paths MUST have at least one exact test for regression detection, even if flexible tests also exist.

5. **Review with Scrutiny**: Flexible assertions require higher review scrutiny than exact assertions. Question whether flexibility is truly necessary.

---

### Danger Scenarios (Where Flexibility is PROHIBITED)

#### 1. Security-Critical String Matching

**Why Dangerous**: Security depends on exact validation. Flexibility creates vulnerabilities.

**Example - SQL Injection Prevention**:
```python
# ❌ DANGEROUS - Flexible assertion on security logic
def test_sql_sanitization_flexible():
    result = sanitize_sql("'; DROP TABLE users; --")
    assert "sanitized" in result  # Too permissive - accepts invalid sanitization
    assert len(result) > 5  # Meaningless check

# ✅ CORRECT - Exact assertion
def test_sql_sanitization_exact():
    result = sanitize_sql("'; DROP TABLE users; --")
    # Exact expected output after proper sanitization
    assert result == "' DROP TABLE users --"  # Quotes escaped, semicolon removed
```

**Rationale**: Security requires bit-perfect correctness. Approximate matches allow exploits.

---

#### 2. API Contracts and File Formats

**Why Dangerous**: External systems depend on exact formats. Variation breaks integrations.

**Example - CSV Generation**:
```python
# ❌ DANGEROUS - Flexible assertion on format
def test_csv_generation_flexible():
    csv = generate_csv(data)
    assert "id" in csv and "name" in csv  # Too permissive
    # Accepts: "id name\n1 John" (space-separated, not CSV)
    # Accepts: "id,name,extra_field\n1,John,X" (schema drift)

# ✅ CORRECT - Exact format validation
def test_csv_generation_exact():
    csv = generate_csv([{"id": 1, "name": "John"}, {"id": 2, "name": "Jane"}])
    expected = "id,name\n1,John\n2,Jane"
    assert csv == expected  # Exact format, no variations allowed
```

**Rationale**: File formats and API contracts are integration points. Flexibility causes interoperability failures.

---

#### 3. Performance Benchmarks and SLAs

**Why Dangerous**: Performance requirements are contractual. Flexibility hides regressions.

**Example - Response Time SLA**:
```python
# ❌ DANGEROUS - Overly permissive threshold
def test_api_performance_permissive():
    response_time = call_api()
    assert response_time < 5.0  # 5 seconds - way too permissive for web API
    # Hides performance degradation from 500ms → 3s

# ✅ CORRECT - Exact SLA-based threshold
def test_api_performance_sla():
    response_times = [call_api() for _ in range(100)]
    p95 = percentile(response_times, 95)
    assert p95 < 0.5  # 500ms p95 - contractual SLA
    # Catches regressions above SLA threshold
```

**Rationale**: Performance is measurable and contractual. Tests must enforce exact SLA thresholds.

---

#### 4. Regulatory Compliance Outputs

**Why Dangerous**: Legal and regulatory requirements demand exactness. Approximations violate compliance.

**Example - Tax Calculation (Financial)**:
```python
# ❌ DANGEROUS - Approximate financial calculation
def test_tax_calculation_approximate():
    tax = calculate_tax(income=100000)
    assert abs(tax - 25000) < 100  # ±$100 tolerance
    # Unacceptable for money - violates accounting standards

# ✅ CORRECT - Exact penny-perfect calculation
def test_tax_calculation_exact():
    tax = calculate_tax(income=100000)
    assert tax == 25000.00  # Exact to the penny
    # Required for tax reporting compliance
```

**Rationale**: Financial, medical, and legal systems require exact calculations. Approximations cause compliance violations.

---

#### 5. Cryptographic Operations

**Why Dangerous**: Cryptographic correctness requires bit-perfect outputs. Any variation indicates a critical bug.

**Example - Password Hashing**:
```python
# ❌ DANGEROUS - Weak validation on crypto
def test_password_hashing_weak():
    hashed = hash_password("test123")
    assert len(hashed) > 20  # Only checks length
    assert hashed.startswith("$2b$")  # Only checks prefix
    # Doesn't verify actual hash correctness

# ✅ CORRECT - Exact known-answer test
def test_password_hashing_exact():
    # Use fixed salt for deterministic testing
    hashed = hash_password("test123", salt="$2b$12$fixedsaltfixedsalt")
    expected = "$2b$12$fixedsaltfixedsaltexamplehashoutput"
    assert hashed == expected  # Exact hash verification
```

**Rationale**: Cryptographic operations must be deterministic (for same input+salt). Variation indicates implementation bug.

---

### Anti-Patterns to Prevent

#### Anti-Pattern 1: Using Flexibility to Mask Bad Prompts

**Problem**: Poor prompt engineering produces inconsistent outputs. Flexible assertions hide the root cause instead of fixing the prompt.

**Example**:
```python
# ❌ BAD - Flexible test hides prompt quality issue
def test_summary_generation_overly_flexible():
    """
    This test passes with 0.7 threshold, but outputs vary wildly:
    - "User has 5 orders" (correct)
    - "The user might have orders" (vague, incorrect)
    - "Orders: variable" (meaningless)
    All score >0.7 similarity, but quality is inconsistent.
    """
    summary = generate_summary(user)
    assert semantic_similarity(summary, "User has 5 orders") > 0.7

# ✅ GOOD - Fix prompt first, then test
def test_summary_generation_after_prompt_fix():
    """
    Prompt now includes: "State exact count of orders. Format: 'User has X orders'"
    Output is consistent. Use higher threshold.
    """
    summary = generate_summary_v2(user)  # Improved prompt
    assert semantic_similarity(summary, "User has 5 orders") > 0.90
```

**Solution**: If tests are flaky or passing with low thresholds, FIX THE PROMPT first. Constrain with examples, specify format, increase temperature precision. Only use flexible assertions for unavoidable variation.

---

#### Anti-Pattern 2: Skipping Error Condition Tests

**Problem**: Focusing on flexible happy-path tests while ignoring error cases entirely.

**Example**:
```python
# ❌ BAD - Only tests success case with flexibility
def test_api_call_success():
    result = call_external_api(valid_data)
    assert "success" in result  # Flexible check
    # Missing: What happens on network failure? Invalid data? Timeout?

# ✅ GOOD - Comprehensive test suite
def test_api_call_success():
    result = call_external_api(valid_data)
    assert result["status"] == "success"  # Exact for structured data

def test_api_call_network_error():
    with pytest.raises(NetworkError, match="Connection timeout"):
        call_external_api_with_network_failure()

def test_api_call_invalid_data():
    with pytest.raises(ValidationError, match="Missing required field: user_id"):
        call_external_api(invalid_data)
```

**Solution**: Error conditions ALWAYS require exact assertions (error types, critical error messages). Don't skip error testing just because happy path uses flexible assertions.

---

#### Anti-Pattern 3: Over-Reliance on Semantic Similarity

**Problem**: Using semantic similarity to validate factual data, hiding factual errors with "sounds right" passing tests.

**Example**:
```python
# ❌ BAD - Semantic similarity hides factual error
def test_user_order_count():
    summary = generate_summary(user)
    # Expected: "The user has 5 active orders"
    # Actual: "The user has several active orders"
    # Semantic similarity: 0.92 (HIGH)
    # Problem: "several" != 5 (factual error hidden)
    assert semantic_similarity(summary, "The user has 5 active orders") > 0.85

# ✅ GOOD - Separate style from facts
def test_user_order_count_facts():
    summary = generate_summary(user)
    # Extract facts with regex or parsing
    order_count = extract_number(summary, context="orders")
    assert order_count == 5  # EXACT assertion on facts

def test_user_order_count_style():
    summary = generate_summary(user)
    # Style/wording can vary
    assert "order" in summary.lower()
    assert "active" in summary.lower() or "current" in summary.lower()
```

**Solution**: Use semantic similarity for **style and wording**, exact assertions for **facts and data**. Extract factual claims and validate separately.

---

#### Anti-Pattern 4: No Baseline Exact Tests

**Problem**: Making ALL tests flexible, losing regression detection capability.

**Example**:
```python
# ❌ BAD - All tests are flexible
def test_discount_calculation_flexible_only():
    result = calculate_discount(100, 0.2)
    # Only flexible test - no exact baseline
    explanation = result.explanation
    assert semantic_similarity(explanation, "20% discount applied") > 0.80

# If calculate_discount breaks (returns wrong number), test might still pass
# because explanation is flexible.

# ✅ GOOD - Baseline exact + flexible supplement
def test_discount_calculation_exact_baseline():
    """Baseline regression test - MUST remain exact."""
    result = calculate_discount(100, 0.2)
    assert result.amount == 80.0  # Exact calculation check
    assert result.discount_rate == 0.2  # Exact rate check

def test_discount_calculation_explanation_flexible():
    """Flexible test for explanation text variations."""
    result = calculate_discount(100, 0.2)
    explanation = result.explanation
    assert semantic_similarity(explanation, "20% discount applied") > 0.85
```

**Solution**: Critical paths MUST have at least one exact test. Flexible tests are supplements, not replacements for regression detection.

---

#### Anti-Pattern 5: Undocumented Flexibility Rationale

**Problem**: Future developers encounter flexible tests and don't understand why flexibility was chosen. Leads to cargo-culting or incorrect modifications.

**Example**:
```python
# ❌ BAD - No explanation for flexibility
def test_generate_report():
    report = generate_report()
    assert semantic_similarity(report, expected_report) > 0.80
    # Why 0.80? Why semantic similarity? When is this test actually failing?
    # Developers don't know.

# ✅ GOOD - Documented rationale
def test_generate_report():
    """
    FLEXIBLE ASSERTION RATIONALE:

    WHY FLEXIBLE:
    - Report is AI-generated with phrasing variations
    - Exact wording not specified in requirements
    - Semantic meaning must be preserved

    PATTERN USED: Semantic Similarity (Pattern 1)

    THRESHOLD: >0.80 cosine similarity
    - Based on: Pilot testing with 100 generated reports
    - 0.80 captures all valid variations while rejecting hallucinations

    FAILURE ACTION:
    - If test becomes flaky (intermittent failures):
      1. Review recent prompt changes
      2. Check if new valid variation emerged (update expected)
      3. If neither, indicates prompt quality degradation → fix prompt

    BASELINE EXACT TEST: test_report_contains_required_sections() validates structure
    """
    report = generate_report(data)
    expected = "Sales increased 15% in Q4 due to holiday promotions."
    assert semantic_similarity(report, expected) > 0.80
```

**Solution**: ALWAYS document:
- **Why** flexibility is needed (non-determinism source)
- **Which pattern** is used (1-4)
- **Threshold justification** (how was it chosen?)
- **Failure action plan** (what to do when test fails)
- **Reference to baseline exact test** (if exists)

---

### Enforcement Mechanisms

#### 1. Explicit Threshold Definition

**Requirement**: Every flexible assertion MUST define explicit acceptance criteria. No vague "similar enough" checks.

**Template**:
```python
# ✅ GOOD - Explicit threshold
assert cosine_similarity(actual, expected) > 0.85  # Clear numeric threshold

# ❌ BAD - Vague criteria
assert is_similar_enough(actual, expected)  # What does "enough" mean?
```

**Rationale**: Explicit thresholds are reviewable, testable, and tunable. Vague criteria hide quality issues.

---

#### 2. Mandatory Baseline Exact Tests

**Requirement**: Critical paths MUST include at least one exact test, even if flexible tests supplement it.

**Pattern**:
```python
def test_critical_feature_exact_baseline():
    """
    BASELINE REGRESSION TEST - DO NOT MAKE FLEXIBLE
    This test catches breaking changes to core behavior.
    """
    result = critical_function(standard_input)
    assert result == expected_exact_output

def test_critical_feature_flexible_variations():
    """
    FLEXIBLE SUPPLEMENT - Tests acceptable variations.
    Depends on baseline test above for regression detection.
    """
    result = critical_function(standard_input)
    assert flexible_check(result, acceptable_variations)
```

**Rationale**: Flexible tests alone provide false confidence. Exact baseline catches regressions.

---

#### 3. Documented Rationale Requirement

**Requirement**: Every flexible assertion MUST include a docstring or comment explaining the flexibility decision.

**Template**:
```python
def test_with_flexible_assertion():
    """
    FLEXIBLE ASSERTION RATIONALE:

    - Why: [Explain source of non-determinism]
    - Pattern: [Semantic Similarity / Behavioral Correctness / Quality of Reasoning / Multiple Valid Paths]
    - Threshold: [Specific acceptance criteria and how it was determined]
    - Failure Action: [What to do if test becomes flaky or starts failing]
    - Baseline: [Reference to exact test if exists, or "N/A - no baseline needed"]
    """
    # Test implementation
    ...
```

**Rationale**: Documentation prevents cargo-culting and enables informed future modifications.

---

#### 4. Higher Review Scrutiny

**Requirement**: Code reviews MUST specifically evaluate flexible assertions with this checklist:

**Flexible Assertion Review Checklist**:
- [ ] **Is flexibility truly necessary?** Could an exact assertion work instead?
- [ ] **Is threshold appropriate?** Not too permissive (false positives) or too strict (flakiness)?
- [ ] **Is rationale documented?** Clear explanation of why, which pattern, threshold justification?
- [ ] **Is baseline exact test present?** For critical paths, is there regression detection?
- [ ] **Does this mask a prompt quality issue?** Could prompt be improved to reduce variation?
- [ ] **Is this security-critical?** If yes, REJECT - must use exact assertions
- [ ] **Are error conditions still exact?** Error types and critical messages must remain exact
- [ ] **Is threshold data-driven?** Based on pilot testing, not guesswork?

**Rationale**: Flexible assertions require careful scrutiny to prevent quality erosion. Reviewers must actively question flexibility decisions.

---

### When to Reject Flexible Assertions (Review Guidance)

**REJECT if**:
- Security-critical operations (auth, validation, sanitization, crypto)
- External contracts (APIs, file formats, protocols)
- Performance SLAs (response times, benchmarks)
- Regulatory compliance (finance, healthcare, legal)
- No documented rationale provided
- Exact assertion would work equally well
- Masks a prompt quality issue that should be fixed instead
- No baseline exact test for critical path
- Threshold appears arbitrary (not data-driven)

**APPROVE if**:
- Non-determinism is inherent and proven (not prompt-induced)
- Threshold is data-driven (based on pilot testing or research)
- Rationale clearly documents why flexibility needed
- Pattern choice (1-4) is appropriate for variation type
- Baseline exact tests exist for critical paths
- Error conditions remain exact
- Not security, compliance, or contract-critical
- Reviewer understands and agrees with flexibility justification

---

## 7. Practical Decision Trees

**Status**: ✅ Completed in Step 6d

This section provides visual flowcharts and practical decision aids for choosing the right assertion strategy.

### 7.1 Master Decision Flowchart

Use this flowchart to determine whether to use exact or flexible assertions for a given test:

```
┌─────────────────────────────────────────────────────────────────┐
│ START: Choosing Assertion Strategy                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ CRITICAL SAFETY CHECK                                           │
│ Is this ANY of the following?                                   │
│                                                                  │
│ • Security-critical (auth, validation, sanitization)            │
│ • API contract / file format (external integration)             │
│ • Performance SLA (timing, memory benchmarks)                   │
│ • Regulatory compliance (finance, healthcare, legal)            │
│ • Cryptographic operation (hashing, encryption)                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────┴─────────┐
                   YES                   NO
                    │                     │
                    ↓                     ↓
         ┌──────────────────┐   ┌──────────────────────┐
         │ USE EXACT        │   │ Continue to          │
         │ ASSERTIONS       │   │ Determinism Check    │
         │                  │   └──────────────────────┘
         │ No exceptions.   │             │
         │ Security cannot  │             ↓
         │ be approximate.  │   ┌──────────────────────┐
         └──────────────────┘   │ Is output            │
                                │ deterministic?       │
                                │                      │
                                │ (Same input →        │
                                │  Same output)        │
                                └──────────────────────┘
                                          ↓
                              ┌───────────┴───────────┐
                             YES                      NO
                              │                        │
                              ↓                        ↓
                   ┌──────────────────┐     ┌──────────────────────┐
                   │ USE EXACT        │     │ Is variation         │
                   │ ASSERTIONS       │     │ acceptable?          │
                   │                  │     │                      │
                   │ Preferred for    │     │ (Multiple valid      │
                   │ deterministic    │     │  outputs OK)         │
                   │ code.            │     └──────────────────────┘
                   └──────────────────┘               ↓
                                           ┌──────────┴──────────┐
                                          YES                    NO
                                           │                      │
                                           ↓                      ↓
                              ┌──────────────────────┐ ┌────────────────────┐
                              │ What type of         │ │ REDESIGN for       │
                              │ variation?           │ │ Determinism        │
                              │                      │ │                    │
                              │ Choose pattern:      │ │ • Use fixed seed   │
                              └──────────────────────┘ │ • Remove randomness│
                                          ↓            │ • Constrain prompt │
                     ┌────────────────────┼────────────────────┐ └──────────┘
                     │                    │                    │
                     ↓                    ↓                    ↓
         ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
         │ SEMANTIC         │ │ BEHAVIORAL       │ │ REASONING        │
         │ (wording, style) │ │ (implementation) │ │ (explanation)    │
         └──────────────────┘ └──────────────────┘ └──────────────────┘
                 │                     │                     │
                 ↓                     ↓                     ↓
         Pattern 1:          Pattern 2:          Pattern 3:
         Semantic            Behavioral          Quality of
         Similarity          Correctness         Reasoning
         (>0.85 cosine)      (input→output)      (checklist)
                 │                     │                     │
                 └─────────────────────┴─────────────────────┘
                                       ↓
                      ┌──────────────────────────────┐
                      │ MULTIPLE VALID PATHS         │
                      │ (enumerable solutions)       │
                      └──────────────────────────────┘
                                       ↓
                               Pattern 4:
                          Multiple Valid Solution
                         (accept any from set)
                                       ↓
                      ┌──────────────────────────────┐
                      │ IMPLEMENT WITH:              │
                      │ • Documented rationale       │
                      │ • Explicit threshold         │
                      │ • Baseline exact tests       │
                      │ • Plan reference             │
                      └──────────────────────────────┘
                                       ↓
                                   ✅ DONE
```

---

### 7.2 Pattern Selection Matrix

Quick reference table for choosing the right flexible assertion pattern:

| **Variation Type** | **Pattern** | **Threshold Example** | **Use When** | **Don't Use When** |
|-------------------|-------------|----------------------|--------------|-------------------|
| **Semantic** (wording, formatting, synonyms) | Pattern 1: Semantic Similarity | Cosine similarity >0.85 | • AI-generated text<br>• Comments/docs<br>• Error messages<br>• Markdown variations | • Facts/data present<br>• Legal/compliance text<br>• Security messages |
| **Behavioral** (variable names, algorithm choice) | Pattern 2: Behavioral Correctness | Input X → Output Y (black box) | • Implementation flexibility<br>• Internal naming<br>• Algorithm variations | • External interfaces<br>• API contracts<br>• File formats |
| **Reasoning** (explanation quality, logic) | Pattern 3: Quality of Reasoning | Checklist: 3/3 criteria met | • AI explanations<br>• Justifications<br>• Decision rationale | • Factual accuracy required<br>• Regulatory docs |
| **Multiple Paths** (enumerable valid solutions) | Pattern 4: Multiple Valid Solutions | Output ∈ {A, B, C} | • Order doesn't matter<br>• Multiple correct algorithms<br>• API response supersets | • Single correct solution<br>• Performance-critical path choice |

---

### 7.3 Common Scenario Quick Reference

#### JavaScript/TypeScript (Jest)

| **Scenario** | **Exact or Flexible?** | **Pattern (if flexible)** | **Code Example** |
|-------------|----------------------|--------------------------|------------------|
| API response exact structure | Exact | N/A | `expect(response).toMatchObject({id: 123, name: "test"})` |
| AI-generated user message | Flexible | Pattern 1 | `expect(semanticSim(msg, expected)).toBeGreaterThan(0.85)` |
| Function returns correct calculation | Exact | N/A | `expect(calculateTotal(items)).toBe(150.00)` |
| Implementation uses either Map or Object | Flexible | Pattern 2 | `expect(result.get(key) OR result[key]).toBe(value)` |
| Error type must be ValidationError | Exact | N/A | `expect(() => fn()).toThrow(ValidationError)` |
| Error message wording | Flexible | Pattern 1 | `expect(semanticSim(e.message, expected)).toBeGreaterThan(0.85)` |

#### Python (pytest)

| **Scenario** | **Exact or Flexible?** | **Pattern (if flexible)** | **Code Example** |
|-------------|----------------------|--------------------------|------------------|
| Database query returns correct ID | Exact | N/A | `assert user.id == 42` |
| AI-generated docstring | Flexible | Pattern 1 | `assert semantic_similarity(doc, expected) > 0.85` |
| Function calculates tax correctly | Exact | N/A | `assert calculate_tax(100) == 25.00` |
| Variable naming (behavior matters) | Flexible | Pattern 2 | Test output, not variable names |
| Authentication token validation | Exact | N/A | `assert validate_token(token) == True` |
| Log message contains key info | Flexible | Pattern 3 | `assert all(x in log for x in ["user", "action", "timestamp"])` |

#### Java (JUnit 5)

| **Scenario** | **Exact or Flexible?** | **Pattern (if flexible)** | **Code Example** |
|-------------|----------------------|--------------------------|------------------|
| Service returns correct status code | Exact | N/A | `assertEquals(200, response.getStatusCode())` |
| AI-generated Javadoc | Flexible | Pattern 1 | `assertTrue(semanticSimilarity(doc, expected) > 0.85)` |
| Payment amount exact to cent | Exact | N/A | `assertEquals(new BigDecimal("99.99"), total)` |
| Collection can be List or Set | Flexible | Pattern 4 | `assertTrue(validTypes.contains(result.getClass()))` |
| Exception must be IllegalArgumentException | Exact | N/A | `assertThrows(IllegalArgumentException.class, () -> fn())` |
| Exception message describes problem | Flexible | Pattern 1 | `assertTrue(semanticSimilarity(e.getMessage(), expected) > 0.80)` |

---

### 7.4 Integration Checklist

Use this checklist when adding flexible assertions to your RPTC workflow:

#### Planning Phase (`/rptc:plan`)

- [ ] **Identify** non-deterministic outputs in feature requirements
- [ ] **Document** variation type (semantic, behavioral, reasoning, multiple paths)
- [ ] **Select** appropriate pattern (1-4) based on variation type
- [ ] **Define** explicit threshold/acceptance criteria
- [ ] **Complete** safety check (not security/compliance/contract-critical)
- [ ] **Plan** at least one baseline exact test for critical path
- [ ] **Add** flexible assertion section to `.rptc/plans/[feature].md`

#### TDD Phase (`/rptc:tdd`)

- [ ] **RED**: Write flexible test with complete rationale docstring
  - [ ] Include "why" (reason for flexibility)
  - [ ] Include pattern reference (Section 3.X)
  - [ ] Include threshold specification
  - [ ] Include baseline exact test reference
  - [ ] Include failure action guidance
  - [ ] Include plan reference link
- [ ] **GREEN**: Implement to genuinely meet threshold (don't game it)
  - [ ] Verify facts separately with exact assertions
  - [ ] Avoid hard-coding to barely pass threshold
- [ ] **REFACTOR**: Monitor threshold margins during optimization
  - [ ] Check that similarity doesn't drop significantly
  - [ ] Verify baseline exact tests still pass

#### Quality Gate Phase

- [ ] **Efficiency Review**: Complete efficiency checklist (Section 5.3)
  - [ ] Flexibility justified (not masking quality issue)
  - [ ] Threshold appropriate (0.85-0.92 recommended)
  - [ ] Baseline exact tests present
  - [ ] Documentation complete
- [ ] **Security Review**: Complete security checklist (Section 5.3)
  - [ ] No security-critical flexible assertions
  - [ ] API contracts use exact validation
  - [ ] Compliance requirements exact
  - [ ] Error handling strict where needed

#### Commit Phase (`/rptc:commit`)

- [ ] **Plan** updated with flexible assertion strategy
- [ ] **Tests** include rationale in docstrings
- [ ] **Baseline** exact tests present and documented
- [ ] **Commit message** explains flexible assertion usage
- [ ] **PR description** highlights flexible assertions for review

---

### 7.5 Threshold Selection Guide

Choosing the right threshold for semantic similarity (Pattern 1):

| **Threshold Range** | **Meaning** | **Use When** | **Risk** |
|-------------------|------------|--------------|----------|
| **>0.95** | Near-identical | Minimal acceptable variation (e.g., capitalization only) | May reject valid variations |
| **>0.90** | Very high similarity | Synonyms OK, structure same (e.g., "calculate" vs "compute") | Balanced - recommended starting point |
| **>0.85** | High similarity | Rephrasing OK, meaning preserved (e.g., active vs passive voice) | **RECOMMENDED DEFAULT** |
| **>0.80** | Medium-high similarity | Moderate rephrasing (e.g., sentence restructuring OK) | Borderline - validate carefully |
| **>0.75** | Medium similarity | Significant rephrasing (e.g., different explanation approach) | May accept low-quality outputs |
| **<0.75** | Low similarity | ⚠️ **DANGER ZONE** - May accept incorrect content | **NOT RECOMMENDED** |

**Calibration Process**:
1. Run test with known good outputs
2. Measure actual similarity scores (collect 10+ samples)
3. Set threshold at 10th percentile - 0.05 (safety margin)
4. Example: If 10 good outputs range 0.88-0.96, set threshold >0.83 (0.88 - 0.05)

---

### 7.6 Troubleshooting Decision Tree

When a flexible assertion test fails:

```
┌─────────────────────────────────────────────────────────────────┐
│ Flexible Assertion Test Failed                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────────┐
                    │ Is output valid?    │
                    │ (Human review)      │
                    └─────────────────────┘
                              ↓
                    ┌─────────┴─────────┐
                   YES                   NO
                    │                     │
                    ↓                     ↓
         ┌──────────────────┐   ┌──────────────────┐
         │ Threshold too     │   │ Is error in      │
         │ strict            │   │ implementation?  │
         │                  │   └──────────────────┘
         │ → Lower threshold│             ↓
         │   by 0.02-0.05   │   ┌─────────┴─────────┐
         │                  │  YES                   NO
         │ → Document       │   │                     │
         │   rationale      │   ↓                     ↓
         └──────────────────┘ ┌────────────┐ ┌──────────────────┐
                              │ FIX CODE   │ │ Is prompt        │
                              │            │ │ unstable?        │
                              │ Run tests  │ │ (flaky output)   │
                              │ again      │ └──────────────────┘
                              └────────────┘          ↓
                                           ┌──────────┴──────────┐
                                          YES                    NO
                                           │                      │
                                           ↓                      ↓
                              ┌──────────────────┐  ┌──────────────────┐
                              │ FIX PROMPT       │  │ RECONSIDER       │
                              │                  │  │ FLEXIBILITY      │
                              │ • Add examples   │  │                  │
                              │ • Constrain      │  │ Maybe exact      │
                              │   format         │  │ assertion is     │
                              │ • Reduce temp    │  │ needed instead   │
                              └──────────────────┘  └──────────────────┘
```

---

### 7.7 Anti-Pattern Detection Checklist

Review your flexible assertions against these anti-patterns:

| **Anti-Pattern** | **Detection** | **Fix** |
|-----------------|--------------|--------|
| **Masking Bad Prompts** | Test fails frequently, passes on retry | Improve prompt quality first, THEN apply flexibility |
| **Skipping Error Tests** | Only happy path uses flexible assertions | Add exact assertions for error conditions |
| **Over-Reliance on Similarity** | >50% of tests are flexible | Convert some back to exact, focus flexibility on truly variable outputs |
| **No Baseline Exact Tests** | Critical path has zero exact tests | Add at least one exact test for regression detection |
| **Undocumented Rationale** | Flexible test lacks docstring | Add complete rationale (why, pattern, threshold, failure action) |
| **Security Flexibility** | Auth/validation uses flexible assertions | **CRITICAL**: Change to exact assertions immediately |
| **Threshold Gaming** | Implementation tweaked to barely pass threshold | Refactor to genuinely solve problem, not game test |

---

### 7.8 Language-Specific Pattern Examples

#### Pattern Selection by Language Ecosystem

**JavaScript/TypeScript (Jest)**:
- **Most Common**: Pattern 1 (Semantic Similarity) for UX messages, React component text
- **Second Most**: Pattern 4 (Multiple Valid Paths) for React re-render scenarios
- **Least Common**: Pattern 3 (Quality of Reasoning) - usually exact for frontend

**Python (pytest)**:
- **Most Common**: Pattern 1 (Semantic Similarity) for AI/ML outputs, docstrings
- **Second Most**: Pattern 2 (Behavioral Correctness) for algorithm variations
- **Third Most**: Pattern 3 (Quality of Reasoning) for scientific/research outputs

**Java (JUnit)**:
- **Most Common**: Pattern 2 (Behavioral Correctness) for enterprise service variations
- **Second Most**: Pattern 4 (Multiple Valid Paths) for collection type flexibility
- **Least Common**: Pattern 1 (Semantic Similarity) - Java culture prefers exact

**Go (testing)**:
- **Most Common**: Pattern 2 (Behavioral Correctness) for interface implementations
- **Second Most**: Pattern 4 (Multiple Valid Paths) for concurrent execution order
- **Rare**: Pattern 1 (Semantic Similarity) - Go culture values exactness

---

### 7.9 Quick Decision Reference Card

Print or bookmark this quick reference:

```
┌─────────────────────────────────────────────────────────────┐
│ FLEXIBLE ASSERTION QUICK DECISION CARD                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ 🔴 ALWAYS EXACT:                                            │
│   • Security (auth, validation, sanitization)               │
│   • API contracts / file formats                            │
│   • Performance benchmarks                                  │
│   • Regulatory compliance                                   │
│   • Cryptographic operations                                │
│                                                              │
│ 🟢 FLEXIBLE ALLOWED (with rationale):                       │
│   • AI-generated text → Pattern 1 (>0.85 similarity)        │
│   • Variable naming → Pattern 2 (behavior test)             │
│   • AI explanations → Pattern 3 (checklist)                 │
│   • Multiple algorithms → Pattern 4 (accept any valid)      │
│                                                              │
│ ⚠️ REQUIRED FOR FLEXIBLE:                                   │
│   ✓ Documented rationale (why, pattern, threshold)          │
│   ✓ Baseline exact test for critical path                   │
│   ✓ Safety check complete (not security/compliance)         │
│   ✓ Plan references flexible strategy                       │
│                                                              │
│ 📊 THRESHOLD GUIDE (Pattern 1):                             │
│   >0.90 = Very similar (synonyms OK)                        │
│   >0.85 = Similar (rephrasing OK) ← RECOMMENDED            │
│   >0.80 = Moderate (restructuring OK)                       │
│   <0.75 = Too permissive (AVOID)                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Appendix: Version History

**v2.0.0 (2025-01-25)**: Complete Flexible Assertions SOP

**Step 6a (Framework)**: Initial framework creation
- Section 1: Core Problem Statement ✅
- Section 2: When to Use Flexible vs Exact Assertions ✅
- Section 6: Safety Mechanisms & Anti-Patterns ✅

**Step 6b (Patterns 1-2)**: First pattern implementations
- Section 3.1: Pattern 1 - Semantic Similarity Evaluation ✅
- Section 3.2: Pattern 2 - Behavioral Correctness Assessment ✅

**Step 6c (Patterns 3-4 + Examples)**: Remaining patterns and language examples
- Section 3.3: Pattern 3 - Quality of Reasoning Verification ✅
- Section 3.4: Pattern 4 - Multiple Valid Solution Path Support ✅
- Section 4: Language-Specific Examples (Python, JavaScript, Java) ✅

**Step 6d (Integration + Finalization)**: RPTC workflow integration and decision aids
- Section 5: Integration with RPTC TDD Workflow ✅
  - Planning phase integration
  - TDD phase (RED-GREEN-REFACTOR)
  - Quality gate integration (efficiency + security)
  - Commit phase documentation
  - Workflow diagram
  - RPTC command cross-references
- Section 7: Practical Decision Trees ✅
  - Master decision flowchart
  - Pattern selection matrix
  - Common scenario quick reference (3 languages)
  - Integration checklist
  - Threshold selection guide
  - Troubleshooting decision tree
  - Anti-pattern detection checklist
  - Language-specific pattern preferences
  - Quick decision reference card

**Total Content**:
- 4,519 lines
- 7 major sections (all complete)
- 4 flexible assertion patterns fully documented
- 3 language implementations (Python, JavaScript, Java)
- 9 practical decision aids and reference tables
- Complete RPTC workflow integration

---

_Flexible Testing Guide completed across Steps 6a-6d_
_Ready for production use in RPTC v2.0.0_

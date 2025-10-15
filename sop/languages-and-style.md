# Languages and Style Guide

Comprehensive language-specific conventions, style guides, formatters, and linters.

## Language Style Guides

### JavaScript/TypeScript

**Style Guide**: Airbnb or Standard (specify in project `.context/`)
**Formatter**: Prettier
**Linter**: ESLint
**Type Checker**: TypeScript (tsc)

**Conventions**:

- Single quotes for strings
- Semicolons (if using Airbnb)
- Trailing commas in multi-line structures
- 2-space indentation
- Arrow functions preferred for callbacks
- Destructuring where appropriate
- Template literals for string interpolation

**Type Annotations**:

```typescript
// Always use explicit return types for functions
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Use interfaces for object shapes
interface User {
  id: string;
  name: string;
  email: string;
}
```

**Validation Libraries**: Zod, Joi, Yup

### Python

**Style Guide**: PEP 8
**Formatter**: Black
**Linter**: Pylint, Flake8, Ruff
**Type Checker**: mypy

**Conventions**:

- Double quotes for strings
- 4-space indentation
- snake_case for functions and variables
- PascalCase for classes
- SCREAMING_SNAKE_CASE for constants
- Type hints on all function signatures

**Type Annotations**:

```python
from typing import List, Optional, Dict

def process_users(users: List[Dict[str, str]]) -> Optional[str]:
    """Process user data and return summary.

    Args:
        users: List of user dictionaries

    Returns:
        Summary string or None if empty
    """
    if not users:
        return None
    return f"Processed {len(users)} users"
```

**Validation Libraries**: Pydantic, Marshmallow, dataclasses with validation

### Java

**Style Guide**: Google Java Style Guide
**Formatter**: Google Java Format
**Linter**: Checkstyle, SpotBugs
**Build Tools**: Maven, Gradle

**Conventions**:

- 2-space indentation
- camelCase for methods and variables
- PascalCase for classes
- SCREAMING_SNAKE_CASE for constants
- Braces on same line
- Comprehensive Javadoc for public APIs

### C#/.NET

**Style Guide**: Microsoft C# Coding Conventions
**Formatter**: dotnet format
**Linter**: StyleCop, Roslyn Analyzers
**Build Tool**: dotnet CLI

**Conventions**:

- PascalCase for public members
- camelCase for private fields (with underscore prefix)
- 4-space indentation
- Braces on new line (Allman style)
- XML documentation comments

### Go

**Style Guide**: Effective Go
**Formatter**: gofmt, goimports
**Linter**: golangci-lint
**Build Tool**: go modules

**Conventions**:

- Tabs for indentation
- camelCase for exported identifiers
- Short variable names in small scopes
- Error handling: return errors, don't panic
- Interfaces: small and focused

### Rust

**Style Guide**: Rust Style Guide
**Formatter**: rustfmt
**Linter**: clippy
**Build Tool**: Cargo

**Conventions**:

- snake_case for functions, variables, modules
- PascalCase for types, traits
- SCREAMING_SNAKE_CASE for constants
- 4-space indentation
- Result type for error handling
- Ownership and borrowing patterns

### Ruby

**Style Guide**: Ruby Style Guide (community)
**Formatter**: RuboCop (with auto-correct)
**Linter**: RuboCop
**Package Manager**: Bundler

**Conventions**:

- 2-space indentation
- snake_case for methods and variables
- PascalCase for classes and modules
- Use symbols over strings for hash keys
- Prefer `unless` over `if !`

### PHP

**Style Guide**: PSR-12
**Formatter**: PHP-CS-Fixer
**Linter**: PHP_CodeSniffer
**Package Manager**: Composer

**Conventions**:

- 4-space indentation
- camelCase for methods
- PascalCase for classes
- snake_case for database columns
- Type declarations on all functions (PHP 7.4+)

## Documentation Standards

### JSDoc (JavaScript/TypeScript)

```javascript
/**
 * Calculate the total price including tax
 * @param {number} price - Base price
 * @param {number} taxRate - Tax rate as decimal (e.g., 0.08)
 * @returns {number} Total price with tax
 * @throws {Error} If price or taxRate is negative
 * @example
 * calculateTotalPrice(100, 0.08) // returns 108
 */
function calculateTotalPrice(price, taxRate) {
  if (price < 0 || taxRate < 0) {
    throw new Error("Price and tax rate must be non-negative");
  }
  return price * (1 + taxRate);
}
```

### Python Docstrings (Google Style)

```python
def calculate_total_price(price: float, tax_rate: float) -> float:
    """Calculate the total price including tax.

    Args:
        price: Base price in dollars
        tax_rate: Tax rate as decimal (e.g., 0.08)

    Returns:
        Total price with tax applied

    Raises:
        ValueError: If price or tax_rate is negative

    Example:
        >>> calculate_total_price(100, 0.08)
        108.0
    """
    if price < 0 or tax_rate < 0:
        raise ValueError("Price and tax rate must be non-negative")
    return price * (1 + tax_rate)
```

### Javadoc (Java)

```java
/**
 * Calculate the total price including tax
 *
 * @param price Base price
 * @param taxRate Tax rate as decimal (e.g., 0.08)
 * @return Total price with tax
 * @throws IllegalArgumentException if price or taxRate is negative
 *
 * @example
 * <pre>
 * double total = calculateTotalPrice(100.0, 0.08); // returns 108.0
 * </pre>
 */
public double calculateTotalPrice(double price, double taxRate) {
    if (price < 0 || taxRate < 0) {
        throw new IllegalArgumentException("Price and tax rate must be non-negative");
    }
    return price * (1 + taxRate);
}
```

## Package Management

### Development Environment Setup

| Language      | Package Manager | Virtual Environment | Version Manager |
| ------------- | --------------- | ------------------- | --------------- |
| JavaScript/TS | npm, yarn, pnpm | N/A                 | nvm, volta      |
| Python        | pip, poetry, uv | venv, virtualenv    | pyenv           |
| Java          | Maven, Gradle   | N/A                 | SDKMAN!         |
| C#/.NET       | NuGet           | N/A                 | dotnet CLI      |
| Go            | Go modules      | N/A                 | go env          |
| Rust          | Cargo           | N/A                 | rustup          |
| Ruby          | Bundler         | N/A                 | rbenv, rvm      |
| PHP           | Composer        | N/A                 | phpenv          |

### Standard Commands

```bash
# Install dependencies
npm install              # JavaScript
pip install -r requirements.txt   # Python
mvn install             # Java (Maven)
dotnet restore          # C#
go mod download         # Go
cargo build             # Rust
bundle install          # Ruby
composer install        # PHP

# Add dependencies
npm add package-name
pip install package-name
mvn dependency:get -DgroupId=... -DartifactId=...
dotnet add package PackageName
go get package-path
cargo add package-name
bundle add gem-name
composer require vendor/package

# Development dependencies
npm add --save-dev package-name
pip install --dev package-name
# (varies by language/tool)
```

## Pre-commit Hooks

Install and configure pre-commit for automated checks:

```bash
# Install pre-commit
pip install pre-commit

# .pre-commit-config.yaml example
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## Validation Libraries

### JavaScript/TypeScript

- **Zod**: Runtime validation with TypeScript inference
- **Joi**: Schema validation
- **Yup**: Schema validation with async support
- **class-validator**: Decorator-based validation

### Python

- **Pydantic**: Data validation using Python type hints
- **Marshmallow**: Object serialization and validation
- **Cerberus**: Lightweight validation
- **jsonschema**: JSON Schema validation

### Java

- **Bean Validation (JSR 380)**: Standard validation framework
- **Hibernate Validator**: Reference implementation
- **Apache Commons Validator**: Common validation routines

### Other Languages

- C#: FluentValidation, DataAnnotations
- Go: validator/v10, ozzo-validation
- Rust: validator crate
- Ruby: ActiveModel::Validations, dry-validation
- PHP: Symfony Validator, Respect\Validation

## Code Quality Tools

### Static Analysis

- **SonarQube**: Multi-language code quality and security
- **CodeClimate**: Automated code review
- **Codacy**: Automated code analysis

### Language-Specific

- **JavaScript/TS**: ESLint, TSLint (deprecated), SonarJS
- **Python**: Pylint, Flake8, Bandit (security), mypy (types)
- **Java**: PMD, FindBugs, Checkstyle, SpotBugs
- **C#**: StyleCop, FxCop, Roslyn Analyzers
- **Go**: golangci-lint (aggregates multiple linters)
- **Rust**: clippy (official linter)

### Complexity Metrics

- **Cyclomatic Complexity**: Aim for <10 per function
- **Cognitive Complexity**: Measure code understandability
- **Maintainability Index**: Overall code maintainability score

Tools: radon (Python), complexity-report (JS), CodeMR (Java)

## Editor Configuration

Use `.editorconfig` for consistent formatting across editors:

```ini
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,jsx,ts,tsx,json}]
indent_style = space
indent_size = 2

[*.{py}]
indent_style = space
indent_size = 4

[*.{java,cs}]
indent_style = space
indent_size = 4

[*.{go}]
indent_style = tab
indent_size = 4

[*.{md,markdown}]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

## Project-Specific Overrides

Document any deviations from these standards in `.context/style-overrides.md` with rationale.

Example overrides:

- "Using 4-space indent for JavaScript (team preference)"
- "Skipping type hints in data science notebooks (exploratory code)"
- "Using tabs instead of spaces for Python (legacy codebase)"

# Git Workflow and Deployment

## Branching Strategies

### Git Flow (Release-Based Projects)

```text
main (production) ← hotfix/*, release/*
develop (integration) ← feature/*, fix/*
```

**Branches**:

- **main**: Production code, tagged with versions
- **develop**: Integration for next release
- **feature/\***: New features (from develop)
- **fix/\***: Bug fixes (from develop)
- **hotfix/\***: Critical production fixes (from main)
- **release/\***: Release preparation (from develop)

**Workflow**: Feature → develop → release → main (tagged)

### GitHub Flow (Continuous Deployment)

```text
main (always deployable) ← feature/*, fix/*, docs/*
```

**Workflow**: Branch from main → PR → Deploy staging → Merge → Auto-deploy production
**Best for**: Continuous deployment, web apps, SaaS

### Trunk-Based Development (High-Velocity Teams)

- Single `main` branch
- Short-lived branches (< 1 day)
- Feature flags for incomplete features
- Multiple merges per day

## Branch Naming

### Prefixes

`feature/`, `fix/`, `hotfix/`, `refactor/`, `docs/`, `test/`, `chore/`, `perf/`, `style/`

### Format

```text
<prefix>/<ticket-id>-<short-description>

Examples:
feature/USER-123-oauth-login
fix/BUG-456-email-validation
refactor/improve-user-service
```

## Commit Message Standards

### Conventional Commits

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`, `revert`

### Examples

```text
feat: add user authentication

Implement JWT-based auth with refresh tokens.
Includes login, logout, and token refresh endpoints.
```

```text
fix(api): handle null values in user profile

Previously caused 500 errors. Now returns defaults.

Fixes #456
```

```text
feat(auth)!: change password hashing algorithm

BREAKING CHANGE: Switch to Argon2. Existing passwords
will need rehashing on next login.
```

### Best Practices

- Atomic commits (one logical change)
- Present tense, imperative mood
- First line < 72 chars
- Explain why, not what
- Reference issues/tickets

## Pull Request Process

### PR Template

```markdown
## Description

Brief description and motivation

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests pass locally
```

### Workflow

1. Create PR: `gh pr create --title "feat: ..." --body "..."`
2. Request reviews (minimum one required)
3. Automated checks pass (lint, tests, build, security)
4. Code review and address feedback
5. Approval (minimum one)
6. Merge (squash and merge to main)

### Review Guidelines

**Reviewers**: Review within 24 hours, constructive feedback, check correctness/readability/performance/security
**Authors**: Respond to all comments, explain complex decisions, update based on feedback

## Merging Strategies

### Squash and Merge (Recommended)

**When**: Feature branches to main
**Benefit**: Clean linear history, one commit per feature

### Rebase and Merge

**When**: Keeping feature branch updated with main
**Benefit**: Linear history, preserves commits

```bash
git checkout feature/user-auth
git rebase main
git push --force-with-lease
```

### Merge Commit

**When**: Release branches, preserving branch history

## Versioning (SemVer)

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (v1.0.0 → v2.0.0)
- **MINOR**: New features, backward compatible (v1.0.0 → v1.1.0)
- **PATCH**: Bug fixes (v1.0.0 → v1.0.1)

**Pre-release**: `v1.0.0-alpha.1`, `v1.0.0-beta.2`, `v1.0.0-rc.1`

### Tagging

```bash
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```

## CI/CD Pipelines

### GitHub Actions Example

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
      - run: npm run build

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm audit --audit-level=high
```

### Deployment Workflow

```yaml
name: Deploy

on:
  push:
    branches: [main]
    tags: ["v*"]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      - run: npm ci && npm run build
      - run: npm test
      - run: ./scripts/deploy.sh production
```

## Deployment Procedures

### Environments

- **Development**: Auto-deploy from develop, latest features, may be unstable
- **Staging**: Mirrors production, pre-release testing, deploy from release branches
- **Production**: Stable code only, deploy from main, tagged releases

### Deployment Checklist

**Pre-deployment**:

- [ ] Tests passing
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] Backup current production

**Deployment**:

- [ ] Run database migrations
- [ ] Deploy application
- [ ] Verify health checks
- [ ] Run smoke tests
- [ ] Monitor logs

**Post-deployment**:

- [ ] Verify critical functionality
- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Update status page

### Deployment Strategies

**Blue-Green**: Two identical environments, switch traffic after verification, easy rollback
**Canary**: Deploy to small subset, gradually increase traffic, rollback if issues
**Rolling**: Deploy to servers incrementally, maintain availability

### Zero-Downtime Deployment

```bash
#!/bin/bash
npm run build
rsync -avz dist/ servers:/app/releases/v1.2.0/
ssh servers "ln -sfn /app/releases/v1.2.0 /app/current"
ssh servers "systemctl reload app"
curl -f https://api.example.com/health || exit 1
```

## Rollback Procedures

### Quick Rollback

```bash
# Revert to previous version
git checkout v1.1.0
npm run deploy

# Or create revert commit
git revert HEAD
git push origin main

# Switch symlink
ssh servers "ln -sfn /app/releases/v1.1.0 /app/current"
ssh servers "systemctl reload app"
```

### Database Rollback

```bash
npm run migrate:rollback
# Or restore from backup
./scripts/restore-database.sh backup.sql
```

## Hotfix Procedure

1. Create hotfix branch from main: `git checkout -b hotfix/fix-issue`
2. Implement minimal fix
3. Test thoroughly
4. Deploy to staging and verify
5. Create PR and get quick review
6. Tag and deploy: `git tag -a v1.2.1 -m "Hotfix: issue"` → deploy
7. Merge back to develop
8. Post-mortem: Document incident, add tests, improve monitoring

## Release Process

### Release Checklist

**Preparation** (1 week before):

- [ ] Feature freeze on develop
- [ ] Update CHANGELOG.md
- [ ] Update version numbers
- [ ] Prepare release notes

**Release Branch** (3 days before):

```bash
git checkout develop
git checkout -b release/v1.2.0
```

- [ ] Final bug fixes only
- [ ] Deploy to staging
- [ ] QA and performance testing
- [ ] Security audit

**Release Day**:

```bash
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin main --tags

git checkout develop
git merge --no-ff release/v1.2.0
git push origin develop
```

- [ ] Deploy to production
- [ ] Verify deployment
- [ ] Publish release notes
- [ ] Monitor for issues

## Git Best Practices

### Commit Hygiene

- Commit early and often
- Keep commits focused and atomic
- Write meaningful messages
- Review changes before committing
- Use `git add -p` for partial commits

### Branch Hygiene

- Delete merged branches
- Keep branches short-lived
- Sync with main regularly
- Avoid long-running branches

### Collaboration

- Pull before pushing
- Communicate about force pushes
- Use draft PRs for WIP
- Tag teammates for review
- Resolve conflicts promptly

## Project-Specific Configuration

Document in `.context/git-workflow.md`:

- Branching strategy choice
- PR approval requirements
- Deployment triggers
- Release schedule
- Hotfix procedures

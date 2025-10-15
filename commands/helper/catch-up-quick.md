# Quick Context Catch-Up

Get rapid context overview for immediate task execution.

Arguments: None

## Process

Gather essential context in under 2 minutes:

### 1. Project Basics

- Read `CLAUDE.md` (if exists)
- Read `package.json` or equivalent (tech stack)
- Read `README.md` (project overview)

### 2. Current State

```bash
git status           # Current changes
git branch          # Current branch
git log -5 --oneline # Recent commits
```

### 3. Recent Activity

- Last 5 commit messages (what's been done)
- Current branch name (what's being worked on)
- Staged/unstaged changes (current progress)

### 4. Summary Report

```text
📋 Quick Context Catch-Up

**Project**: [name from package.json/README]
**Tech Stack**: [languages/frameworks]
**Current Branch**: [branch-name]

**Recent Work** (last 5 commits):
1. [commit 1]
2. [commit 2]
3. [commit 3]
4. [commit 4]
5. [commit 5]

**Current Status**:
- Staged files: [N]
- Modified files: [N]
- Branch: [branch-name]

**Ready to assist with**: [based on current context]
```

**Use when**: Quick question, small fix, or immediate task.

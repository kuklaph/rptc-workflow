# Provider adapters

## Why separate files remain

Claude Code and Codex do not offer interchangeable harnesses.

Claude has native slash commands, plugin-declared Markdown agents, task
dependencies, native plan tools, and persistent peer teams.

Codex exposes skills, a flat `update_plan`, plan-mode-gated structured input,
parent-owned `spawn_agent` and `wait_agent`, and TOML agent installation.

Trying to generate one identical prompt for both would either remove useful
Claude behavior or describe Codex capabilities that do not exist.

## What should be shared

Share policy when changing it should alter engineering behavior in both
providers:

- when architecture is necessary;
- what TDD means;
- how bugs are diagnosed;
- what counts as evidence;
- when user approval is required;
- how tests and production are compared;
- completion states.

## What should remain provider-owned

Keep mechanics in adapters:

- tool and command names;
- progress tracking;
- planning transitions;
- agent installation;
- spawn and wait behavior;
- team communication;
- plugin-root path syntax;
- provider instruction-file names.

## Review question

When two files look duplicated, ask:

> Would changing this sentence alter engineering behavior in both providers, or
> only explain how one harness performs the behavior?

Move the first kind to a shared contract. Keep the second kind in the adapter.

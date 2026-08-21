#!/usr/bin/env python3
"""Validate RPTC provider contracts, skill metadata, and eval fixtures."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "rptc"
CONTRACT_PATH = PLUGIN / "provider-contract.json"

PROVIDER_TOKENS = {
    "TaskCreate",
    "TaskUpdate",
    "TodoWrite",
    "AskUserQuestion",
    "EnterPlanMode",
    "ExitPlanMode",
    "spawn_agent",
    "wait_agent",
    "update_plan",
    "request_user_input",
    "SendMessage",
    "CLAUDE_PLUGIN_ROOT",
}

FRONTMATTER_RE = re.compile(r"\A---\s*\n(.*?)\n---\s*\n", re.DOTALL)


class ValidationError(Exception):
    pass


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise ValidationError(f"missing JSON file: {path.relative_to(ROOT)}") from exc
    except json.JSONDecodeError as exc:
        raise ValidationError(
            f"invalid JSON in {path.relative_to(ROOT)}: {exc}"
        ) from exc


def parse_frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    match = FRONTMATTER_RE.match(text)
    if not match:
        raise ValidationError(f"missing YAML frontmatter: {path.relative_to(ROOT)}")

    fields: dict[str, str] = {}
    for raw_line in match.group(1).splitlines():
        if not raw_line or raw_line[0].isspace() or ":" not in raw_line:
            continue
        key, value = raw_line.split(":", 1)
        fields[key.strip()] = value.strip().strip('"').strip("'")
    return fields


def validate_contract() -> list[str]:
    warnings: list[str] = []
    contract = load_json(CONTRACT_PATH)

    if contract.get("schema_version") != 1:
        raise ValidationError("provider-contract.json schema_version must be 1")

    providers = contract.get("providers")
    if set(providers or {}) != {"claude", "codex"}:
        raise ValidationError("provider contract must define claude and codex")

    flows = contract.get("flows")
    if not isinstance(flows, dict) or not flows:
        raise ValidationError("provider contract must define at least one flow")

    for name, flow in flows.items():
        if not isinstance(flow, dict):
            raise ValidationError(f"flow {name!r} must be an object")

        shared = flow.get("shared_contract")
        if not shared:
            raise ValidationError(f"flow {name!r} has no shared_contract")
        shared_path = PLUGIN / shared
        if not shared_path.is_file():
            raise ValidationError(
                f"flow {name!r} references missing shared contract: {shared}"
            )

        claude = flow.get("claude")
        codex = flow.get("codex")
        parity = flow.get("parity")
        if parity not in {"semantic", "provider-specific", "intentional-asymmetry"}:
            raise ValidationError(f"flow {name!r} has invalid parity value: {parity!r}")

        for provider_name, adapter in (("claude", claude), ("codex", codex)):
            if adapter is None:
                continue
            adapter_path = PLUGIN / adapter
            if not adapter_path.is_file():
                raise ValidationError(
                    f"flow {name!r} references missing {provider_name} adapter: {adapter}"
                )

            if contract.get("enforce_adapter_contract_refs"):
                text = adapter_path.read_text(encoding="utf-8")
                expected = f"Shared contract: `{shared}`"
                if expected not in text:
                    raise ValidationError(
                        f"{adapter} must contain exact marker: {expected}"
                    )

        if (claude is None or codex is None or parity != "semantic") and not flow.get(
            "reason"
        ):
            raise ValidationError(
                f"flow {name!r} needs a reason for provider-specific behavior"
            )

    for path in (PLUGIN / "shared" / "workflows").glob("*.md"):
        text = path.read_text(encoding="utf-8")
        found = sorted(token for token in PROVIDER_TOKENS if token in text)
        if found:
            raise ValidationError(
                f"shared workflow {path.relative_to(PLUGIN)} contains provider tools: "
                + ", ".join(found)
            )

    return warnings


def validate_skills() -> list[str]:
    warnings: list[str] = []
    for path in sorted(PLUGIN.rglob("SKILL.md")):
        fields = parse_frontmatter(path)
        missing = [key for key in ("name", "description") if not fields.get(key)]
        if missing:
            raise ValidationError(
                f"{path.relative_to(ROOT)} is missing frontmatter fields: "
                + ", ".join(missing)
            )

        line_count = len(path.read_text(encoding="utf-8").splitlines())
        if line_count > 500:
            warnings.append(
                f"{path.relative_to(ROOT)} has {line_count} lines; consider progressive disclosure"
            )
    return warnings


def validate_evals() -> list[str]:
    routing = load_json(ROOT / "evals" / "routing.json")
    parity = load_json(ROOT / "evals" / "provider-parity.json")

    if routing.get("schema_version") != 1 or not routing.get("cases"):
        raise ValidationError("evals/routing.json must contain schema_version 1 and cases")
    if parity.get("schema_version") != 1 or not parity.get("cases"):
        raise ValidationError(
            "evals/provider-parity.json must contain schema_version 1 and cases"
        )

    contract = load_json(CONTRACT_PATH)
    known_flows = set(contract["flows"])
    for case in parity["cases"]:
        flow = case.get("flow")
        if flow not in known_flows:
            raise ValidationError(
                f"provider parity eval references unknown flow: {flow!r}"
            )
        if not case.get("invariants"):
            raise ValidationError(
                f"provider parity eval for {flow!r} has no invariants"
            )
    return []


def main() -> int:
    warnings: list[str] = []
    try:
        warnings.extend(validate_contract())
        warnings.extend(validate_skills())
        warnings.extend(validate_evals())
    except ValidationError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print("RPTC validation passed.")
    if warnings:
        print(f"{len(warnings)} non-blocking warning(s):")
        for warning in warnings:
            print(f"- {warning}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

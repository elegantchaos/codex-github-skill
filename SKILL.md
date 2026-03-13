---
name: codex-github
description: Use when working with GitHub in Codex.app. It covers pull requests, draft releases, and safe non-interactive gh CLI usage, while relying on codex-git for git write-side behavior.
---

# Codex GitHub

Use this skill when working with GitHub in Codex.app.

Use `codex-git` alongside this skill when the task also needs git write commands.

Read the relevant reference file before running `gh` commands:

- for pull requests, read `references/pull-requests.md`
- for draft releases, read `references/draft-releases.md`

## Use This Skill When

- creating or editing pull requests
- preparing or updating draft releases
- running `gh` commands non-interactively in Codex.app

## Shared Rules

- Prefer deterministic, non-interactive `gh` commands.
- Keep PRs and release notes factual and scoped to the actual diff.
- Include validation summary and known gaps when they are relevant.
- When a workflow requires git writes, use `codex-git` for escalation and command-shape guidance.

## Process

1. Decide whether the task is a pull request task or a draft release task.
2. Read the matching reference file before running commands.
3. Follow that reference process completely.
4. Use `codex-git` alongside this skill if the task also needs git write commands.

## References

- `references/pull-requests.md`: PR creation and editing process, `--body-file` rules, and verification steps
- `references/draft-releases.md`: draft release process, notes generation rules, and output checklist
- `scripts/generate_release_notes.swift`: git-log-based fallback for release notes when ReleaseTools is unavailable

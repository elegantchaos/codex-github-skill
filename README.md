<p align="center">
    <img src="assets/logo.svg" alt="Codex GitHub - Agent Skill" height="100" />
</p>

# Codex GitHub

This repository contains the `codex-github` agent skill.

## Purpose

Use this skill when working with GitHub workflows in Codex.app. It covers pull requests, draft releases, and safe non-interactive `gh` CLI usage, while relying on `codex-git` for git write-side behavior.

## Compatibility

- Agent hosts: Codex-compatible skill hosts
- Publication class: `portable-with-prereqs`

## Prerequisites

- GitHub CLI authenticated against the target repository
- Codex-style git workflow support via the `codex-git` skill when git write commands are involved

## Shared Baseline

This skill does not require the shared agents baseline.

## Contents

- `SKILL.md`
- `agents/openai.yaml`
- `scripts/generate_release_notes.swift`
- standard support files such as `assets/`, `LICENSE`, and `CHANGELOG.md`

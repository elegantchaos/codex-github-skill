---
name: codex-github
description: Use when working with GitHub workflows in Codex.app. It covers pull requests, draft releases, and safe non-interactive gh CLI usage, while relying on codex-git for git write-side behavior.
---

# Codex GitHub

Use this skill when working with GitHub workflows in Codex.app.

## Purpose

This skill is the canonical place for GitHub workflow guidance in the shared setup. Use it for:

- pull request creation and editing
- draft release preparation
- safe non-interactive `gh` CLI usage

Use `codex-git` alongside this skill when the workflow also needs git write commands.

## Shared Rules

- Prefer deterministic, non-interactive `gh` commands.
- Keep PRs and release notes factual and scoped to the actual diff.
- Include validation summary and known gaps when they are relevant.
- When a workflow requires git writes, use `codex-git` for escalation and command-shape guidance.

## Pull Requests

### Rules

- Always use `--body-file` for PR descriptions.
- Never use inline `--body` for multi-line markdown.
- Prefer building the PR body in a temporary markdown file, then passing it to `gh pr create` or `gh pr edit`.
- After updating PR body text, verify the final result with `gh pr view --json body,url`.
- Always push the PR head branch before creating or editing the PR.
- If push fails, stop and report the exact push error.

### Workflow

1. Check whether the branch needs updating before push.
   - If the head branch is behind the intended base branch, offer to pull and resolve conflicts before pushing.
2. Verify and push the PR head branch.
   - Use `git branch --show-current` to confirm the current branch when needed.
   - Push the head branch before PR creation or editing.
3. Build the PR body in a file.
4. Create or edit the PR with `gh pr create --body-file` or `gh pr edit --body-file`.
5. Verify final PR text with `gh pr view --json body,url`.

### Notes

- Keep PR summaries concise and factual.
- Include explicit validation bullets.
- `--body-file` avoids shell interpolation risks involving backticks, `$`, parentheses, and embedded markdown.

## Draft Releases

### Rules

- Draft releases must be prepared from `main` unless the user explicitly asks for another target.
- Push `main` before drafting the release.
- Generate notes from the actual commit range, then improve them before creating the draft.
- Leave the release in draft state unless the user explicitly asks to publish it.

### Workflow

1. Confirm release inputs.
   - Determine the new release tag.
   - Determine the target branch or commit.
2. Verify the release is being prepared from `main`, unless the user directed otherwise.
3. Push the target branch before drafting.
4. Generate release notes.
   - Prefer `rt changes --end <target> > /tmp/<new_tag>-notes.md` when ReleaseTools is available.
   - The included `scripts/generate_release_notes.swift` helper is available when a simple git-log-based fallback is needed.
5. Improve the generated notes.
   - Add a short human-readable opening summary.
6. Create or update the draft release with `gh release create --draft --notes-file` or `gh release edit --draft --notes-file`.
7. Hand off for manual review and publish.

### Output Checklist

- report `new_tag`, `previous_tag`, and `target`
- report the exact commit range used for notes
- report the draft release URL
- confirm that the release remains in draft state

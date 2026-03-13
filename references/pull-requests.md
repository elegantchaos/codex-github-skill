# Pull Request Workflow

## Rules

- Always use `--body-file` for PR descriptions.
- Never use inline `--body` for multi-line markdown.
- Prefer building the PR body in a temporary markdown file, then passing it to `gh pr create` or `gh pr edit`.
- After updating PR body text, verify the final result with `gh pr view --json body,url`.
- Always push the PR head branch before creating or editing the PR.
- If push fails, stop and report the exact push error.

## Workflow

1. Check whether the branch needs updating before push.
   - If the head branch is behind the intended base branch, offer to pull and resolve conflicts before pushing.
2. Verify and push the PR head branch.
   - Use `git branch --show-current` to confirm the current branch when needed.
   - Push the head branch before PR creation or editing.
3. Build the PR body in a file.
4. Create or edit the PR with `gh pr create --body-file` or `gh pr edit --body-file`.
5. Verify final PR text with `gh pr view --json body,url`.

## Notes

- Keep PR summaries concise and factual.
- Include explicit validation bullets.
- `--body-file` avoids shell interpolation risks involving backticks, `$`, parentheses, and embedded markdown.

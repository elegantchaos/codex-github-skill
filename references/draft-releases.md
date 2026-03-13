# Draft Release Workflow

## Rules

- Draft releases must be prepared from `main` unless the user explicitly asks for another target.
- Push `main` before drafting the release.
- Generate notes from the actual commit range, then improve them before creating the draft.
- Leave the release in draft state unless the user explicitly asks to publish it.

## Workflow

1. Confirm release inputs.
   - Determine the new release tag.
   - Determine the target branch or commit.
2. Verify the release is being prepared from `main`, unless the user directed otherwise.
3. Push the target branch before drafting.
4. Generate release notes.
   - Prefer `rt changes --end <target> > /tmp/<new_tag>-notes.md` when ReleaseTools is available.
   - Use `scripts/generate_release_notes.swift` when a simple git-log-based fallback is needed.
5. Improve the generated notes.
   - Add a short human-readable opening summary.
6. Create or update the draft release with `gh release create --draft --notes-file` or `gh release edit --draft --notes-file`.
7. Hand off for manual review and publish.

## Output Checklist

- report `new_tag`, `previous_tag`, and `target`
- report the exact commit range used for notes
- report the draft release URL
- confirm that the release remains in draft state

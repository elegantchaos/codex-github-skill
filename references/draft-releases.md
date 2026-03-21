# Draft Release Workflow

## Rules

- Draft releases must be prepared from `main` unless the user explicitly asks for another target.
- Push `main` before drafting the release.
- Generate notes from the actual commit range, then improve them before creating the draft.
- Leave the release in draft state unless the user explicitly asks to publish it.
- Treat draft release URLs with an `untagged-...` slug as normal GitHub behavior while the release remains in draft state.
- Do not call out the `untagged-...` slug in user-facing output unless the release metadata itself is wrong.
- Always create the release tag in `vX.Y.Z` form.
- Derive the release title from the tag by removing the leading `v` and, when the version ends in `.0`, dropping only the trailing third component.
  - `v1.2.3` -> `1.2.3`
  - `v2.0.0` -> `2.0`

## Workflow

1. Confirm release inputs.
   - Determine the new release tag.
   - Derive the release title from the tag using the formatting rule above.
   - Determine the target branch or commit.
2. Verify the release is being prepared from `main`, unless the user directed otherwise.
3. Push the target branch before drafting.
4. Generate release notes.
   - Prefer `rt changes --end <target> > /tmp/<new_tag>-notes.md` when ReleaseTools is available.
   - Use `scripts/generate_release_notes.swift` when a simple git-log-based fallback is needed.
5. Improve the generated notes.
   - Add a short human-readable opening summary.
6. Create or update the draft release with `gh release create --draft --title <derived title> --notes-file` or `gh release edit --draft --title <derived title> --notes-file`.
   - If GitHub returns or displays an `untagged-...` URL for the draft, accept it silently as long as `gh release view` confirms the intended tag, title, target, and draft state.
7. Hand off for manual review and publish.

## Output Checklist

- report `new_tag`, `previous_tag`, and `target`
- report the exact commit range used for notes
- report the draft release URL
- confirm that the release remains in draft state

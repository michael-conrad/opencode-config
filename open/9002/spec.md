# Spec: #9001 — Add missing alt text to the README screenshot

## Summary

The README embeds `docs/screenshot.png` without alt text. Screen readers
announce an unnamed image.

## Success criteria

### SC-1 (structural)

The README's image embed for `docs/screenshot.png` carries non-empty alt
text describing the screenshot.

- **Verify:** the markdown image syntax for `docs/screenshot.png` in
  `README.md` contains alt text between the square brackets.

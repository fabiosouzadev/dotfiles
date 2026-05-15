<!-- generated-by: gsd-doc-writer -->
# Testing

This document describes how to test changes to these dotfiles to ensure stability across platforms.

## Testing Procedures

Since dotfiles affect the entire user environment, testing is primarily manual and focuses on idempotency and cross-platform compatibility.

### 1. Dry-run Verification

Before applying any change, always run a dry-run to see what files will be modified and verify template logic:

```bash
chezmoi apply --dry-run --verbose
```

Check the output for:
- Correct path resolution (especially on different OSs).
- Expected variable expansions.
- No unexpected file deletions.

### 2. Idempotency Check

Apply the changes twice and ensure the second run does nothing:

```bash
chezmoi apply
chezmoi apply # Should produce no output or changes
```

### 3. Cross-Platform Validation

If you make changes to shared scripts (in `home/.chezmoiscripts/unix/`) or shared templates, try to verify them on at least one other platform (e.g., test macOS changes on Linux via a VM or Docker container).

## CI Integration

*Currently, no automated CI pipeline is configured for this repository.*

## Troubleshooting

If a script fails during `chezmoi apply`:
1. Check the script's output in the terminal.
2. Run the script manually to isolate the error:
   ```bash
   chezmoi execute-template < home/.chezmoiscripts/.../script.sh.tmpl > /tmp/test.sh
   bash /tmp/test.sh
   ```
3. Verify that all required environment variables are set in `.chezmoi.yaml.tmpl`.

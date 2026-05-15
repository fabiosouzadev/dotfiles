<!-- generated-by: gsd-doc-writer -->
# Development

This guide explains how to contribute to these dotfiles and maintain them.

## Local Setup

To develop changes to these dotfiles, it is recommended to work in a separate branch:

1.  Create a new branch: `git checkout -b feat/my-new-feature`
2.  Make your changes in the `home/` directory.
3.  Test your changes locally:
    ```bash
    chezmoi apply --dry-run --verbose
    ```
4.  If satisfied, apply the changes:
    ```bash
    chezmoi apply
    ```

## Maintenance Commands

The following commands are useful during development:

| Command | Description |
|---------|-------------|
| `chezmoi add <file>` | Add a new file to the dotfiles management. |
| `chezmoi edit <file>` | Edit the source template for a managed file. |
| `chezmoi diff` | Show differences between managed files and the current home directory. |
| `chezmoi apply` | Apply changes to the home directory. |
| `chezmoi cd` | Open a shell in the chezmoi source directory. |

## Code Style

-   **Shell Scripts**: Use `sh` or `bash` for scripts in `.chezmoiscripts/`. Ensure they are idempotent (safe to run multiple times).
-   **Templates**: Use Go `text/template` syntax correctly. Avoid complex logic in templates where possible; move logic to variables in `.chezmoi.yaml.tmpl`.
-   **Naming**: Use lowercase-kebab-case for filenames and directories.

## Branch Conventions

-   `main`: The stable branch containing the current setup.
-   `feat/*`: For new features or tools.
-   `fix/*`: For bug fixes.
-   `docs/*`: For documentation-only changes.

## PR Process

1.  Ensure your changes are idempotent and don't break the bootstrap process on other platforms.
2.  Run `chezmoi apply` to verify the templates compile correctly.
3.  Commit your changes following the [Conventional Commits](https://www.conventionalcommits.org/) specification.
4.  Push your branch and open a Pull Request against `main`.
5.  Provide a clear description of the changes and any new tools added.

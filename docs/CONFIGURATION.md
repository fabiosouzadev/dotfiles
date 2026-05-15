<!-- generated-by: gsd-doc-writer -->
# Configuration

This document lists the environment variables and settings used to customize the dotfiles setup.

## Environment Variables

The following environment variables can be used to override the default detection logic in `.chezmoi.yaml.tmpl`:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `CHEZMOI_PROFILE` | No | `personal` | Set to `work` or `personal` to toggle profile-specific settings. |
| `CHEZMOI_FORCE_GUI` | No | `false` | Force `guiAvailable` to true. |
| `CHEZMOI_FORCE_HEADLESS` | No | `false` | Force `headless` to true. |
| `CHEZMOI_SKIP_SHELL_PROBES` | No | `false` | Skip expensive shell probes during initialization. |
| `CI` | No | `false` | Detected automatically; sets `ephemeral` and `headless` to true. |

## Config File Format

The core configuration is defined in `home/.chezmoi.yaml.tmpl`. This template generates the final `~/.config/chezmoi/chezmoi.yaml` file.

### Key Sections:

-   **data**: Contains all the variables available to templates.
-   **encryption**: Configured to use `age`.
-   **age**: Identity file location (`~/.config/chezmoi/key.txt`) and recipient public key.

## Required vs Optional Settings

-   **Required**: The `age` identity file (`~/.config/chezmoi/key.txt`) is required if you use encrypted secrets. Without it, `chezmoi apply` will fail on encrypted files.
-   **Optional**: All feature flags (AI tools, window managers, etc.) are optional and have sane defaults based on environment detection.

## Feature Flags

The following features can be toggled in `home/.chezmoi.yaml.tmpl` under the `features` key:

| Feature | Default | Description |
|---------|---------|-------------|
| `ai.coding_assistants` | `true` | Install AI assistants (Claude Code, Aider, etc.). |
| `ai.spec_tools` | `true` | Install spec and review tools. |
| `ai.gsd` | `true` | Install GSD (Get Shit Done) tools. |
| `ai.ollama.install` | `true` | Install and configure Ollama. |
| `ai.hermes.install` | `true` | Install Hermes Agent. |
| `i3.enabled` | `true` (Linux) | Enable i3 window manager configuration. |
| `niri.enabled` | `true` (Linux) | Enable Niri window manager configuration. |

## Per-Environment Overrides

The setup automatically detects the environment and adjusts accordingly:

-   **Headless**: Disables GUI-related scripts and configurations (e.g., window managers, browsers).
-   **Ephemeral**: Used in CI or Cloud IDEs; minimizes setup time and avoids persistent state where possible.
-   **OS-specific**: Package lists are pulled from `home/.chezmoidata/{darwin,linux,windows}/`.

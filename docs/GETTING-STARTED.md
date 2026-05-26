<!-- generated-by: gsd-doc-writer -->
# Getting Started

This guide will help you get your development environment up and running with these dotfiles.

## Prerequisites

Before you begin, ensure your system meets the following requirements:

-   **Operating System**: macOS, Linux (Arch, Ubuntu), or Windows (with WSL2).
-   **git**: Required to clone the repository.
-   **chezmoi**: The dotfile manager used to apply these configurations.
-   **age**: Required to decrypt secrets.
-   **Nerd Font**: A font with icons (e.g., JetBrainsMono Nerd Font) is highly recommended for the best terminal experience.

## Installation Steps

### 1. Initialize chezmoi

Run the following command to bootstrap your machine. This will install `chezmoi` if it's missing and initialize the repository.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply fabiosouzadev
```

### 2. Setup Secrets (Optional but Recommended)

If you have your own `age` key, place it at `~/.config/chezmoi/key.txt`. If you don't have one, you can generate it:

```bash
mkdir -p ~/.config/chezmoi
age-keygen -o ~/.config/chezmoi/key.txt
```

*Note: You will need to re-encrypt the files in `home/` if you want to use your own secrets. See [docs/FORK-GUIDE.md](FORK-GUIDE.md) for details.*

### 3. Change Shell

The configuration is optimized for **Zsh**. After installation, change your default shell:

```bash
chsh -s $(which zsh)
```

## First Run

Open a new terminal window. You should see the **Starship** prompt and all plugins being initialized by **Zinit**.

To verify the installation of modern CLI tools:
```bash
eza --version
bat --version
fzf --version
lazygit --version
```

To check if AI tools are available:
```bash
claude --version
aider --version
```

## Common Setup Issues

-   **Missing Icons**: If you see squares instead of icons in your prompt or file listings, you are likely not using a Nerd Font. Install one and configure your terminal to use it.
-   **Age Decryption Failure**: If `chezmoi apply` fails with a "decryption error", ensure your private key in `~/.config/chezmoi/key.txt` matches the recipient public key in `.chezmoi.yaml.tmpl`.

## Next Steps

-   Read [Architecture](ARCHITECTURE.md) to understand how the system is structured.
-   Explore [Keymaps](KEYMAPS.md) for a list of shortcuts.
-   Check [Configuration](CONFIGURATION.md) for a list of available feature flags.

# Plan: Implement GitLab CLI

## Description
Implement the GitLab command line interface (https://docs.gitlab.com/cli/) for this dotfiles project.

## Tasks
- Create a script `gitlab-cli.sh` in `~/bin` that installs the `glab` binary via the official installer and adds it to the PATH.
- Add a brief usage README in `.github/TOOLS.md`.

## Execution Steps
1. Download the latest `glab` release for the current OS.
2. Extract and place the binary in `~/bin` (ensure it is executable).
3. Verify installation with `glab --version`.
4. Document usage in `.github/TOOLS.md`.

## Verification
- Run `glab auth login` successfully.
- Ensure the script is executable and listed in PATH.

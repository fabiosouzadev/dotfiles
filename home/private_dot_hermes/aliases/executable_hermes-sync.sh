#!/usr/bin/env bash

# Aliases para hermes-sync
alias hermes-sync-push='hermes-sync push && chezmoi cd && git add . && git commit -m "backup: update Hermes sync" && git push'
alias hermes-sync-pull='hermes-sync pull'
alias hermes-sync-status='hermes-sync status'
alias hermes-sync-doctor='hermes-sync doctor'

# Aliases para compatibilidade OmniRoute
alias omniroute-sync-push='hermes-sync push && chezmoi cd && git add . && git commit -m "backup: update OmniRoute sync" && git push'
alias omniroute-sync-pull='hermes-sync pull'
alias omniroute-sync-status='hermes-sync status'
alias omniroute-sync-doctor='hermes-sync doctor'

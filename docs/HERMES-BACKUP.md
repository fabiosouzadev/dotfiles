# Hermes Agent backup via Chezmoi

Este dotfiles **não** faz backup completo do histórico do Hermes dentro do Git. O objetivo é restaurar a identidade/configuração operacional do Hermes numa nova VPS sem transformar o repo em depósito de estado mutável.

Modelo correto:

```text
arquivos pequenos estáveis + SQL seletivo + manifest -> chezmoi add --encrypt -> git push
```

## Comandos

```bash
hermes-sync-status   # ver saúde do estado local e dos arquivos sync
hermes-sync-push     # exporta manifest/SQL e adiciona ao chezmoi criptografado
hermes-sync-pull     # importa estado seletivo depois de chezmoi apply
```

Também funciona diretamente:

```bash
hermes-sync status
hermes-sync export
hermes-sync push
hermes-sync doctor
hermes-sync pull
```

## O que entra

Arquivos pequenos/estáveis, sempre criptografados via age/chezmoi:

- `~/.hermes/config.yaml`
- `~/.hermes/.env`
- `~/.hermes/auth.json`
- `~/.hermes/gmail_app_password.txt`
- `~/.hermes/memories/MEMORY.md`
- `~/.hermes/memories/USER.md`
- `~/.hermes/cron/jobs.json`
- `~/.hermes/channel_directory.json`
- `~/.hermes/gateway_state.json`
- `~/.hermes/mcp_servers.json`, se existir
- `~/.hermes/shell-hooks-allowlist.json`, se existir

Arquivos gerados pelo próprio `hermes-sync export`:

- `~/.hermes/sync/manifest.json`
- `~/.hermes/sync/kanban-config.sql`
- `~/.hermes/sync/skills-manifest.tsv`

## Banco de dados

### `state.db`

Não entra no dotfiles.

Motivo: contém histórico de sessões/mensagens, FTS e runtime state. Cresce com uso e não é adequado para Git.

### `kanban.db`

Não entra como SQLite bruto. O sync exporta apenas SQL semântico das tabelas:

- `tasks`
- `task_links`
- `task_comments`

Ficam fora por padrão:

- `task_events`
- `task_runs`
- `task_attachments`
- `kanban_notify_subs`

## Skills

`~/.hermes/skills/` não entra inteiro no Git. Hoje é uma árvore grande, com conteúdo de hub/registry e arquivos auxiliares.

O sync gera apenas:

```text
~/.hermes/sync/skills-manifest.tsv
```

Esse manifesto lista categoria, skill, tamanho, quantidade de arquivos e caminho. Skills realmente autorais/importantes devem ser versionadas de forma explícita ou recriadas via processo próprio, não escondidas num tarball gigante.

## O que fica fora

- `~/.hermes/state.db`
- `~/.hermes/sessions/`
- `~/.hermes/logs/`
- `~/.hermes/cache/`
- `~/.hermes/audio_cache/`
- `~/.hermes/hermes-agent/`
- `state.db-wal`, `state.db-shm`
- `gateway.pid`, `gateway.lock`, `processes.json`
- `node_modules/`, `venv/`, `.venv/`, `__pycache__/`, `*.pyc`
- qualquer `backup.tar.gz` monolítico

## Backup manual

```bash
hermes-sync-push
chezmoi cd
git status
git add .
git commit -m "backup: update Hermes sync"
git push
```

Antes de commitar, rode:

```bash
hermes-sync-doctor  # se o alias existir
# ou
hermes-sync doctor
```

O doctor bloqueia/alerta sobre blobs proibidos no chezmoi, especialmente backups monolíticos.

## Restore em nova VPS

Depois de bootstrapar o dotfiles:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply fabiosouzadev
```

Então:

```bash
hermes-sync-pull
hermes doctor
hermes gateway restart
```

`chezmoi apply` restaura arquivos pequenos/secrets. `hermes-sync-pull` importa o SQL seletivo do Kanban quando existir.

## Regra mental

> O chezmoi restaura a identidade/configuração do Hermes, não o histórico completo de conversas.

Para backup completo de histórico, use uma estratégia separada, como `restic`, `rclone`, snapshot de volume, ou backup criptografado rotativo fora do Git.

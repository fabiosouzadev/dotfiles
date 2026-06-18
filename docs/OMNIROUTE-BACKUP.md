# OmniRoute backup via Chezmoi

Este dotfiles **não** faz backup completo do banco de dados SQLite do OmniRoute nem dos logs de chamadas. O objetivo é restaurar as configurações semânticas do OmniRoute numa nova VPS sem transformar o repo em depósito de estado mutável gigante.

Modelo correto:
```text
config seletiva (SQL) + secrets (.env) + manifest -> chezmoi add --encrypt -> git push
```

## Resposta prática: o que este backup restaura

O export seletivo inclui as tabelas de configuração necessárias para recriar o estado operacional/admin, incluindo:

- provedores/conexões e credenciais criptografadas (`provider_connections`, `provider_nodes`);
- combos e roteamento (`combos`, `model_combo_mappings`);
- chaves da API local (`api_keys`);
- proxies/upstream e quotas/grupos quando configurados;
- hooks/plugins/skills/relay/webhooks quando configurados;
- **settings do dashboard/admin em `key_value`, incluindo `settings.password`, `settings.requireLogin`, `secrets.jwtSecret` e `secrets.apiKeySecret`.**

Ou seja: a senha do dashboard web fica coberta pelo backup atual porque ela mora em `key_value`, que é exportada criptografada dentro de `config.sql`.

## Comandos

```bash
omniroute-sync-status   # ver saúde do estado local e dos arquivos sync
omniroute-sync-push     # exporta config SQL seletiva e adiciona ao chezmoi criptografado
omniroute-sync-pull     # importa estado seletivo depois de chezmoi apply
omniroute-sync-doctor   # valida se não há blobs gigantes/plaintext no chezmoi
```

Também funciona diretamente:
```bash
omniroute-sync status
omniroute-sync push
omniroute-sync pull
omniroute-sync doctor
```

## O que entra

Arquivos pequenos/estáveis, sempre criptografados via age/chezmoi:

- `~/.omniroute/.env`
- `~/.omniroute/config.sql`
- `~/.omniroute/sync/manifest.json`
- `~/.omniroute/sync/backup-note.txt`

## O que fica fora

- `~/.omniroute/storage.sqlite` (banco bruto)
- `~/.omniroute/storage.sqlite-wal`, `storage.sqlite-shm`
- `~/.omniroute/call_logs/` (histórico de chamadas JSON)
- `~/.omniroute/db_backups/` (backups automáticos internos)
- `~/.omniroute/logs/`
- tabelas de analytics/cache/histórico como `call_logs`, `usage_history`, `quota_snapshots`, `proxy_logs`, `xp_audit_log`, `model_intelligence`
- qualquer `backup.tar.gz` monolítico

## Restore em nova VPS

Depois de bootstrapar o dotfiles:

```bash
chezmoi apply
omniroute-sync pull
omniroute-restart
omniroute-health
```

`chezmoi apply` restaura o `.env`, o `config.sql` e o `manifest`. `omniroute-sync pull` injeta os dados do SQL no banco local.

## Regra mental

> O chezmoi restaura a inteligência de roteamento, credenciais e configurações/admin do OmniRoute, não o histórico de chamadas nem métricas mutáveis de runtime.

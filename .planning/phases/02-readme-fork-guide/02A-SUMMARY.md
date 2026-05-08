---
phase: 2
plan_id: 02A
title: "README — Guia de Fork e Personalização"
status: complete
---

# Plan 02A Summary: README — Guia de Fork e Personalização

## What was accomplished

- O stub `docs/FORK-GUIDE.md` foi completamente reescrito para servir como um *Hub/Índice* do processo de fork, contendo a checklist inicial e referências para os submódulos da documentação, além de explicar o que funciona "out-of-the-box".
- O novo arquivo `docs/fork/CHEZMOI-VARS.md` foi criado, abordando como modificar as variáveis de ambiente (`email`, `signingkey`) no arquivo principal do Chezmoi, e listando como personalizar a lista de repositórios `.chezmoidata/repos.json` bem como os pacotes de instalação do sistema operacional.
- O novo arquivo `docs/fork/SECRETS-GUIDE.md` foi criado para ensinar como utilizar o `age-keygen` para gerar a chave própria do usuário do fork e atualizar o recipient no arquivo `.chezmoi.yaml.tmpl`, com o passo a passo de como re-encriptar todos os segredos.

## Issues Encountered & Resolved
- Nenhuma. O projeto foi executado conforme as especificações e aprovação do usuário. Toda a infraestrutura descritiva bilíngue foi preservada.

## Testing / Verification
- O comando `grep` validou com sucesso os links formatados no `docs/FORK-GUIDE.md`, ambos apontando para os subdiretórios `fork/SECRETS-GUIDE.md` e `fork/CHEZMOI-VARS.md`.
- Os arquivos foram verificados com o comando `test -f`.

# Phase 1: Apply em todo perfil e CI - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-24
**Phase:** 01-apply-em-todo-perfil-e-ci
**Areas discussed:** Contexto Instivo e Arch, Plataforma do CI, Instaladores e shellcheck

---

## Contexto Instivo e Arch

Esclarecimento do usuário: não trabalha mais na Instivo; hoje trabalha na Zup, alocado no Itaú.

| Option | Description | Selected |
|--------|-------------|----------|
| Remover tudo | Apaga guard, scripts 655/554 e entradas do .chezmoiignore | |
| Remover guard, manter openvpn3 | Só a config da VPN Instivo sai | |
| Manter desativado | Deixa os arquivos com comentário de legado | ✓ |

| Option (coderabbit-cli 515) | Description | Selected |
|--------|-------------|----------|
| Máquina pessoal | Troca o guard por profile personal | |
| Pessoal e work | Instala em qualquer máquina com coding_assistants | |
| Remover o script | Não usa mais o coderabbit | ✓ |

| Option (Arch puro) | Description | Selected |
|--------|-------------|----------|
| Sim, incluir Arch puro | pacman/paru funcionam igual | |
| Não, só derivadas | Documenta o motivo no guard | |
| Você decide | Pesquisa verifica dependências das derivadas | ✓ |

---

## Plataforma do CI

| Option | Description | Selected |
|--------|-------------|----------|
| Forgejo Actions no Codeberg | `.forgejo/workflows/`, runner próprio como plano B | ✓ |
| Woodpecker (ci.codeberg.org) | Exige aprovação manual | |
| Espelho no GitHub Actions | Runners grátis, macOS real, mais um remoto | |
| Você decide | | |

**Gatilho:** Todo push em main ✓ (alternativas: push + hook pre-push; push + manual)
**macOS:** Linux com dados simulados ✓ (alternativa: runner macOS real)
**Profundidade:** o usuário escolheu primeiro "também apply em container"; depois, nas perguntas de detalhe, desistiu dos containers. Fica só renderização + lint.

---

## Instaladores e shellcheck

Esclarecimento do usuário: os arquivos `encrypted_*.asc` são criptografados pelo chezmoi e não devem ser mexidos.

| Option (lazygit/atuin/glab) | Description | Selected |
|--------|-------------|----------|
| Migrar para o mise | mise resolve versão/arch/macOS | |
| Manter scripts com jq | jq, curl -f, GITHUB_TOKEN | ✓ |
| Híbrido | | |

| Option (Ollama) | Description | Selected |
|--------|-------------|----------|
| Continua em script, com jq e curl -f | | ✓ |
| Instalador oficial no modo root | | |
| Você decide | | |

| Option (shellcheck) | Description | Selected |
|--------|-------------|----------|
| Severidade warning | Barra warning/error; corrige achados nesta fase | ✓ |
| Só severidade error | | |
| Tudo (inclui style) | | |

## Claude's Discretion

- Arch puro no `script_arch_based_only` e helper único para os testes inline de `osid`
- Formato dos dados simulados por perfil no CI
- Como o CI contorna os `.asc` sem alterá-los

## Deferred Ideas

- `chezmoi apply` em containers no CI
- Migrar instaladores para o mise

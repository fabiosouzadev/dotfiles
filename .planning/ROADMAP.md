# Roadmap: fabiosouzadev/dotfiles

**Criado:** 2026-05-07
**Modo:** Vertical MVP
**Fases:** 8 | **Requisitos v1:** 18

---

## Milestones

- ✅ **v1.0 Documentação & Manutenibilidade** — Fases 1-9 (concluído 2026-05-13)
- 📋 **v2.0 CI/CD & Automação** — Planejado

## Fases

<details>
<summary>✅ v1.0 Documentação & Manutenibilidade (Fases 1-9) — CONCLUÍDO 2026-05-13</summary>

### Fase 1: README — Estrutura Base e Quick Start
**Objetivo:** Entregar um README funcional com identidade visual, visão geral do projeto e comandos de instalação rápida por OS.
**Modo:** mvp
**Requisitos:** DOC-01, DOC-02, DOC-03, DOC-04, DOC-05, DOC-06, DOC-07
**Status:** ✅ Concluído

### Fase 2: README — Guia de Fork e Personalização
**Objetivo:** Tornar o repo fork-friendly com guia passo-a-passo de como adaptar os dotfiles para outro usuário.
**Modo:** mvp
**Requisitos:** DOC-08
**Status:** ✅ Concluído

### Fase 3: README — Cheatsheet de Keymaps do tmux
**Objetivo:** Documentar todos os keybindings customizados do tmux extraídos do `tmux.conf.tmpl`.
**Modo:** mvp
**Requisitos:** KEY-01
**Status:** ✅ Concluído

### Fase 4: README — Cheatsheet de Keymaps do Neovim
**Objetivo:** Documentar os keybindings principais do Neovim e integração com tmux.
**Modo:** mvp
**Requisitos:** KEY-02
**Status:** ⏭️ Ignorado (config externa)

### Fase 5: README — Cheatsheet de Zsh Keybindings e Aliases
**Objetivo:** Documentar aliases úteis e keybindings do zsh.
**Modo:** mvp
**Requisitos:** KEY-03
**Status:** ✅ Concluído

### Fase 6: Tech Debt — Correções Rápidas
**Objetivo:** Resolver itens de dívida técnica simples e de baixo risco.
**Modo:** mvp
**Requisitos:** DEBT-01, DEBT-02, DEBT-03, DEBT-04
**Status:** ✅ Concluído

### Fase 7: Tech Debt — Feature Flags para AI Tools
**Objetivo:** Tornar instalação de AI tools opt-in via feature flags, reduzindo tempo de setup e complexidade.
**Modo:** mvp
**Requisitos:** DEBT-05, DEBT-06
**Status:** ✅ Concluído

### Fase 8: Performance — Otimização do Shell Startup
**Objetivo:** Reduzir o tempo de startup do zsh com lazy-loading de ferramentas pesadas.
**Modo:** mvp
**Requisitos:** PERF-01
**Status:** ✅ Concluído

### Fase 9: Hermes Agent — Integração
**Objetivo:** Adicionar suporte ao Hermes Agent como ferramenta de IA opcional, integrada via feature flags.
**Modo:** mvp
**Requisitos:** HERME-01, HERME-02, HERME-03, HERME-04, HERME-05
**Status:** ✅ Concluído

## Progresso

| Fase | Milestone | Planos Concluídos | Status | Concluído |
|------|-----------|-------------------|--------|-----------|
| 1. README Base | v1.0 | 1/1 | Complete | 2026-05-13 |
| 2. Fork Guide | v1.0 | 1/1 | Complete | 2026-05-13 |
| 3. tmux Keymaps | v1.0 | 1/1 | Complete | 2026-05-13 |
| 4. nvim Keymaps | v1.0 | 0/1 | Ignorado | - |
| 5. zsh Keymaps | v1.0 | 1/1 | Complete | 2026-05-13 |
| 6. Tech Debt Fix | v1.0 | 1/1 | Complete | 2026-05-13 |
| 7. Feature Flags | v1.0 | 1/1 | Complete | 2026-05-13 |
| 8. Shell Performance | v1.0 | 1/1 | Complete | 2026-05-13 |
| 9. Hermes Agent | v1.0 | 1/1 | Complete | 2026-05-13 |

## Dependências entre Fases

```
Fase 1 (README Base) ─────→ Fase 2 (Fork Guide)
                      ├───→ Fase 3 (tmux Keymaps)
                      ├───→ Fase 4 (nvim Keymaps)
                      └───→ Fase 5 (zsh Keymaps)

Fase 6 (Correções Rápidas) ── independente
Fase 7 (Feature Flags) ────── independente (mas depois de Fase 6 recomendado)
Fase 8 (Shell Startup) ────── independente (mas depois de Fase 7 recomendado)
Fase 9 (Hermes) ───────────── independente (mas depois de Fase 7 recomendado)
```

**Nota:** Fases 2-5 dependem de Fase 1 (estrutura do README). Fases 6-9 são independentes e podem rodar em paralelo com as fases de documentação.

</details>

## Próximos Passos

### 🚧 v2.0 CI/CD & Automação (Planejado)

- [ ] GitHub Actions para `chezmoi apply --dry-run` em containers multi-OS
- [ ] ShellCheck linting para scripts `.sh.tmpl`
- [ ] Testes automatizados de instalação

---

*Última atualização: 2026-05-22*
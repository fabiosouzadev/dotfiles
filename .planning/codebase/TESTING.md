# Testing — Testes e Validação

> Estratégias de teste, verificação e validação para o repositório de dotfiles.

## Visão Geral

Como dotfiles afetam o ambiente inteiro do usuário, o teste é **primariamente manual** e foca em **idempotência** e **compatibilidade cross-platform**. Não há CI pipeline configurada atualmente.

## Nível de Cobertura

| Categoria | Status | Notas |
|-----------|--------|-------|
| Dry-run verification | ✅ Suportado | `chezmoi apply --dry-run --verbose` |
| Idempotency check | ✅ Suportado | `chezmoi apply` 2x deve ser idêntico |
| Template compilation | ✅ Verificável | `chezmoi apply` falha se template não compilar |
| Cross-platform validation | ⚠️ Manual | Requer VM/container para outras plataformas |
| Script execution | ⚠️ Manual | Scripts de bootstrap testados via apply |
| CI pipeline | ❌ Não configurado | Nenhum pipeline automatizado |
| Unit tests | ❌ Não existentes | Scripts shell sem testes unitários |
| Integration tests | ❌ Não existentes | |
| E2E validation | ❌ Não existentes | |

## Procedimentos de Teste

### 1. Dry-Run Verification (Pré-requisito obrigatório)

Antes de aplicar qualquer mudança, execute:

```bash
chezmoi apply --dry-run --verbose
```

Verifique a saída para:
- [ ] Resolução correta de caminhos (especialmente em diferentes SOs)
- [ ] Expansão correta de variáveis (feature flags, condicionais)
- [ ] Nenhuma exclusão inesperada de arquivos
- [ ] Templates compilam sem erros
- [ ] Scripts de bootstrap são gerados corretamente

### 2. Idempotency Check

Aplique as mudanças e verifique que a segunda aplicação não faz nada:

```bash
chezmoi apply
chezmoi apply  # Deve não produzir output ou mudanças
```

### 3. Diff Check

Compare o estado gerenciado com o diretório home atual:

```bash
chezmoi diff
```

Deve mostrar apenas as diferenças desejadas.

### 4. Template Execution Test

Para testar scripts de bootstrap isoladamente:

```bash
chezmoi execute-template < home/.chezmoiscripts/.../script.sh.tmpl > /tmp/test.sh
bash /tmp/test.sh
```

### 5. Cross-Platform Validation

Para scripts compartilhados em `home/.chezmoiscripts/unix/`:

- Verifique em pelo menos uma outra plataforma (VM ou Docker)
- macOS changes → testar via VM macOS ou Docker macOS
- Linux changes → testar via Docker Linux
- Verifique que guards (`script_is_not_ephemeral`, `script_is_not_headless`) funcionam corretamente

## Checklists de Smoke Test

### Após `chezmoi apply` bem-sucedido:

```bash
# Shell
zsh --version                     # Zsh instalado
echo $SHELL                       # Zsh como shell padrão
source ~/.zshrc                   # Zsh carrega sem erros

# Ferramentas CLI
eza --version                     # File listing
bat --version                     # Cat melhorado
fzf --version                     # Fuzzy finder
lazygit --version                 # Git TUI
delta --version                   # Diff beautifier
glab --version                    # GitLab CLI
mise --version                    # Runtime version manager

# AI Tools (se habilitados)
claude --version                  # Claude Code
aider --version                   # Aider
codex --version                   # OpenAI Codex

# Configurações
which nvim                        # Neovim acessível
tmux -V                           # tmux instalado
starship --version                # Starship prompt

# SSH
ssh -T git@github.com             # GitHub acessível
```

### Verificação de Segredos:

```bash
# Verificar que a chave age existe localmente
test -f ~/.config/chezmoi/key.txt && echo "OK" || echo "MISSING"

# Verificar que segredos são descriptografados
chezmoi cd
ls home/private_dot_ssh/          # Deve mostrar arquivos descriptografados aplicados
```

### Verificação de Services (se aplicável):

```bash
# systemd user services (Linux)
systemctl --user status hermes-dashboard
systemctl --user status omniroute
```

## Troubleshooting

### Script falha durante `chezmoi apply`

1. Verifique o output do script no terminal
2. Execute o script manualmente para isolar o erro:
   ```bash
   chezmoi execute-template < home/.chezmoiscripts/.../script.sh.tmpl > /tmp/test.sh
   bash /tmp/test.sh
   ```
3. Verifique se variáveis de ambiente necessárias estão definidas em `.chezmoi.yaml.tmpl`

### Template não compila

```bash
chezmoi apply --dry-run --verbose 2>&1 | grep -i "error\|template\|fail"
chezmoi cd
chezmoi edit <arquivo>            # Para debug interativo
```

### Idempotência falha

- Verifique scripts `run_once_*` que podem não ter verificação de execução prévia
- Verifique `run_onchange_*` que podem ter side-effects em cada execução

### Cross-platform failures

- Verifique se guards de SO estão corretos (`eq .chezmoi.os "darwin"`, etc.)
- Verifique se scripts `unix/` realmente funcionam no macOS
- Verifique se feature flags são apropriadas para cada plataforma

## Áreas sem Teste Automatizado (Risco)

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Sem CI pipeline | Mudanças podem quebrar bootstrap | Dry-run rigoroso antes de cada commit |
| Scripts shell não testados | Falhas em bootstrap cross-platform | Manual testing em cada SO |
| Segredos criptografados | Aplicação falha se key errada | Verificar `chezmoi apply` após key change |
| Templates complexos | Lógica incorreta em runtime | Revisão cuidadosa de `.chezmoi.yaml.tmpl` |
| Feature flag interactions | Features conflitantes | Documentação clara de dependências |

## Melhorias Futuras de Teste

1. **CI Pipeline**: Adicionar GitHub Actions para validar:
   - Compilação de templates em cada commit
   - `chezmoi diff` vazio em dry-run (sem drift)
   - Shellcheck nos scripts shell
   - yamllint/jsonlint nos dados
2. **Unit Tests**: Shellunit/bats para scripts de bootstrap
3. **Snapshot Tests**: Capturar output esperado dos templates
4. **Cross-Platform CI**: Matrix de OS no CI (Ubuntu, macOS, Windows via Actions)

## Versão do Documento

Gerado automaticamente pelo gsd-map-codebase em 2026-09-16.

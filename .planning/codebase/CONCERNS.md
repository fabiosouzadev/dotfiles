# Concerns — Preocupações, Riscos e Pontos de Atenção

> Riscos identificados, vulnerabilidades, limitações e áreas de atenção no repositório.

## Riscos de Segurança

### 1. Segredos Criptografados (Risco: ALTO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| Chave age no repo | A chave pública do autor está no `.chezmoi.yaml.tmpl` | Fazer fork exige gerar nova chave age |
| Re-criptografia necessária | Todos os `encrypted_*` arquivos usam a chave do autor | Usar `chezmoi add --encrypt` com nova chave |
| Segredos no history do Git | Commits anteriores podem conter segredos | Bateroria (battery) de rebase/rewrite ao fazer fork |
| Tokens de API em Zsh | `504-zup.zsh.tmpl` contém ~20 tokens corporativos (Zup) | Criptografados com age, descriptografados no apply |
| SSH private keys | 3 pares de chaves (pessoal, zup, vps) | Criptografados com age |

### 2. Configuração de SSH (Risco: MÉDIO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| Chaves múltiplas | 3 chaves SSH diferentes gerenciadas | Cada uma criptografada com age |
| Known hosts template | `private_known_hosts.tmpl` | Template, não arquivo estático |
| Readonly key | `private_readonly_ssh-key-oracle-dev-2.key.pub` | Public key, sem risco |

### 3. Configuração de Git (Risco: BAIXO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| GPG signing habilitado | `gpgsign = true` em todos os commits | Depende de chave GPG configurada localmente |
| Multi-include git config | Complexidade de includes condicionais | Bem documentado, templates testados |

## Riscos de Funcionalidade

### 4. Detecção de Ambiente (Risco: MÉDIO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| Detecção de VPS imprecisa | Baseada em hostname patterns | Forçável via `CHEZMOI_VPS` env var |
| Work machine hostname hardcoded | `"zwpe0f96cn"` específico do autor | Deve ser alterado em forks |
| Hardware-specific detection | Dell3530/3520 hostname patterns | Deve ser alterado em forks |
| GUI detection em WSL | Depende de probes X11 | Pode falhar em ambientes headless WSL |
| Container detection | Usa `/proc/1/cgroup` grep | Pode ser incompleto para alguns containers |

### 5. Idempotência (Risco: MÉDIO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| Scripts `run_once_*` sem verificação | Podem re-executar ações sem idempotência | Rever cada script para verificação |
| `run_onchange_*` scripts | Re-executam quando dados mudam, mas podem ter side-effects | Testes manuais necessários |
| Mise install script | Remove instalação antes de reinstalar | Design intencional, mas pode falhar |

### 6. Cross-Platform (Risco: ALTO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| Sem CI pipeline | Nenhuma validação automática cross-platform | Dry-run rigoroso |
| Scripts Windows não testados | PowerShell templates existem | Requer teste em Windows |
| Termux específico | Android-specific scripts | Requer dispositivo Termux |
| Numeração de scripts cross-SO | Mesma numeração pode não se aplicar | Scripts organização por SO |

## Riscos de Manutenção

### 7. Complexidade do `.chezmoi.yaml.tmpl` (Risco: ALTO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| Template muito grande | 280 linhas de Go template complexo | Documentar seções, dividir em partes |
| Lógica de detecção complexa | 20+ variáveis condicionais | Adicionar comments por seção |
| Debug output em template | Escreve para stdout durante apply | Apenas em TTY interativo (controlado) |
| Hardcoded hostnames | "zwpe0f96cn", "dell3530", "dell3520" | Deve ser parametrizado em forks |

### 8. Acoplamento entre Componentes (Risco: MÉDIO)

| Acoplamento | Detalhe | Impacto |
|------------|---------|---------|
| Zsh → Zinit | Zsh depende de Zinit | Se Zinit falha, zsh não funciona |
| Chezmoi → age | Secrets dependem de age | Se age não instalado, apply falha |
| Hermes → systemd | Dashboard requer systemd | Não funciona em macOS sem systemd |
| OmniRoute → Node/mise | Requer source build | Se mise falha, OmniRoute não inicia |
| Coding Orchestrator → Hermes | Skill do Hermes | Se Hermes falha, orquestrador falha |
| Ollama → sudo (root mode) | Requer acesso root | Não funciona em managed machines |

### 9. Dependências Externas (Risco: BAIXO)

| Preocupação | Detalhe | Mitigação |
|------------|---------|-----------|
| `.chezmoiexternals/` | 7 dependências externas gerenciadas por chezmoi | Verificar URLs no chezmoi docs |
| URL de install scripts | curl install de várias ferramentas | URLs podem expirar/mudar |
| Nerd Font dependency | Requer fonte específica para ícones | Documentado em README |

## Limitações Conhecidas

| Limitação | Impacto | Workaround |
|-----------|---------|------------|
| Sem CI pipeline | Sem validação automática | Dry-run manual |
| Sem testes unitários | Sem regression tests para scripts | Manual testing |
| Sem testes cross-platform | Funcionalidade não validada em todas as plataformas | VMs/containers |
| Repositório público com segredos | Segredos criptografados mas visíveis | Re-criptografar em fork |
| Sem documentação de rollback | Sem procedimento para reverter mudanças | Git history |
| Templates com lógica Go | Não é possível testar templates isoladamente | `chezmoi execute-template` |

## Dependências Críticas

```
chezmoi (OBRIGATÓRIO)
  ├── age (OBRIGATÓRIO se usar secrets)
  ├── zsh (OBRIGATÓRIO para shell)
  ├── gpg (OBRIGATÓRIO se usar GPG)
  └── git (OBRIGATÓRIO)
  └── curl (OBRIGATÓRIO para install scripts)

Zinit (CRÍTICO para shell)
  ├── starship (prompt)
  ├── eza (listing)
  ├── ripgrep (search)
  ├── fd (file finder)
  ├── bat (cat alternativo)
  └── fzf (fuzzy finder)

Hermes (IMPORTANTE para IA)
  └── OmniRoute (CRÍTICO para agentes)
  └── Coding Orchestrator (CRÍTICO para execução autônoma)
```

## Condições de Falha Conhecidas

1. **`chezmoi apply` falha** → Verificar idade key em `~/.config/chezmoi/key.txt`
2. **Templates não compilam** → Verificar variáveis em `.chezmoi.yaml.tmpl`
3. **Scripts não executam** → Verificar permissões (`chmod +x`) e guards (`script_is_not_headless`)
4. **Secrets não descriptografam** → Verificar que key age corresponde ao recipient no template
5. **Zsh não carrega** → Verificar Zinit installation em `~/.local/share/zinit/zinit.git`

## Plano de Mitigação Recomendado

1. **Curto prazo**: Adicionar CI pipeline para validação de templates e dry-run
2. **Curto prazo**: Adicionar testes unitários (bats/shellunit) para scripts críticos
3. **Médio prazo**: Dividir `.chezmoi.yaml.tmpl` em templates menores modulares
4. **Médio prazo**: Documentar procedimentos de rollback
5. **Longo prazo**: Implementar testes cross-platform via CI matrix
6. **Longo prazo**: Adicionar snapshot tests para templates críticos

## Versão do Documento

Gerado automaticamente pelo gsd-map-codebase em 2026-09-16.

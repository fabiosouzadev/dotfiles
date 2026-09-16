# Conventions — Convenções e Padrões

> Padrões de codificação, nomenclatura, branching e práticas de manutenção do repositório.

## Convenções de Commit

O repositório segue **Conventional Commits** (https://www.conventionalcommits.org/):

```
<tipo>(<escopo>): <descrição>
```

Exemplos dos commits recentes:
- `chore(gsd): cleaning codebase` — tarefa de manutenção
- `chore(qdrant): change memory` — atualização de componente
- `chore(omniroute): change memory` — atualização de componente
- `chore(hermes): change model` — atualização de configuração
- `chore(hermes): add configs` — adição de configuração
- `chore(claude): add configs` — adição de configuração
- `chore(codex): add configs` — adição de configuração

**Tipos esperados:**
- `feat`: nova funcionalidade
- `fix`: correção de bug
- `chore`: manutenção, limpeza, atualização de dependências
- `docs`: mudança apenas em documentação
- `refactor`: refatoração sem mudança de comportamento
- `test`: adição/atualização de testes

## Convenções de Nomenclatura de Arquivos

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Scripts de bootstrap | `run_{once|onchange}_{before|after}_NNN-{name}.{sh,ps1}.tmpl` | `run_once_after_503-install-mise.sh.tmpl` |
| Configuração zsh modular | `NNN-{name}.zsh.tmpl` | `200-aliases.zsh.tmpl`, `606-hermes.zsh.tmpl` |
| Templates de config | `{nome}.tmpl` | `dot_zshrc.tmpl`, `config.tmpl` |
| Segredos | `encrypted_{nome}.asc` | `encrypted_omniroute-key.txt.asc` |
| Binários executáveis | `executable_{nome}` | `executable_omniroute-sync` |
| Dotfiles | `dot_{nome}` | `dot_zshrc`, `dot_bashrc` |
| Dados privados | `private_dot_{nome}` | `private_dot_ssh`, `private_dot_config` |

## Padrões de Template (Go text/template)

### Estrutura de Templates

```go
{{- /* Comentário */ -}}
{{- $var := expression -}}
{{- if condition -}}
  ...
{{- else -}}
  ...
{{- end }}
{{- range .items -}}
  {{ .field }}
{{- end }}
{{ template "name" . }}
```

### Condições de Guarda em Scripts

Todos os scripts de bootstrap começam com templates de guarda:

```bash
{{ template "common/script_is_not_ephemeral" . }}  # Exit 0 em CI/cloud IDEs
{{ template "common/script_is_not_headless" . }}   # Exit 0 sem GUI
{{ template "workplace/script_is_not_vps" . }}     # Exit 0 em VPS
{{ template "workplace/script_is_not_zup" . }}     # Exit 0 no workplace Zup
```

**Regra**: Scripts que dependem de GUI ou interação humana DEVERIAM ter `script_is_not_headless`. Scripts para ambientes controlados DEVERIAM ter `script_is_not_vps` ou `script_is_not_zup` conforme aplicável.

### Convenção de Debug Output

Saída de debug APENAS em TTY interativo:

```go
{{- if $interactiveTTY -}}
{{- writeToStdout "Debug info\n" -}}
{{- end -}}
```

## Padrões de Configuração

### Git Config (Multi-Profile)

Usa `includeIf` para configuração por contexto:

- **Personal**: `~/.config/git/config.personal.inc`
- **Work (Zup)**: `~/.config/git/config.zup.inc`
- **VPS**: `~/.config/git/config.vps.inc`
- **GitLab agent**: `~/.config/git/config.agents.inc`
- **Personal SSH**: `~/.config/git/config.personal-ssh.inc`

### Segredos

1. Todos os segredos são criptografados com **age** no Git
2. A descriptografia é feita automaticamente pelo chezmoi durante `chezmoi apply`
3. A chave age é armazenada LOCALMENTE em `~/.config/chezmoi/key.txt` (NÃO versionada)
4. Variáveis de ambiente secretas são mantidas em arquivos `.asc` descriptografados via `{{ include "path" | decrypt | trim }}`
5. Cada ambiente/workplace pode ter chaves diferentes (ex: `encrypted_omniroute-key.txt.asc` vs `encrypted_omniroute-key-zup.txt.asc`)

### Zsh Modular

- Arquivos numerados `NNN-name.zsh.tmpl` em `dot_zshrc.d/`
- Carregados em ordem numérica pelo `dot_zshrc.tmpl`
- Cada arquivo tem responsabilidade única
- Templates Go usam `{{ if .settings.featureFlag }}` para ativar/desativar

## Convenções de Branching

| Branch | Uso |
|--------|-----|
| `main` | Branch estável com setup atual |
| `feat/*` | Novas funcionalidades ou ferramentas |
| `fix/*` | Correções de bugs |
| `docs/*` | Mudanças apenas em documentação |

## Processo de Desenvolvimento

1. Crie uma branch: `git checkout -b feat/my-new-feature`
2. Faça alterações em `home/`
3. Teste localmente: `chezmoi apply --dry-run --verbose`
4. Aplique: `chezmoi apply`
5. Verifique que templates compilam corretamente
6. Commit seguindo Conventional Commits
7. Abra PR contra `main`

## Processo de Adição de Scripts

Ao adicionar novos scripts de bootstrap:

1. Escolha o número adequado deixando gaps para futuras inserções
2. Coloque no diretório correto por SO: `darwin/`, `linux/`, `unix/`, `windows/`, `termux/`
3. Adicione guard template se necessário (`script_is_not_ephemeral`, etc.)
4. Use helpers: `{{ template "common/script_helper" . }}` para funções `info`, `success`, `warn`
5. Verifique idempotência: o script deve ser seguro para execução múltipla

## Convenções de Idempotência

- **Scripts `run_once_*`**: Devem verificar se já foram executados antes de fazer alterações
- **Scripts `run_onchange_*`**: Executam no apply; re-executam quando o arquivo de dados associado muda
- **Templates**: Sempre geram o mesmo output para a mesma entrada
- **Aplicação**: `chezmoi apply` duas vezes deve produzir resultado idêntico na segunda vez (verificável via `chezmoi diff`)

## Convenções de Documentação

| Documento | Localização | Conteúdo |
|-----------|-------------|----------|
| README.md | Raiz | Visão geral, quick start, integrações |
| docs/ARCHITECTURE.md | docs/ | Arquitetura e fluxos |
| docs/CONFIGURATION.md | docs/ | Variáveis e feature flags |
| docs/GETTING-STARTED.md | docs/ | Instalação passo a passo |
| docs/DEVELOPMENT.md | docs/ | Como contribuir |
| docs/TESTING.md | docs/ | Testes e verificação |
| docs/HERMES-BACKUP.md | docs/ | Modelo de backup Hermes |
| docs/OMNIROUTE-BACKUP.md | docs/ | Modelo de backup OmniRoute |
| docs/KEYMAPS.md | docs/ | Atalhos de teclado |
| docs/FORK-GUIDE.md | docs/ | Guia de fork |
| docs/fork/CHEZMOI-VARS.md | docs/fork/ | Guia de variáveis |
| docs/fork/SECRETS-GUIDE.md | docs/fork/ | Guia de segredos |

## Convenções de Segredos

1. **Nunca** commite a chave age (`key.txt`) no Git
2. **Sempre** criptografe com age antes de commitar
3. **Use** `chezmoi add --encrypt` para adicionar novos segredos
4. **Revise** scripts antes de aplicar em produção (especialmente em forks)
5. **Gere** uma nova chave age ao fazer fork: `age-keygen -o ~/.config/chezmoi/key.txt`
6. **Re-criptografe** todos os arquivos `encrypted_` com sua nova chave pública

## Convenções de Feature Flags

Features são controladas por flags em `.chezmoi.yaml.tmpl` ou `ai_tools.yaml`:

```yaml
# Em .chezmoi.yaml.tmpl
features:
  ai:
    coding_assistants: true
    spec_tools: true
    gsd: true
    multiplexer: true
    ollama:
      install: true
      mode: user
```

Scripts verificam flags assim:
```go
{{- if $.features.ai.coding_assistants }}
  # instalar ferramentas de IA
{{- end }}
```

## Versão do Documento

Gerado automaticamente pelo gsd-map-codebase em 2026-09-16.

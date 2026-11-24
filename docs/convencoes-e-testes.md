# Convenções e testes

Este documento descreve os padrões que o repositório realmente segue (nomes, estrutura dos scripts, templates, segredos) e como validar uma mudança antes de aplicá-la. O resumo das convenções e os comandos básicos de desenvolvimento estão no [README](../README.md#desenvolvimento); aqui está o detalhe.

> Escopo: tudo que está versionado em `home/`. O diretório `.claude/` (instalação local do GSD, com hooks em JavaScript) está no `.gitignore` e segue as convenções do projeto GSD, não as deste repositório.

---

## 1. Nomes de arquivos

### Atributos do chezmoi

| Prefixo / sufixo | Efeito | Exemplo |
|------------------|--------|---------|
| `dot_` | vira `.` no destino | `dot_zshrc.tmpl` → `~/.zshrc` |
| `private_` | permissão restrita (sem acesso de grupo/outros) | `private_dot_config/`, `private_dot_ssh/` |
| `executable_` | bit de execução | `dot_local/bin/executable_hermes-sync` |
| `encrypted_` + `.asc` | arquivo criptografado com GPG (ASCII armor) | `dot_keys/encrypted_wakatime-key.txt.asc` |
| `.tmpl` | renderizado como template Go | `dot_m2/settings.xml.tmpl` |

Os prefixos se combinam na ordem que o chezmoi exige: `encrypted_private_dot_env.asc`, `private_dot_wakatime.cfg.tmpl`.

### Scripts

Formato: `run_<frequência>_<momento>_<NNN>-<verbo>-<alvo>.<ext>.tmpl`

- **Frequência:** `once` (roda uma vez por conteúdo) ou `onchange` (roda quando o conteúdo renderizado muda).
- **Momento:** `before` (antes de gravar os arquivos) ou `after`.
- **`NNN`:** número de três dígitos na faixa da categoria (tabela no [README](../README.md#faixas-de-numeração-dos-scripts)).
- **Verbo:** `install`, `configure`, `compile`, `init`, `clone`.
- **Extensão:** `.sh.tmpl` para bash, `.ps1.tmpl` para PowerShell.

O diretório define a plataforma: `linux/`, `darwin/`, `windows/`, `termux/`, `vps/` e `unix/` (Linux + macOS). O `.chezmoiignore.tmpl` exclui os diretórios que não se aplicam à máquina atual.

Há exceções históricas sem extensão `.sh` (`run_once_before_104-install-cirrus-driver-for-macbook.tmpl`, `223-compile-nvim.tmpl`, `224-compile-tmux.tmpl`); em scripts novos, use sempre `.sh.tmpl`.

### Módulos do zsh

`home/dot_zshrc.d/NNN-nome.zsh.tmpl`, carregados em ordem alfabética. O número define a ordem e o agrupamento (`1xx` base do shell, `2xx` aliases e histórico, `3xx` integrações e chaves, `4xx` chaves por contexto, `5xx` trabalho, `6xx` ferramentas de IA, `999` completions por último). Módulos com segredo são `encrypted_NNN-nome.zsh.asc`.

### Dados

`home/.chezmoidata/` usa um arquivo por assunto na raiz (`ai_tools.yaml`, `ollama.yaml`, `idea.yaml`, `repos.json`) e subdiretórios por plataforma (`linux/packages/archlinux.yaml`, `windows/packages.yaml`, `vps/features.yaml`). YAML, JSON e TOML convivem; escolha o formato do arquivo vizinho.

---

## 2. Anatomia de um script bash

Esqueleto usado pela maioria dos scripts (ex.: `vps/run_once_after_531-install-agentmemory.sh.tmpl`):

```bash
#!/usr/bin/env bash
# vim: filetype=bash

set -euo pipefail

{{ template "common/script_is_not_ephemeral" . }}
{{ template "linux/script_linux_only" . }}
{{ template "common/script_helper" . }}
{{ template "workplace/script_is_vps" . }}

{{ if not .features.algo.enabled }}
info ">> Algo: feature flag disabled, skipping <<"
exit 0
{{ end }}

if command -v algo &> /dev/null; then
    info "Algo already installed, skipping."
    exit 0
fi

info ">> Installing algo <<"
# ...
success "Algo installed."
```

Regras que esse esqueleto expressa:

1. **Shebang** sempre `#!/usr/bin/env bash`.
2. **Modo estrito**: `set -euo pipefail`. O template `common/script_helper` já define isso, então todo script que o inclui fica em modo estrito mesmo sem a linha explícita.
3. **Guards antes de qualquer efeito colateral.** Cada guard em `home/.chezmoitemplates/` vira um `exit 0` renderizado quando a condição não se aplica. Um script que não se aplica sai com sucesso, nunca com erro.
4. **`script_helper` antes de `script_is_vps` / `script_is_not_vps`**, porque esses dois guards chamam `info`.
5. **Feature flag com mensagem**: ao pular por flag, registre com `info` e saia com `exit 0`.
6. **Idempotência**: verifique se a ferramenta já existe (`command -v`, diretório presente) antes de instalar. Operações opcionais que podem falhar sem prejuízo terminam em `|| true` (ex.: `systemctl --user enable --now ... || true`).
7. **Saída padronizada** com `info`, `warn`, `error` e `success` (cores ANSI definidas em `common/script_helper`). Mensagens de log costumam ser em inglês; comentários podem ser em português ou inglês.

### Guards disponíveis

| Template | Sai quando |
|----------|-----------|
| `common/script_is_not_ephemeral` | `settings.ephemeral` (CI, Codespaces, devcontainer…) |
| `common/script_is_not_headless` | `settings.headless` |
| `linux/script_linux_only` | `osid` não contém `linux` |
| `linux/script_arch_based_only` | `osid` não contém `endeavouros` nem `cachyos` |
| `linux/script_ubuntu_only` | `osid` não contém `ubuntu` |
| `darwin/script_darwin_only` | não é macOS |
| `windows/script_windows_only` | não é Windows |
| `workplace/script_is_vps` / `script_is_not_vps` | não é / é VPS |
| `workplace/script_is_zup` / `script_is_not_zup` | `workplace` não é / é `Zup` |
| `workplace/script_is_instivo` | `workplace` não é `Instivo` |

Outros templates utilitários: `common/script_eval_mise` (ativa os shims do mise) e `common/script_validate_completions_path` (cria os diretórios de completions de zsh e bash).

> Observação: `home/.chezmoi.yaml.tmpl` só atribui `workplace` como `Zup` ou `Itau`. Nenhuma máquina recebe `Instivo` hoje, então scripts com `script_is_instivo` sempre saem.

---

## 3. Anatomia de um script PowerShell

Exemplo: `windows/run_onchange_before_202-install-scoop-packages.ps1.tmpl`.

- Primeira linha: comentário com o próprio nome do arquivo e uma descrição curta.
- `$ErrorActionPreference = 'Stop'` logo após os gates de template.
- Funções locais de log: `Write-Info`, `Write-Ok`, `Write-Warn`.
- Idempotência com `Get-Command ... -ErrorAction SilentlyContinue` e checagem de buckets/pacotes já presentes.
- Scripts `run_onchange_` que leem dados incluem um comentário de hash para que mudanças nos dados disparem o script:

```powershell
# Hash: {{ .packages.windows.scoop | toJson | sha256sum }}
```

No bash, os scripts de pacotes renderizam a lista diretamente no corpo do script (`{{ range .packages.linux.arch.core }}`), o que já muda o conteúdo quando os dados mudam.

---

## 4. Convenções de template

- **Whitespace**: use `{{-` e `-}}` em blocos de lógica para não deixar linhas em branco no arquivo gerado. `home/.chezmoi.yaml.tmpl` é o exemplo mais completo.
- **Caminhos**: derive de `.chezmoi.homeDir` ou `.chezmoi.sourceDir` com `joinPath`, e normalize barras com `| replace "\\" "/"` quando o valor for usado também no Windows. Não escreva caminhos absolutos fixos.
- **Dados calculados**: a detecção de ambiente fica em `home/.chezmoi.yaml.tmpl` e é exposta como `.settings.*`, `.dirs.*`, `.features.*` e `.gpg.*`. Use `chezmoi data` para ver os valores na máquina atual.
- **Feature flags**: `.features.*` vem de duas fontes que são mescladas: o dicionário `features` de `home/.chezmoi.yaml.tmpl` (sudo, systemd, ollama, i3, niri…) e os arquivos em `home/.chezmoidata/` (`features.ai.*`, `features.hermes.*`, `features.tailscale`, `features.dockge`, `features.idea`, `features.repos`).
- **Gate primeiro por flag, depois por ambiente**, como diz o README; em templates de config, envolva o arquivo inteiro num `{{ if }}` quando ele só faz sentido em um contexto (ex.: `dot_zshrc.d/504-zup.zsh.tmpl` começa com `{{- if eq .settings.workplace "Zup" -}}`).
- **Segredos em templates**: nunca escreva o valor; leia de um arquivo criptografado.

```text
{{- $key := joinPath .chezmoi.sourceDir "dot_keys" "encrypted_omniroute-key.txt.asc" -}}
"token": "{{ include $key | decrypt | trim }}"
```

  Quando o segredo depende do contexto, troque o caminho com um `if` antes de usar (padrão usado para a chave Zup em `dot_claude/settings.json.tmpl`).

### Armadilhas de template

- **`:=` versus `=`**: dentro de `{{ if }}`, `{{ $x := ... }}` cria uma variável nova que some ao fim do bloco. Para reatribuir, use `{{ $x = ... }}`. Esse erro existe hoje em `unix/run_once_after_590-install-ai-tools.sh.tmpl` (flags `multiplexer` no bloco npm e `composio.install`), fazendo essas entradas nunca serem instaladas.
- **Chave inexistente é erro**: o chezmoi renderiza com `missingkey=error`. `{{ .features.ai.hermes.dashboard.port }}` falha com `map has no entry for key "hermes"`, e `| default` não ajuda porque o erro acontece no acesso. Use `hasKey` ou `dig` para chaves opcionais. Casos atuais:
  - `home/.chezmoitemplates/common/caddyfile_hermes.tmpl` referencia `.features.ai.hermes.*`, que não existe. Hoje nenhum arquivo inclui esse template, por isso não quebra.
  - `home/dot_zshrc.d/termux.zsh.tmpl` lê `.features.ai.omniroute.domain`, que também não existe. Só é avaliado quando `settings.termux` é verdadeiro, ou seja, deve falhar justamente no Termux.
- **`.chezmoidata` é global**: todos os arquivos, inclusive `vps/features.yaml`, são carregados em qualquer máquina. Restrinja por guard ou pelo `.chezmoiignore.tmpl`, não pelo diretório do dado.
- **Ordem de avaliação**: o `.chezmoiignore.tmpl` decide o que entra; um script ignorado ali nunca roda, mesmo que seus guards passassem.

---

## 5. Segredos

Resumo prático (o procedimento básico está no [README](../README.md#segredos)):

- Criptografia: GPG, configurada em `home/.chezmoi.yaml.tmpl` (`encryption: gpg`). Não use `age` neste repositório, mesmo com o binário instalado.
- Chaves soltas (uma linha) ficam em `home/dot_keys/encrypted_<nome>-key.txt.asc` e são consumidas com `include | decrypt | trim`.
- `.env` de stacks ficam ao lado do `compose.yaml.tmpl` como `encrypted_dot_env.asc`.
- Variáveis de ambiente sensíveis vão em módulos `home/dot_zshrc.d/encrypted_NNN-*.zsh.asc`; o módulo de trabalho em texto claro (`504-zup.zsh.tmpl`) apenas **mapeia** variáveis já definidas por eles (`export X=$ZUP_X`).
- Nunca coloque token, senha ou chave em `.tmpl` em texto claro, nem em comentários de exemplo.

---

## 6. Testes e validação

### Estado atual

Não há suíte de testes automatizados, linter configurado nem CI neste repositório: não existe `.github/`, pipeline de GitLab, configuração de `shellcheck` ou arquivo de testes. As variáveis de CI (`GITHUB_ACTIONS`, `GITLAB_CI`…) aparecem só na detecção de ambiente efêmero do `home/.chezmoi.yaml.tmpl`.

A validação é manual, usando o próprio chezmoi.

### Checklist antes de commitar

| Passo | Comando | O que pega |
|-------|---------|-----------|
| Renderizar o template alterado | `chezmoi execute-template < home/caminho/arquivo.tmpl` | erros de sintaxe, chaves inexistentes, whitespace |
| Conferir os dados que o template vê | `chezmoi data` | perfil, `osid`, flags efetivas na máquina |
| Ver o diff do que mudaria | `chezmoi diff` | arquivos alterados inesperadamente |
| Simular o apply completo | `chezmoi apply --dry-run --verbose` | scripts que rodariam, ordem, erros de template em todos os arquivos |
| Checar a instalação do chezmoi | `chezmoi doctor` | GPG ausente, versão, config |

`chezmoi execute-template` também aceita uma expressão pela entrada padrão, útil para testar uma condição isolada:

```bash
echo '{{ .settings.profile }} {{ .settings.osid }}' | chezmoi execute-template
```

### Validar um script

1. Renderize e leia o resultado: `chezmoi execute-template < home/.chezmoiscripts/unix/run_once_after_NNN-x.sh.tmpl`. Um script que não se aplica à máquina deve renderizar com um `exit 0` logo no início.
2. Opcional: passe o resultado por `bash -n` (sintaxe) ou, se instalado, `shellcheck -s bash -`.
3. Para reexecutar um `run_once_` já executado: `chezmoi state delete-bucket --bucket=scriptState`.

### Validar em outros perfis

Os overrides de ambiente permitem simular outra máquina sem trocar de host:

```bash
CHEZMOI_PROFILE=vps CHEZMOI_VPS=1 chezmoi apply --dry-run --verbose
CHEZMOI_FORCE_HEADLESS=1 chezmoi diff
```

Limitações: `osid`, `workplace` e o sistema operacional vêm do host real; `CHEZMOI_VPS` só é avaliado em Linux, e `CHEZMOI_PROFILE=vps` sozinho muda `settings.profile` mas não `settings.vps` (que é o que os guards de VPS consultam). Para testar Ubuntu ou Arch de verdade, use um container ou VM (Distrobox e Lima são detectados como container e marcam `headless`).

### Stacks Docker

Para um `compose.yaml.tmpl` alterado, renderize para um arquivo temporário e valide com `docker compose -f <arquivo> config`. Lembre que a rede externa `edge-network` precisa existir para o `up`.

### Lacunas conhecidas

- Erros de template só aparecem no `apply` (ou no `--dry-run`) da plataforma afetada; uma mudança testada no Windows não exercita os templates de Linux, macOS ou Termux.
- Não há verificação automática de sintaxe dos scripts renderizados nem dos módulos zsh.
- Os bugs listados em [Armadilhas de template](#armadilhas-de-template) passariam despercebidos por qualquer validação feita fora do contexto afetado (Termux, VPS).

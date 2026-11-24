# Phase 1: Apply em todo perfil e CI - Context

**Gathered:** 2026-11-24
**Status:** Ready for planning

<domain>
## Phase Boundary

`chezmoi apply` renderiza e executa sem erro em todo perfil suportado (Linux root e user, VPS, macOS, Termux), e um CI no Codeberg barra regressões de template e script a cada push. Requisitos: APPLY-01..06, REL-04, REL-05. Corrige os bugs de template A4, A5, M2, M4 e B7, a descoberta de versão dos instaladores (M7), os guards de workplace/Arch e cria o CI (M8).

</domain>

<decisions>
## Implementation Decisions

### Contexto Instivo (APPLY-06, escopo ajustado)
- **D-01:** O usuário não trabalha mais na Instivo (hoje é Zup, alocado no Itaú). O contexto Instivo **não** deve ser reativado. O guard `home/.chezmoitemplates/workplace/script_is_instivo` e os scripts que dependem dele (`linux/run_once_after_655-configure-vpn-instivo.sh.tmpl`, `linux/run_once_after_554-install-openvpn3.sh.tmpl`) e as entradas no `home/.chezmoiignore.tmpl` **ficam no repositório, desativados**, com comentário marcando que é legado e que nunca roda. Não apagar.
- **D-02:** O APPLY-06 passa a ser cumprido assim: o comportamento de `script_is_instivo` (nunca passa) é intencional e documentado no próprio guard, não "fazer passar". Atualizar o texto do requisito/critério 3 do ROADMAP quando a fase fechar.
- **D-03:** Remover o script `home/.chezmoiscripts/unix/run_once_after_515-install-coderabbit-cli.sh.tmpl` (o usuário não usa o coderabbit). Remover também as referências a ele (`.chezmoiignore.tmpl`, docs), se houver.

### Plataforma do CI (REL-05)
- **D-04:** CI em **Forgejo Actions no Codeberg** (`.forgejo/workflows/`). Se os runners hospedados do Codeberg não estiverem disponíveis ou forem insuficientes, a pesquisa documenta o plano B (runner próprio), sem trocar de plataforma.
- **D-05:** Dispara em **todo push em `main`** (o usuário commita direto em main; sem PR obrigatório).
- **D-06:** O perfil macOS (e os demais) é renderizado em runner **Linux com dados simulados**. Sem runner macOS real.
- **D-07:** O CI faz **só renderização + análise**: `chezmoi execute-template` por perfil (Linux, VPS, macOS, Termux), `shellcheck` nos scripts renderizados e `docker compose config` nas stacks. **Sem `chezmoi apply` em container** (o usuário desistiu disso).
- **D-08:** `shellcheck` com **`--severity=warning`**: barra warning e error; os achados existentes são corrigidos nesta fase. Style/info ficam fora.

### Segredos (restrição travada)
- **D-09:** Os arquivos `encrypted_*.asc` são criptografados pelo chezmoi e **não podem ser tocados**: nada nesta fase lê, decifra, edita, renomeia, recria ou gera esses arquivos, e não entra chave GPG no CI. O CI precisa contornar esses arquivos sem alterá-los (por exemplo, pulá-los ao renderizar). A forma exata fica a critério da pesquisa, desde que respeite esta regra.

### Instaladores (REL-04)
- **D-10:** lazygit, atuin e glab **continuam como scripts** (`unix/run_once_after_529-install-lazygit`, `536-install-atuin`, `528-install-glab`). Não migrar para o mise. Trocar `curl | grep | sed` / `grep -oP` por `jq` (ou redirecionamento `releases/latest/download`), usar `curl -f`, validar a versão e abortar com mensagem clara se a consulta falhar. Aceitar `GITHUB_TOKEN` quando existir. O glab precisa funcionar no macOS (sem `grep -oP`).
- **D-11:** O Ollama (Linux `linux/run_once_after_504-install-ollama.sh.tmpl` e macOS `darwin/run_once_after_504-install-ollama-darwin.sh.tmpl`) **continua em script próprio**, com `jq` e `curl -f` na descoberta de versão. No modo user, remove só binários/libs antigos e preserva `~/.ollama/models` e a chave de identidade (M4).

### Claude's Discretion
- **Arch puro no `script_arch_based_only`:** a pesquisa verifica se algum script protegido depende de algo exclusivo de EndeavourOS/CachyOS. Se não depender, incluir Arch puro. Em qualquer caso, documentar a regra no próprio guard. Também é decisão do planejamento se os testes inline de `osid` (`endeavouros`/`cachyos`) espalhados nos scripts viram um helper único.
- Formato dos dados simulados por perfil no CI (arquivos de fixture, `--override-data`, env `CHEZMOI_*`).
- Garantir que `jq` está disponível antes dos instaladores que passam a depender dele (pacote base por plataforma, incluindo Termux).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requisitos e problemas
- `docs/pontos-de-atencao.md` — fonte dos requisitos; seções A4, A5, M2, M4, M7, M8, B7
- `.planning/REQUIREMENTS.md` — APPLY-01..06, REL-04, REL-05
- `.planning/ROADMAP.md` — Phase 1: critérios de sucesso e notas (Codeberg, `.asc`)

### Arquitetura e convenções
- `docs/arquitetura.md` §guards (linha ~239) — comportamento documentado de `script_arch_based_only` e guards de workplace
- `docs/convencoes-e-testes.md` — tabela de guards e convenções de scripts
- `docs/estrutura.md` — layout de `home/.chezmoitemplates/`
- `.planning/codebase/` — mapas do código (têm erros conhecidos; confirmar no código)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `home/.chezmoitemplates/` — guards reutilizáveis (`common/script_is_not_ephemeral`, `common/script_helper` com `info`/`success`/`error`, `linux/script_*_only`, `workplace/script_is_zup`).
- Overrides por env em `home/.chezmoi.yaml.tmpl`: `CHEZMOI_PROFILE`, `CHEZMOI_VPS`, `CHEZMOI_FORCE_GUI`, `CHEZMOI_FORCE_HEADLESS`, `CHEZMOI_SKIP_SHELL_PROBES`. Servem para simular perfis no CI.

### Established Patterns
- `workplace` é definido em `home/.chezmoi.yaml.tmpl:55-60` só como `Zup`, `Itau` ou vazio, a partir do hostname. Por isso `script_is_instivo` (`eq .settings.workplace "Instivo"`) nunca passa.
- `script_arch_based_only` aceita só `osid` com `endeavouros`/`cachyos`, e o mesmo teste é repetido inline nos scripts 655, 515, 201, 214, 215, 220.
- Scripts `run_once_*`/`run_onchange_*` em `home/.chezmoiscripts/{linux,darwin,unix,termux,vps,windows}/`; comentários e docs voltados ao usuário em pt-BR; commits em Conventional Commits em inglês direto em `main`.

### Integration Points
- Novo `.forgejo/workflows/*.yml` na raiz do repositório (fora de `home/`, que é o source dir do chezmoi).
- Stacks para `docker compose config`: `home/dot_local/opt/stacks/*/compose.yaml.tmpl` (13) e `home/dot_local/opt/dockge/`.

</code_context>

<specifics>
## Specific Ideas

- O CI deve falhar se um bug como A4 ou A5 voltar (critério 5 do ROADMAP).
- Contexto atual de trabalho do usuário: Zup, alocado no Itaú (workplaces `Zup`/`Itau` já detectados por hostname).

</specifics>

<deferred>
## Deferred Ideas

- `chezmoi apply` real em containers (Ubuntu/Arch/VPS) no CI: considerado e descartado pelo usuário nesta fase; pode voltar como fase própria.
- Migrar lazygit/atuin/glab para o mise: descartado nesta fase (o usuário quer manter os scripts).

</deferred>

---

*Phase: 01-apply-em-todo-perfil-e-ci*
*Context gathered: 2026-11-24*

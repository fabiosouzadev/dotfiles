---
phase: 2
plan_id: 02A
title: "README — Guia de Fork e Personalização"
wave: 1
depends_on: [1]
files_modified:
  - docs/FORK-GUIDE.md
  - docs/fork/SECRETS-GUIDE.md
  - docs/fork/CHEZMOI-VARS.md
requirements:
  - DOC-08
autonomous: true
---

# Plan 02A: README — Guia de Fork e Personalização

## Objective

Tornar o repositório amigável para *forks*, criando um guia passo a passo dividido em múltiplos arquivos que explica como adaptar os dotfiles para um novo usuário. Assumiremos que o usuário já conhece o básico de `chezmoi` e `age`, focando apenas nas peculiaridades locais do repositório. O conteúdo deverá ser totalmente bilíngue (Inglês e Português espelhados).

## Must-Haves (Goal-Backward Verification)

1. `docs/FORK-GUIDE.md` funciona como um índice central e checklist bilíngue.
2. `docs/fork/CHEZMOI-VARS.md` explica as variáveis do `.chezmoi.yaml.tmpl` e `.chezmoidata/`.
3. `docs/fork/SECRETS-GUIDE.md` alerta sobre as chaves `age` e explica como re-encriptar arquivos.
4. Todos os arquivos usam cabeçalhos bilíngues e explicações em ambos os idiomas (Inglês/Português).

## Tasks

<task id="02A-T1" type="execute">
<title>Criar estrutura de pastas e reescrever o FORK-GUIDE.md principal</title>

<read_first>
- .planning/phases/02-readme-fork-guide/02-CONTEXT.md
- docs/FORK-GUIDE.md (conteúdo antigo)
</read_first>

<action>
1. Criar o diretório `docs/fork/` se não existir.
2. Reescrever o arquivo `docs/FORK-GUIDE.md` para atuar como um *Hub/Index* bilíngue.
3. Conteúdo a incluir:
   - Título bilíngue e introdução.
   - Checklist de "Primeiro Fork" (First Fork Checklist / Checklist do Primeiro Fork) descrevendo a ordem de ações.
   - Links para os arquivos secundários (Secrets e Chezmoi Vars).
   - O que funciona "out-of-the-box" (O que você ganha de graça).
</action>

<acceptance_criteria>
- `docs/FORK-GUIDE.md` tem links para `fork/CHEZMOI-VARS.md` e `fork/SECRETS-GUIDE.md`.
- Checklist do Primeiro Fork está presente em ambos os idiomas.
</acceptance_criteria>
</task>

<task id="02A-T2" type="execute">
<title>Criar guia focado em variáveis do Chezmoi</title>

<action>
1. Criar `docs/fork/CHEZMOI-VARS.md`.
2. Documentar as seguintes áreas de forma bilíngue (Inglês/PT-BR):
   - **`home/.chezmoi.yaml.tmpl`**: Explicar a necessidade de alterar `email`, `signingkey`, entre outras.
   - **`home/.chezmoidata/repos.json`**: Mostrar como configurar os repositórios clonados automaticamente.
   - **Controle de Pacotes**: Explicar brevemente como os pacotes de instalação mudam via OS no `chezmoidata`.
</action>

<acceptance_criteria>
- Arquivo criado e preenchido com as seções de `chezmoi.yaml.tmpl` e `repos.json`.
- Texto bilíngue incluído.
</acceptance_criteria>
</task>

<task id="02A-T3" type="execute">
<title>Criar guia focado em Segredos (age encryption)</title>

<action>
1. Criar `docs/fork/SECRETS-GUIDE.md`.
2. Documentar as seguintes áreas de forma bilíngue (Inglês/PT-BR):
   - **O problema**: Explicar que os 17 arquivos encriptados usarão a chave do dono original e falharão.
   - **A solução**: Como gerar uma nova chave (`age-keygen`), atualizar o recipient no `.chezmoi.yaml.tmpl`, e como recriar (`chezmoi add --encrypt`) os próprios secrets como SSH, API tokens, etc.
</action>

<acceptance_criteria>
- Explicação clara de falha por falta de chave `age` privada.
- Passo-a-passo técnico bilíngue de resolução (gerar chave + adicionar encryptado).
</acceptance_criteria>
</task>

## Verification Plan

### Automated Tests
1. `cat docs/FORK-GUIDE.md | grep -i "fork/SECRETS-GUIDE.md"` (garantir link)
2. `cat docs/FORK-GUIDE.md | grep -i "fork/CHEZMOI-VARS.md"` (garantir link)
3. `test -f docs/fork/SECRETS-GUIDE.md && echo OK`
4. `test -f docs/fork/CHEZMOI-VARS.md && echo OK`

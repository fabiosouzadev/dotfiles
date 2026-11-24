#!/usr/bin/env bash
# Valida arquivos Docker Compose renderizados: docker compose config -q.
#
# Renderiza cada compose.yaml.tmpl da VPS (13 stacks + dockge = 14) com o perfil
# vps via ci/render.sh one, cria .env vazio (encrypted_dot_env.asc não é lido, D-09),
# e roda `docker compose config -q` para validar sintaxe e interpolação.
#
# Warnings de variáveis faltando são esperados (os .env reais estão criptografados).
# Nenhum daemon Docker é necessário; `config -q` só valida a estrutura.

set -euo pipefail

# Configuração
SOURCE_ROOT="${SOURCE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CI_TOOLS_DIR="${CI_TOOLS_DIR:-${TMPDIR:-/tmp}/dotfiles-ci-tools}"

# Adiciona CI_TOOLS_DIR ao PATH
if [ -d "$CI_TOOLS_DIR" ]; then
  export PATH="$CI_TOOLS_DIR:$PATH"
fi

# Resolve docker compose command
COMPOSE=""
if [ -x "$CI_TOOLS_DIR/docker-compose" ]; then
  COMPOSE="$CI_TOOLS_DIR/docker-compose"
elif docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "ERROR: docker compose not found" >&2
  echo "Run: bash ci/bootstrap-tools.sh" >&2
  exit 2
fi

# Work dir
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# Gera base config uma vez e exporta para render.sh one reusar
BASE_CONFIG="$WORK/base.yaml"
if ! bash "$SOURCE_ROOT/ci/render.sh" base-config "$BASE_CONFIG" >/dev/null 2>&1; then
  echo "ERROR: failed to generate base config" >&2
  exit 1
fi
export CI_BASE_CONFIG="$BASE_CONFIG"

# Encontra todos os compose.yaml.tmpl sob home/dot_local/opt
COMPOSE_TEMPLATES=()
while IFS= read -r -d '' file; do
  COMPOSE_TEMPLATES+=("$file")
done < <(find "$SOURCE_ROOT/home/dot_local/opt" -name 'compose.yaml.tmpl' -print0)

if [ ${#COMPOSE_TEMPLATES[@]} -eq 0 ]; then
  echo "ERROR: no compose.yaml.tmpl files found in home/dot_local/opt" >&2
  exit 2
fi

# Valida cada stack
TOTAL=0
FAILED=0
FAILED_STACKS=()

for tmpl in "${COMPOSE_TEMPLATES[@]}"; do
  # Stack name = parent directory name
  STACK=$(basename "$(dirname "$tmpl")")
  STACK_DIR="$WORK/$STACK"
  mkdir -p "$STACK_DIR"

  # Renderiza com perfil vps
  RENDERED="$STACK_DIR/compose.yaml"
  if ! bash "$SOURCE_ROOT/ci/render.sh" one vps "$tmpl" > "$RENDERED" 2>"$WORK/$STACK.err"; then
    echo "COMPOSE FAIL $STACK: $(head -1 "$WORK/$STACK.err")"
    FAILED=$((FAILED + 1))
    FAILED_STACKS+=("$STACK")
    continue
  fi

  # Cria .env vazio (os .env reais são encrypted_dot_env.asc, D-09)
  touch "$STACK_DIR/.env"

  # Valida com docker compose config -q
  TOTAL=$((TOTAL + 1))
  if $COMPOSE -f "$RENDERED" --project-directory "$STACK_DIR" config -q 2>"$WORK/$STACK.config.err"; then
    echo "COMPOSE OK $STACK"
  else
    # Extrai primeira linha de erro real (ignora warnings de missing vars)
    ERROR=$(grep -v '^WARN' "$WORK/$STACK.config.err" | head -1 || echo "unknown error")
    echo "COMPOSE FAIL $STACK: $ERROR"
    FAILED=$((FAILED + 1))
    FAILED_STACKS+=("$STACK")
  fi
done

# Resultado final
if [ $FAILED -eq 0 ]; then
  echo "COMPOSE OK (stacks=$TOTAL)"
  exit 0
else
  echo "COMPOSE FAILED (failed=$FAILED)"
  exit 1
fi

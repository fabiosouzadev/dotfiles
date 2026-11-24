#!/usr/bin/env bash
# Instala ferramentas CI com versões fixas e verificação SHA-256.
#
# Por que pinned: Shellcheck v0.11.0 adicionou novas regras; um upgrade silencioso
# (via apt/brew) mudaria o gate sem revisão explícita. Chezmoi está pinado para
# evitar mudanças de comportamento em execute-template. jq e docker-compose fixos
# garantem reprodutibilidade.
#
# Download direto via curl + sha256sum evita intermediários (npm/pip/cargo) que
# introduziriam supply-chain risk adicional. SHA-256 do release API GitHub garante
# integridade.

set -euo pipefail

# Configuração
CI_TOOLS_DIR="${CI_TOOLS_DIR:-${TMPDIR:-/tmp}/dotfiles-ci-tools}"
CI_FORCE_PINNED="${CI_FORCE_PINNED:-}"

# Detecta plataforma
HOST_OS="$(uname -s)"
case "$HOST_OS" in
  Linux)
    HOST="linux"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    HOST="windows"
    ;;
  *)
    echo "ERROR: plataforma não suportada: $HOST_OS" >&2
    echo "Suportado: Linux, Windows (Git Bash/MSYS)" >&2
    exit 2
    ;;
esac

# Tabela de ferramentas pinadas (2026-11-24)
# chezmoi v2.74.2
CHEZMOI_VERSION="2.74.2"
CHEZMOI_URL_LINUX="https://github.com/twpayne/chezmoi/releases/download/v2.74.2/chezmoi-linux-amd64"
CHEZMOI_SHA_LINUX="5554b112f18c8f1b9194385950922ee3303703a977f3752d4637d3138516ae05"

# shellcheck v0.11.0
SHELLCHECK_VERSION="0.11.0"
SHELLCHECK_URL_LINUX="https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.x86_64.tar.gz"
SHELLCHECK_SHA_LINUX="b7af85e41cc99489dcc21d66c6d5f3685138f06d34651e6d34b42ec6d54fe6f6"
SHELLCHECK_URL_WINDOWS="https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.zip"
SHELLCHECK_SHA_WINDOWS="8a4e35ab0b331c85d73567b12f2a444df187f483e5079ceffa6bda1faa2e740e"

# jq 1.8.2
JQ_VERSION="1.8.2"
JQ_URL_LINUX="https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-linux-amd64"
JQ_SHA_LINUX="b1c22172dd303f3be49e935aa56aa48a8b7a46e0bc838b4997d3bb451495870f"
JQ_URL_WINDOWS="https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-windows-amd64.exe"
JQ_SHA_WINDOWS="a6fc67fedaf9128a3309a1e2ebb8b986aeccf70122ee46d2cb4849e423f0c627"

# docker-compose v5.8.0
COMPOSE_VERSION="5.8.0"
COMPOSE_URL_LINUX="https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-x86_64"
COMPOSE_SHA_LINUX="b8840f5008c447f41fce0a57ae3adeab42c89b1eb6e6012524bcabbfb4ffbaf6"

# Função: download e verifica SHA-256
download_and_verify() {
  local url="$1"
  local expected_sha="$2"
  local dest="$3"

  # Se o arquivo existe e o checksum já bate, pula
  if [ -f "$dest" ]; then
    local actual_sha
    actual_sha=$(sha256sum "$dest" | cut -d' ' -f1)
    if [ "$actual_sha" = "$expected_sha" ]; then
      return 0
    fi
    echo "Checksum mismatch (re-download): $dest" >&2
    rm -f "$dest"
  fi

  echo "Downloading: $url -> $dest" >&2
  curl -fsSL -o "$dest" "$url"

  local actual_sha
  actual_sha=$(sha256sum "$dest" | cut -d' ' -f1)
  if [ "$actual_sha" != "$expected_sha" ]; then
    echo "ERROR: SHA-256 mismatch!" >&2
    echo "  Expected: $expected_sha" >&2
    echo "  Got:      $actual_sha" >&2
    echo "  File:     $dest" >&2
    rm -f "$dest"
    exit 1
  fi
}

# Cria diretório de ferramentas
mkdir -p "$CI_TOOLS_DIR"

# Linux: instala todas as ferramentas quando CI_FORCE_PINNED=1 ou se estão faltando
if [ "$HOST" = "linux" ]; then
  # chezmoi
  if [ -n "$CI_FORCE_PINNED" ] || ! command -v chezmoi >/dev/null 2>&1; then
    download_and_verify "$CHEZMOI_URL_LINUX" "$CHEZMOI_SHA_LINUX" "$CI_TOOLS_DIR/chezmoi"
    chmod +x "$CI_TOOLS_DIR/chezmoi"
  fi

  # shellcheck
  SHELLCHECK_TAR="$CI_TOOLS_DIR/shellcheck-v0.11.0.linux.x86_64.tar.gz"
  if [ -n "$CI_FORCE_PINNED" ] || ! command -v shellcheck >/dev/null 2>&1; then
    download_and_verify "$SHELLCHECK_URL_LINUX" "$SHELLCHECK_SHA_LINUX" "$SHELLCHECK_TAR"
    tar -xzf "$SHELLCHECK_TAR" -C "$CI_TOOLS_DIR" "shellcheck-v0.11.0/shellcheck" --strip-components=1
    chmod +x "$CI_TOOLS_DIR/shellcheck"
  fi

  # jq
  if [ -n "$CI_FORCE_PINNED" ] || ! command -v jq >/dev/null 2>&1; then
    download_and_verify "$JQ_URL_LINUX" "$JQ_SHA_LINUX" "$CI_TOOLS_DIR/jq"
    chmod +x "$CI_TOOLS_DIR/jq"
  fi

  # docker-compose
  if [ -n "$CI_FORCE_PINNED" ] || ! command -v docker-compose >/dev/null 2>&1; then
    download_and_verify "$COMPOSE_URL_LINUX" "$COMPOSE_SHA_LINUX" "$CI_TOOLS_DIR/docker-compose"
    chmod +x "$CI_TOOLS_DIR/docker-compose"
  fi
fi

# Windows: instala shellcheck.exe e jq.exe sempre; require chezmoi on PATH
if [ "$HOST" = "windows" ]; then
  # shellcheck.exe
  SHELLCHECK_ZIP="$CI_TOOLS_DIR/shellcheck-v0.11.0.zip"
  download_and_verify "$SHELLCHECK_URL_WINDOWS" "$SHELLCHECK_SHA_WINDOWS" "$SHELLCHECK_ZIP"
  unzip -o "$SHELLCHECK_ZIP" -d "$CI_TOOLS_DIR" shellcheck.exe >/dev/null

  # jq.exe
  download_and_verify "$JQ_URL_WINDOWS" "$JQ_SHA_WINDOWS" "$CI_TOOLS_DIR/jq.exe"

  # chezmoi: exige que esteja no PATH
  if ! command -v chezmoi >/dev/null 2>&1; then
    echo "ERROR: chezmoi não encontrado no PATH. No Windows, instale manualmente:" >&2
    echo "  winget install twpayne.chezmoi" >&2
    echo "  ou baixe de https://github.com/twpayne/chezmoi/releases" >&2
    exit 2
  fi

  # docker compose: usa 'docker compose' se disponível
  if ! docker compose version >/dev/null 2>&1; then
    echo "WARNING: 'docker compose' não disponível. ci/compose-config.sh pode falhar." >&2
  fi
fi

# Adiciona CI_TOOLS_DIR ao PATH para próximos comandos
export PATH="$CI_TOOLS_DIR:$PATH"

# Imprime versões (output lines para verificação)
CHEZMOI_PATH=$(command -v chezmoi)
# chezmoi --version prints "chezmoi version v2.74.2, ..." - extract just the version
CHEZMOI_VER=$(chezmoi --version | head -1 | sed -E 's/^chezmoi version (v?[0-9.]+).*/\1/')
echo "TOOL chezmoi $CHEZMOI_VER $CHEZMOI_PATH"

SHELLCHECK_PATH=$(command -v shellcheck)
SHELLCHECK_VER=$(shellcheck --version | grep '^version:' | awk '{print $2}')
echo "TOOL shellcheck $SHELLCHECK_VER $SHELLCHECK_PATH"

JQ_PATH=$(command -v jq)
JQ_VER=$(jq --version)
echo "TOOL jq $JQ_VER $JQ_PATH"

if [ "$HOST" = "linux" ]; then
  # docker-compose (standalone ou plugin)
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_VER=$(docker compose version --short)
    COMPOSE_PATH="docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_PATH=$(command -v docker-compose)
    COMPOSE_VER=$(docker-compose version --short)
  else
    echo "WARNING: docker-compose não encontrado" >&2
    COMPOSE_VER="missing"
    COMPOSE_PATH="none"
  fi
  echo "TOOL docker-compose $COMPOSE_VER $COMPOSE_PATH"
fi

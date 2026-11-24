#!/usr/bin/env bash
# Valida templates chezmoi por perfil: render + shellcheck + fixture drift.
#
# Renderiza cada template não-criptografado com chezmoi execute-template, honrando
# .chezmoiignore.tmpl. Stubs decrypt calls com "ci-placeholder-secret" (D-09).
# Roda shellcheck --severity=warning nos scripts. Verifica que fixtures têm todas
# as chaves settings/dirs/features/gpg que home/.chezmoi.yaml.tmpl calcula.

set -euo pipefail

# --- Configuração ---
SOURCE_ROOT="${SOURCE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CI_PROFILES_DIR="${CI_PROFILES_DIR:-$SOURCE_ROOT/ci/profiles}"
CI_TOOLS_DIR="${CI_TOOLS_DIR:-${TMPDIR:-/tmp}/dotfiles-ci-tools}"
CI_BASE_CONFIG="${CI_BASE_CONFIG:-}"
CI_KEEP_WORK="${CI_KEEP_WORK:-}"
SHELLCHECK="${SHELLCHECK:-shellcheck}"

# Adiciona CI_TOOLS_DIR ao PATH se existir
if [ -d "$CI_TOOLS_DIR" ]; then
  export PATH="$CI_TOOLS_DIR:$PATH"
fi

# --- Funções auxiliares ---

usage() {
  cat >&2 <<'EOF'
Uso:
  bash ci/render.sh base-config OUT_FILE
  bash ci/render.sh one PROFILE SOURCE_PATH [OVERRIDE_JSON]
  bash ci/render.sh gate [--list] [--only SUBSTR]... [PROFILE...]
  bash ci/render.sh drift [PROFILE...]

Env:
  SOURCE_ROOT      repo root (default: parent de ci/)
  CI_PROFILES_DIR  fixtures dir (default: $SOURCE_ROOT/ci/profiles)
  CI_TOOLS_DIR     tool dir (default: ${TMPDIR:-/tmp}/dotfiles-ci-tools)
  CI_BASE_CONFIG   reuse existing base config
  CI_FORCE_PINNED  =1 → bootstrap sempre instala versões pinadas
  CI_KEEP_WORK     =1 → mantém temp work dir e imprime path

Exit codes: 0 ok · 1 render/shellcheck/drift failures · 2 usage error ou D-09 violation
EOF
  exit 2
}

# Gera base config com home/.chezmoi.yaml.tmpl
generate_base_config() {
  local out="$1"
  local work_state="$2"

  # Renderiza o config template com CHEZMOI_SKIP_SHELL_PROBES=1
  if ! CHEZMOI_SKIP_SHELL_PROBES=1 chezmoi \
    --persistent-state "$work_state" \
    --source "$SOURCE_ROOT" \
    execute-template --init --stdinisatty=false \
    < "$SOURCE_ROOT/home/.chezmoi.yaml.tmpl" \
    > "$out" 2>"$out.err"; then
    echo "RENDER FAIL [config] home/.chezmoi.yaml.tmpl: $(head -1 "$out.err")" >&2
    return 1
  fi
  return 0
}

# Renderiza um único template com profile e override
render_one() {
  local profile="$1"
  local source_path="$2"
  local override_json="${3:-}"

  # Precisa de um work dir temporário
  local work
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT

  local base="$work/base.yaml"
  local state="$work/state.boltdb"

  # Gera base config se não foi passado CI_BASE_CONFIG
  if [ -n "$CI_BASE_CONFIG" ]; then
    base="$CI_BASE_CONFIG"
  else
    if ! generate_base_config "$base" "$state"; then
      rm -rf "$work"
      return 1
    fi
  fi

  # Copia source com CR stripped e aplica stub decrypt
  local stubbed="$work/input.tmpl"
  tr -d '\r' < "$source_path" > "$stubbed"

  # Stub decrypt: joinPath ... | include | decrypt e include ... | decrypt
  sed -i -E 's/(joinPath[^|}]*[|][[:space:]]*include|include[[:space:]]+[^|}]+)[[:space:]]*[|][[:space:]]*decrypt/"ci-placeholder-secret"/g' "$stubbed"

  # Verifica se decrypt sobreviveu (D-09)
  if grep -qw decrypt "$stubbed"; then
    echo "ERROR: D-09: decrypt survived stubbing in $source_path" >&2
    rm -rf "$work"
    exit 2
  fi

  # Renderiza
  local override_args=()
  if [ -n "$override_json" ]; then
    override_args=(--override-data "$override_json")
  fi

  if ! chezmoi \
    --config "$base" \
    --persistent-state "$state" \
    --cache "$work/cache" \
    --source "$SOURCE_ROOT" \
    --destination "$work/dest" \
    --no-tty \
    --override-data-file "$CI_PROFILES_DIR/$profile.yaml" \
    "${override_args[@]+"${override_args[@]}"}" \
    execute-template < "$stubbed" 2>"$work/err"; then
    echo "RENDER FAIL [$profile] $(realpath --relative-to="$SOURCE_ROOT" "$source_path"): $(head -1 "$work/err")" >&2
    rm -rf "$work"
    return 1
  fi

  # Strip CR do output e imprime
  tr -d '\r' < "$work/dest"
  rm -rf "$work"
  return 0
}

# Subcomando: base-config
cmd_base_config() {
  if [ $# -ne 1 ]; then
    usage
  fi
  local out="$1"
  local work
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT

  if ! generate_base_config "$out" "$work/state.boltdb"; then
    rm -rf "$work"
    exit 1
  fi
  rm -rf "$work"
}

# Subcomando: one
cmd_one() {
  if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    usage
  fi
  render_one "$@"
}

# Subcomando: gate
cmd_gate() {
  local list_mode=0
  local only_filters=()
  local profiles=()

  while [ $# -gt 0 ]; do
    case "$1" in
      --list)
        list_mode=1
        shift
        ;;
      --only)
        if [ $# -lt 2 ]; then
          echo "ERROR: --only requires argument" >&2
          exit 2
        fi
        only_filters+=("$2")
        shift 2
        ;;
      *)
        profiles+=("$1")
        shift
        ;;
    esac
  done

  # Se não especificou profiles, usa todos os ci/profiles/*.yaml
  if [ ${#profiles[@]} -eq 0 ]; then
    for f in "$CI_PROFILES_DIR"/*.yaml; do
      profiles+=("$(basename "$f" .yaml)")
    done
  fi

  # Work dir
  local work
  work=$(mktemp -d)
  if [ -z "$CI_KEEP_WORK" ]; then
    trap 'rm -rf "$work"' EXIT
  else
    echo "WORK DIR: $work" >&2
  fi

  # Gera base config uma vez
  local base="$work/base.yaml"
  local state="$work/state.boltdb"
  if [ -n "$CI_BASE_CONFIG" ]; then
    base="$CI_BASE_CONFIG"
  else
    if ! generate_base_config "$base" "$state"; then
      exit 1
    fi
  fi

  # Descobre candidatos (find)
  local candidates=()
  while IFS= read -r -d '' file; do
    # Prune /encrypted_
    if [[ "$file" == */encrypted_* ]]; then
      continue
    fi

    # Exclude paths
    local rel
    rel=$(realpath --relative-to="$SOURCE_ROOT" "$file")
    case "$rel" in
      home/.chezmoitemplates/*|home/.chezmoidata/*|home/.chezmoi.yaml.tmpl|home/.chezmoiignore.tmpl)
        continue
        ;;
    esac

    candidates+=("$file")
  done < <(find "$SOURCE_ROOT/home" -type f -name '*.tmpl' -print0)

  # D-09: nenhum candidato deve conter "encrypted_" no path
  for cand in "${candidates[@]}"; do
    if [[ "$cand" == *encrypted_* ]]; then
      echo "ERROR: D-09: encrypted_ survived filter: $cand" >&2
      exit 2
    fi
  done

  # Renderiza home/.chezmoiexternals/*.tmpl sem ignore filter (config files)
  local externals=()
  for cand in "${candidates[@]}"; do
    if [[ "$cand" == */home/.chezmoiexternals/*.tmpl ]]; then
      externals+=("$cand")
    fi
  done

  # Total de erros
  local total_render_failures=0
  local total_shellcheck_failures=0
  local total_drift_failures=0
  local any_only_matched=0

  # Drift check para profiles selecionados
  for profile in "${profiles[@]}"; do
    local drift_errors=0
    for section in settings dirs features gpg; do
      # Renderiza com base config
      local keys_base
      keys_base=$(chezmoi --config "$base" --persistent-state "$state" --source "$SOURCE_ROOT" execute-template \
        "{{ keys .$section | sortAlpha | join \"\n\" }}" 2>/dev/null | tr -d '\r' || true)

      # Renderiza com fixture
      local keys_fixture
      keys_fixture=$(chezmoi --config /dev/null --persistent-state "$state" --source "$SOURCE_ROOT" \
        --override-data-file "$CI_PROFILES_DIR/$profile.yaml" execute-template \
        "{{ keys .$section | sortAlpha | join \"\n\" }}" 2>/dev/null | tr -d '\r' || true)

      # Compara
      while IFS= read -r key; do
        if [ -n "$key" ] && ! echo "$keys_fixture" | grep -qxF "$key"; then
          echo "DRIFT [$profile] missing $section.$key"
          drift_errors=$((drift_errors + 1))
        fi
      done <<< "$keys_base"
    done
    total_drift_failures=$((total_drift_failures + drift_errors))
  done

  # Gate por profile
  for profile in "${profiles[@]}"; do
    local profile_dir="$work/$profile"
    mkdir -p "$profile_dir"

    # Renderiza .chezmoiignore.tmpl
    local ignore_patterns="$work/$profile-ignore.txt"
    if ! chezmoi \
      --config "$base" \
      --persistent-state "$state" \
      --source "$SOURCE_ROOT" \
      --no-tty \
      --override-data-file "$CI_PROFILES_DIR/$profile.yaml" \
      execute-template < "$SOURCE_ROOT/home/.chezmoiignore.tmpl" 2>/dev/null \
      | tr -d '\r' \
      | grep -v '^\s*$' \
      | grep -v '^\s*#' \
      > "$ignore_patterns"; then
      echo "WARNING: failed to render .chezmoiignore.tmpl for $profile" >&2
      : > "$ignore_patterns"
    fi

    # Verifica negated patterns (não suportado)
    if grep -q '^!' "$ignore_patterns"; then
      echo "ERROR: negated ignore patterns not supported by ci/render.sh" >&2
      exit 2
    fi

    # Mapeia candidates para target paths com chezmoi target-path
    local kept_candidates=()
    local target_paths=()

    # Externals sempre incluídos
    for ext in "${externals[@]}"; do
      kept_candidates+=("$ext")
      target_paths+=("$(basename "$ext" .tmpl)")
    done

    # Outros candidates: batch target-path
    local other_candidates=()
    for cand in "${candidates[@]}"; do
      if [[ "$cand" != */home/.chezmoiexternals/*.tmpl ]]; then
        other_candidates+=("$cand")
      fi
    done

    if [ ${#other_candidates[@]} -gt 0 ]; then
      local dest_root
      dest_root=$(chezmoi --config "$base" --persistent-state "$state" \
        --source "$SOURCE_ROOT" --override-data-file "$CI_PROFILES_DIR/$profile.yaml" \
        target-path 2>/dev/null | tr -d '\r')

      local mapped_targets
      mapped_targets=$(chezmoi --config "$base" --persistent-state "$state" \
        --source "$SOURCE_ROOT" --override-data-file "$CI_PROFILES_DIR/$profile.yaml" \
        target-path "${other_candidates[@]}" 2>/dev/null | tr -d '\r')

      local idx=0
      while IFS= read -r target_full; do
        if [ -n "$target_full" ]; then
          local target_rel="${target_full#$dest_root/}"
          target_rel="${target_rel#/}"

          # Match ignore patterns
          local ignored=0
          while IFS= read -r pattern; do
            if [ -n "$pattern" ]; then
              if [[ "$target_rel" == $pattern || "$target_rel" == $pattern/* ]]; then
                ignored=1
                break
              fi
            fi
          done < "$ignore_patterns"

          if [ $ignored -eq 0 ]; then
            kept_candidates+=("${other_candidates[$idx]}")
            target_paths+=("$target_rel")
          fi
        fi
        idx=$((idx + 1))
      done <<< "$mapped_targets"
    fi

    # Aplica --only filters
    local filtered_candidates=()
    local filtered_targets=()
    if [ ${#only_filters[@]} -gt 0 ]; then
      for i in "${!kept_candidates[@]}"; do
        local cand="${kept_candidates[$i]}"
        local matched=0
        for filt in "${only_filters[@]}"; do
          if [[ "$cand" == *"$filt"* ]]; then
            matched=1
            any_only_matched=1
            break
          fi
        done
        if [ $matched -eq 1 ]; then
          filtered_candidates+=("$cand")
          filtered_targets+=("${target_paths[$i]}")
        fi
      done
    else
      filtered_candidates=("${kept_candidates[@]}")
      filtered_targets=("${target_paths[@]}")
    fi

    local rendered=0
    local render_failures=0
    local shellchecked=0
    local shellcheck_failures=0

    # Renderiza cada candidato
    for i in "${!filtered_candidates[@]}"; do
      local cand="${filtered_candidates[$i]}"
      local target="${filtered_targets[$i]}"
      local rel_source
      rel_source=$(realpath --relative-to="$SOURCE_ROOT" "$cand")

      # Cria stubbed copy
      local stubbed="$work/stubbed-$profile-$(basename "$cand")"
      tr -d '\r' < "$cand" > "$stubbed"
      sed -i -E 's/(joinPath[^|}]*[|][[:space:]]*include|include[[:space:]]+[^|}]+)[[:space:]]*[|][[:space:]]*decrypt/"ci-placeholder-secret"/g' "$stubbed"

      if grep -qw decrypt "$stubbed"; then
        echo "ERROR: D-09: decrypt survived stubbing in $rel_source" >&2
        exit 2
      fi

      # Renderiza
      local rendered_file="$profile_dir/$target"
      mkdir -p "$(dirname "$rendered_file")"

      if chezmoi \
        --config "$base" \
        --persistent-state "$state" \
        --cache "$work/cache" \
        --source "$SOURCE_ROOT" \
        --destination "$work/dest" \
        --no-tty \
        --override-data-file "$CI_PROFILES_DIR/$profile.yaml" \
        execute-template < "$stubbed" 2>"$work/err-$profile-$(basename "$cand")" \
        | tr -d '\r' \
        > "$rendered_file"; then
        rendered=$((rendered + 1))

        if [ $list_mode -eq 1 ]; then
          echo "RENDERED [$profile] $rel_source"
        fi

        # Shellcheck scope: scripts em .chezmoiscripts/ ou .sh files, skip whitespace-only
        local should_shellcheck=0
        if [[ "$target" == .chezmoiscripts/* && "$target" != *.ps1 ]]; then
          should_shellcheck=1
        elif [[ "$target" == *.sh ]]; then
          should_shellcheck=1
        fi

        if [ $should_shellcheck -eq 1 ] && [ -s "$rendered_file" ] && grep -q '[^[:space:]]' "$rendered_file"; then
          shellchecked=$((shellchecked + 1))
          if ! "$SHELLCHECK" --shell=bash --severity=warning --format=gcc "$rendered_file" 2>&1 | \
            while IFS= read -r finding; do
              if [ -n "$finding" ]; then
                echo "SHELLCHECK [$profile] $rel_source: $finding"
              fi
            done | grep -q .; then
            # Nenhum finding
            :
          else
            shellcheck_failures=$((shellcheck_failures + 1))
          fi
        fi
      else
        render_failures=$((render_failures + 1))
        echo "RENDER FAIL [$profile] $rel_source: $(head -1 "$work/err-$profile-$(basename "$cand")")"
      fi
    done

    echo "PROFILE $profile: rendered=$rendered render_failures=$render_failures shellchecked=$shellchecked shellcheck_failures=$shellcheck_failures drift=$drift_errors"

    total_render_failures=$((total_render_failures + render_failures))
    total_shellcheck_failures=$((total_shellcheck_failures + shellcheck_failures))
  done

  # Se --only filters não matcharam nada, exit 2
  if [ ${#only_filters[@]} -gt 0 ] && [ $any_only_matched -eq 0 ]; then
    echo "ERROR: --only filters matched no candidates" >&2
    exit 2
  fi

  # Resultado final
  if [ $total_render_failures -eq 0 ] && [ $total_shellcheck_failures -eq 0 ] && [ $total_drift_failures -eq 0 ]; then
    echo "GATE OK"
    exit 0
  else
    echo "GATE FAILED"
    exit 1
  fi
}

# Subcomando: drift
cmd_drift() {
  local profiles=("$@")

  # Se não especificou profiles, usa todos
  if [ ${#profiles[@]} -eq 0 ]; then
    for f in "$CI_PROFILES_DIR"/*.yaml; do
      profiles+=("$(basename "$f" .yaml)")
    done
  fi

  local work
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT

  local base="$work/base.yaml"
  local state="$work/state.boltdb"
  if ! generate_base_config "$base" "$state"; then
    exit 1
  fi

  local drift_errors=0
  local empty_config="$work/empty.yaml"
  echo "{}" > "$empty_config"

  for profile in "${profiles[@]}"; do
    for section in settings dirs features gpg; do
      local keys_base
      keys_base=$(chezmoi --config "$base" --persistent-state "$state" --source "$SOURCE_ROOT" execute-template \
        "{{ keys .$section | sortAlpha | join \"\n\" }}" 2>/dev/null | tr -d '\r' || true)

      local keys_fixture
      keys_fixture=$(chezmoi --config "$empty_config" --persistent-state "$state" --source "$SOURCE_ROOT" \
        --override-data-file "$CI_PROFILES_DIR/$profile.yaml" execute-template \
        "{{ keys .$section | sortAlpha | join \"\n\" }}" 2>/dev/null | tr -d '\r' || true)

      while IFS= read -r key; do
        if [ -n "$key" ] && ! echo "$keys_fixture" | grep -qxF "$key"; then
          echo "DRIFT [$profile] missing $section.$key"
          drift_errors=$((drift_errors + 1))
        fi
      done <<< "$keys_base"
    done
  done

  if [ $drift_errors -gt 0 ]; then
    exit 1
  fi
  exit 0
}

# --- Main ---
if [ $# -eq 0 ]; then
  usage
fi

SUBCOMMAND="$1"
shift

case "$SUBCOMMAND" in
  base-config)
    cmd_base_config "$@"
    ;;
  one)
    cmd_one "$@"
    ;;
  gate)
    cmd_gate "$@"
    ;;
  drift)
    cmd_drift "$@"
    ;;
  *)
    echo "ERROR: unknown subcommand: $SUBCOMMAND" >&2
    usage
    ;;
esac

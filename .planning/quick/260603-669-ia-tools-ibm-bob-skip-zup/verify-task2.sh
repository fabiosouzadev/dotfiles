#!/usr/bin/env bash
set -euo pipefail
WT=/home/fabio.souza/.local/share/chezmoi/.claude/worktrees/agent-a999f99af820dc6d2
cd "$WT"

F=home/.chezmoiscripts/unix/run_once_after_510-install-ai-tools.sh.tmpl
AI_TOOLS_MAIN=/home/fabio.souza/.local/share/chezmoi/home/.chezmoidata/ai_tools.yaml
AI_TOOLS_WT="$WT/home/.chezmoidata/ai_tools.yaml"

echo "--- 1) guard presente nos dois ranges ---"
[ "$(grep -c 'block_on_workplace' "$F")" -ge 2 ] || { echo "FAIL: guard nao aplicado nos dois ranges"; exit 1; }
[ "$(grep -c 'and \$featureEnabled (not \$blocked)' "$F")" -eq 2 ] || { echo "FAIL: if combinado ausente em algum range"; exit 1; }
echo "  OK"

echo "--- 2) template real renderiza sem erro (workplace atual = Zup) ---"
# Temporarily copy modified ai_tools.yaml to main repo so chezmoi picks up
# block_on_workplace field. Worktree changes aren't visible to chezmoi.
BACKUP=$(mktemp)
cp "$AI_TOOLS_MAIN" "$BACKUP"
cp "$AI_TOOLS_WT" "$AI_TOOLS_MAIN"
OUT_REAL="$(chezmoi execute-template < "$WT/$F" 2>&1)" || { cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: render quebrado: $OUT_REAL"; exit 1; }
echo "$OUT_REAL" | grep -q 'AI Tools Installed' || { cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: render quebrado"; exit 1; }
echo "  OK"

echo "--- 3) workplace=Zup EXCLUI bobibm ---"
if echo "$OUT_REAL" | grep -q 'bobibm'; then cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: bobibm ainda renderiza em Zup"; exit 1; fi
echo "$OUT_REAL" | grep -q 'Installing claude (Curl)' || { cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: claude sumiu (regressao)"; exit 1; }
echo "  OK"

echo "--- 4) workplace!=Zup INCLUI bobibm (simulado inline) ---"
SNIP='{{- range (list (dict "name" "bobibm" "block_on_workplace" "Zup") (dict "name" "claude")) -}}{{- $blocked := false -}}{{- if and (hasKey . "block_on_workplace") (eq .block_on_workplace "none") }}{{ $blocked = true }}{{- end -}}{{ if not $blocked }}INSTALL {{ .name }}
{{ end }}{{- end -}}'
OUT_NONE="$(printf '%s' "$SNIP" | chezmoi execute-template)"
echo "$OUT_NONE" | grep -q 'INSTALL bobibm' || { cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: bobibm bloqueado em workplace none"; exit 1; }
echo "$OUT_NONE" | grep -q 'INSTALL claude' || { cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: claude bloqueado em none"; exit 1; }
echo "  OK"

echo "--- 5) sem regressao: tools sem o campo instalam em Zup ---"
echo "$OUT_REAL" | grep -q 'Installing aider (Curl)' || { cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: aider sumiu"; exit 1; }
echo "$OUT_REAL" | grep -q 'Installing opencode (NPM)' || { cp "$BACKUP" "$AI_TOOLS_MAIN"; rm -f "$BACKUP"; echo "FAIL: opencode sumiu"; exit 1; }
echo "  OK"

# Restore original main repo file
cp "$BACKUP" "$AI_TOOLS_MAIN"
rm -f "$BACKUP"

echo "ALL CHECKS PASSED"

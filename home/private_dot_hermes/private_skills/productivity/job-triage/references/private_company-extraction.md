# Company Extraction Logic (v1.2.0)

## Priority Order (implemented in `scripts/triage.py` → `extract_company_from_content()`)

### P1: Explicit Patterns
Regex patterns in order:
1. `r'(?i)a\s+(\w+)\s+é\s+uma\s+\w+tech'` — "A **Hanzo** é uma foodtech"
2. `r'(?i)empresa[:\\s]+([^\\n]+)'`
3. `r'(?i)company[:\\s]+([^\\n]+)'`
4. `r'(?i)contratante[:\\s]+([^\\n]+)'`
5. `r'(?i)hiring\\s+(?:company|for)[:\\s]+([^\\n]+)'`
6. `r'(?i)post(?:ado)?\\s+por[:@]\\s*([^\\n@]+?)(?:\\s+[-–—|:]|\\s+https?://|$)'` — **FIXED v1.2.0**: para antes de separadores, URLs ou fim de linha
7. `r'(?i)autor[:\\s]+([^\\n]+)'`

**Filter**: Rejeita nomes que parecem de pessoas (2-3 palavras capitalizadas: "Catarina Ugolini", "Andréa B", "Julia Argueiro", "Carla Ferreira")

---

### P2: @usuario (não domínios de email)
Regex: `r'@(\\w+)(?![.\\w]*\\.(com|br|org|net|io|co|me|ai|gov|edu))'`
- Captura `@empresa` mas NÃO `@empresa.com.br`
- Ex: "Postado por @vortigo" → "Vortigo"

---

### P3: Domínio do email
Regex: `r'@([\\w.-]+)'` → remove TLDs comuns
```python
domain = re.sub(r'\\.(com|br|org|net|io|co|me|ai|gov|edu)(\\.(br|com|org))?$', '', domain)
```
**Aceita**: hífens, alfanuméricos (`squadra-com-br` → `Squadra-com-br`?)
**Rejeita**: pontos, underscores (subdomínios pessoais: `primeiro.ultimo`, `primeiro_ultimo`)
- `luana.santos@squadra.com.br` → `squadra` → **Squadra** ✅
- `vagas@empresa.com.br` → `empresa` → **Empresa** ✅

---

### P4: Domínios "nus" no texto (URLs sem protocolo)
Regex: `r'\\b([a-zA-Z0-9-]+\\.[a-zA-Z0-9.-]+\\.(?:com\\.br|com|br|org|net|io|co|me|ai|gov|edu))\\b'`
- Captura `ats.landor.com.br` → remove TLD → `ats.landor` → pega último segmento válido → **Landor**
- Captura `careers.empresa.com.br` → **Empresa**

---

### P5: Primeira palavra capitalizada relevante
- Scaneia primeiras 15 linhas
- Ignora tech terms conhecidos (100+ termos: Node.js, Java, Python, React, Spring, AWS, Kubernetes, etc.)
- Ignora emojis, "VAGA:", "Teste", "Oportunidade", "Olá", "Estou", "Buscando"
- Retorna primeira palavra capitalizada > 2 chars que não seja tech term

---

## Test Cases Validated

| Input | Expected | Result |
|-------|----------|--------|
| `luana.santos@squadra.com.br` | **Squadra** | ✅ P3 |
| `ats.landor.com.br` | **Landor** | ✅ P4 |
| `A Hanzo é uma foodtech` | **Hanzo** | ✅ P1 |
| `Postado por Rafaela Araujo - Email: vagas@empresa.com.br` | **Empresa** (não "Rafaela Araujo") | ✅ P1 filter |
| `vagas@bluesix.com.br` | **Bluesix** | ✅ P3 |
| `fernanda.caponi@am53recruitment.com.br` | **Am53recruitment** | ✅ P3 |
| `emily.cemin@cwi.com.br` | **Cwi** | ✅ P3 |
| `maqueli.oliveira@vortigo.com.br` | **Vortigo** | ✅ P3 |
| `rosangela@bluesix.com.br` | **Bluesix** | ✅ P3 |

---

## Files Modified (v1.2.0)
- `scripts/triage.py` — `extract_company_from_content()` function updated
- `scripts/create-notion-card.sh` — Empresa fallback logic aligned + STATUS_PARAM/ETAPA_PARAM support
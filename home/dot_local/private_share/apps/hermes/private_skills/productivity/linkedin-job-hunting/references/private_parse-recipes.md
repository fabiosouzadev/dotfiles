# LinkedIn Job Search — Parse Recipes for Snapshot Data

## Contexto
Este arquivo documenta como extrair dados estruturados a partir do snapshot da página de resultados de busca do LinkedIn (`/jobs/search-results/`).

O snapshot é gerado via `browser_snapshot(full=true)` e salvo em `/opt/data/cache/web/browser-snapshot-*.txt`. A extração é feita via `execute_code` lendo o arquivo e parseando a estrutura text/markdown.

---

## Estrutura do snapshot (exemplo real)

```
main:
  - button "Selecionada, Backend Software Engineer Lead MB | Mercado Bitcoin São Paulo, SP (Híbrido) Você seria um dos melhores candidatos Visto · Anunciada há 3 semanas" [e22]:
    - paragraph: Selecionada, Backend Software Engineer Lead
    - paragraph: MB | Mercado Bitcoin
    - paragraph: São Paulo, SP (Híbrido)
    - paragraph: Você seria um dos melhores candidatos
    - paragraph: Visto
    - paragraph: ·
    - paragraph: Anunciada há 3 semanas
  - button "Tech Lead - Java (Conta Digital) (Vaga verificada) Porto São Paulo, SP (Híbrido) Fechar vaga de Tech Lead - Java (Conta Digital) 21 conexões trabalham aqui Anunciada há 2 semanas · Promovida" [e25]:
    - paragraph: Tech Lead - Java (Conta Digital) (Vaga verificada)
    - paragraph: Porto
    - paragraph: São Paulo, SP (Híbrido)
    - button "Fechar vaga de Tech Lead - Java (Conta Digital)" [e26]
    - paragraph: 21 conexões trabalham aqui
    - paragraph: Anunciada há 2 semanas
    - paragraph: ·
    - paragraph: Promovida
```

---

## Recipe 1: Extração básica via parse de linhas

```python
from hermes_tools import read_file
import re

def parse_job_cards_snapshot(snapshot_path):
    """
    Parseia o snapshot de resultados de busca do LinkedIn e retorna lista de dicts.
    """
    data = read_file(path=snapshot_path)
    content = data["content"]
    lines = content.split("\n")
    results = []
    
    i = 0
    current_card = None
    
    while i < len(lines):
        line = lines[i]
        
        # Detectar início de card: linha com [eX] e contendo título da vaga
        if re.match(r'^\s*-\s+button\s+"([^"]+)"\s+\[e\d+\]:', line):
            # Extrair o aria-label do botão
            match = re.match(r'^\s*-\s+button\s+"([^"]+)"\s+\[e\d+\]:', line)
            if match:
                aria_label = match.group(1)
                
                # Determinar tipo de card
                is_selected = "Selecionada" in aria_label or "Você seria um dos melhores candidatos" in aria_label
                is_verified = "Vaga verificada" in aria_label
                is_promoted = "Promovida" in aria_label
                
                # Extrair título (remover badges do início)
                title = aria_label
                for badge in ["Selecionada, ", "Vaga verificada", "Promovida"]:
                    title = title.replace(badge, "")
                # Remover suffixo "Fechar vaga de "
                title = re.sub(r'Fechar vaga de\s*', '', title)
                # Limpar resto da string (empresa, localização, etc.)
                title = title.split("Fechar vaga de")[0].strip()
                # Se tiver " · " ou "Anunciada", dividir
                if " · " in title:
                    parts = title.split(" · ")
                    title = parts[0].strip()
                
                current_card = {
                    "aria_label": aria_label,
                    "title": title,
                    "company": "",
                    "location": "",
                    "modality": "",
                    "time_posted": "",
                    "is_selected": is_selected,
                    "is_verified": is_verified,
                    "is_promoted": is_promoted,
                    "connection_count": 0,
                    "raw_text": ""
                }
                results.append(current_card)
        
        # Detectar parágrafos dentro do card atual
        elif current_card is not None and re.match(r'^\s*-\s+paragraph:\s+(.+)$', line):
            match = re.match(r'^\s*-\s+paragraph:\s+(.+)$', line)
            if match:
                text = match.group(1).strip()
                # Acumular texto bruto
                current_card["raw_text"] += text + " "
                
                # Parse de campos
                if not current_card["company"] and is_company_line(text, current_card):
                    current_card["company"] = text
                elif not current_card["location"] and is_location_line(text):
                    current_card["location"] = text
                    current_card["modality"] = parse_modality(text)
                elif not current_card["time_posted"] and "Anunciada há" in text:
                    current_card["time_posted"] = text
                elif "conexões" in text or "ex-alunos" in text:
                    count = parse_connection_count(text)
                    if count > 0:
                        current_card["connection_count"] = count
        
        # Detectar fim de card (próximo button ou fim do main)
        elif re.match(r'^\s*-\s+button\s+"[^"]*"\s+\[e\d+\]:', line) and current_card is not None:
            current_card = None
        
        i += 1
    
    return results

def is_company_line(text, card):
    """
    Heuristica: linha é empresa se não for título, localização, badges, etc.
    Empresas típicas: "MB | Mercado Bitcoin", "Porto", "B3", "Nubank", "Uber", etc.
    """
    if not text:
        return False
    if text in ["·", "Visto", "Promovida", "Candidate-se"]:
        return False
    if "Anunciada há" in text:
        return False
    if "conexões" in text or "ex-alunos" in text:
        return False
    if "Você seria um dos melhores candidatos" in text:
        return False
    if "São Paulo" in text or "SP" in text or "Remoto" in text or "Híbrido" in text:
        return False
    if re.match(r'^(Tech Lead|Especialista|Sr Staff|Staff|IT Manager|Líder|I - |[0-9]+ - )', text):
        return False
    return True

def is_location_line(text):
    """Detecta se linha é localização com base em padrões típicos."""
    if not text:
        return False
    patterns = [
        r'São Paulo.*\(.*(Remoto|Híbrido|Presencial)\)',
        r'São Paulo.*Região.*\(.*(Remoto|Híbrido|Presencial)\)',
        r'.*, SP.*\(.*(Remoto|Híbrido|Presencial)\)',
        r'Osasco, SP',
        r'Barueri, SP',
        r'100% remoto',
        r'Remoto',
        r'Híbrido',
        r'Presencial',
    ]
    for p in patterns:
        if re.search(p, text):
            return True
    return False

def parse_modality(location_str):
    """Extrai modality (Remoto/Híbrido/Presencial) da string de localização."""
    if not location_str:
        return ""
    if "Remoto" in location_str:
        return "Remoto"
    if "Híbrido" in location_str:
        return "Híbrido"
    if "Presencial" in location_str:
        return "Presencial"
    return "N/A"

def parse_connection_count(text):
    """Extrai número de conexões/ex-alunos."""
    # "21 conexões trabalham aqui"
    match = re.search(r'(\d+)\s*conexões', text)
    if match:
        return int(match.group(1))
    # "4 ex-alunos da instituição trabalham aqui"
    match = re.search(r'(\d+)\s*ex-alunos', text)
    if match:
        return int(match.group(1))
    return 0
```

---

## Recipe 2: Extração via estrutura JSON do snapshot

Se o snapshot for lido como estrutura JSON (quando disponível), usar abordagem mais direta:

```python
def parse_from_snapshot_json(snapshot_data):
    """
    snapshot_data é o dict retornado por read_file quando o arquivo é JSON estruturado.
    """
    results = []
    main = snapshot_data.get("snapshot", {}).get("main", [])
    
    for item in main:
        if "button" in item:
            btn = item["button"]
            aria_label = btn.get("aria-label", "") or btn.get("text", "")
            paragraphs = btn.get("paragraphs", [])
            
            # Extrair campos dos paragraphs
            title = ""
            company = ""
            location = ""
            time_posted = ""
            connection_count = 0
            
            for p in paragraphs:
                text = p.get("text", "")
                if not title and is_title_line(text, aria_label):
                    title = text
                elif not company and is_company_line(text, {"aria_label": aria_label}):
                    company = text
                elif not location and is_location_line(text):
                    location = text
                elif "Anunciada há" in text:
                    time_posted = text
            
            results.append({
                "title": title,
                "company": company,
                "location": location,
                "modality": parse_modality(location),
                "time_posted": time_posted,
                "connection_count": connection_count,
                "is_verified": "Vaga verificada" in aria_label,
                "is_promoted": "Promovida" in aria_label,
            })
    
    return results
```

---

## Recipe 3: Detecção de badges e indicadores

```python
def extract_badges(aria_label, paragraphs_text):
    """
    Extrai todos os badges/indicadores de uma card.
    """
    badges = {
        "is_selected": False,
        "is_verified": False,
        "is_promoted": False,
        "is_viewed": False,
        "has_apply_link": False,
        "connection_count": 0,
        "time_posted": None,
    }
    
    # Dos aria-label
    if "Selecionada" in aria_label or "Você seria um dos melhores candidatos" in aria_label:
        badges["is_selected"] = True
    if "Vaga verificada" in aria_label:
        badges["is_verified"] = True
    if "Promovida" in aria_label:
        badges["is_promoted"] = True
    if "Visto" in aria_label:
        badges["is_viewed"] = True
    
    # Dos paragraphs
    full_text = " ".join(paragraphs_text)
    if "Candidate-se" in full_text:
        badges["has_apply_link"] = True
    
    match = re.search(r'(\d+)\s*(?:conexões|ex-alunos)', full_text)
    if match:
        badges["connection_count"] = int(match.group(1))
    
    match = re.search(r'Anunciada há\s+(.+?)(?:\n|$)', full_text)
    if match:
        badges["time_posted"] = match.group(1).strip()
    
    return badges
```

---

## Heuristicas de title parsing

O título da vaga no aria-label pode vir com diversos prefixos/suffixos:

```python
def clean_job_title(aria_label):
    """
    Limpa o aria-label para extrair apenas o título da vaga.
    """
    title = aria_label
    
    # Remover prefixos
    for prefix in ["Selecionada, ", "Vaga verificada, ", "Promovida, "]:
        if title.startswith(prefix):
            title = title[len(prefix):]
    
    # Remover suffixos (após " · ")
    if " · " in title:
        parts = title.split(" · ")
        title = parts[0].strip()
    
    # Remover "Fechar vaga de " se presente
    title = re.sub(r'Fechar vaga de\s*', '', title)
    
    # Remover badges finais
    for badge in ["Vaga verificada", "Promovida", "Visto", "Candidate-se"]:
        title = title.replace(badge, "")
    
    # Limpar whitespace
    title = " ".join(title.split())
    
    # Se título estiver vazio ou muito curto, usar heuristica alternativa
    if len(title) < 5:
        # Tentar extrair entre padrões conhecidos
        match = re.search(r'(Tech Lead[^|]+|Especialista[^|]+|Staff[^|]+|Sr[^|]+|IT Manager[^|]+|Líder[^|]+)', title)
        if match:
            title = match.group(1).strip()
    
    return title
```

---

## Exemplo de uso completo

```python
from hermes_tools import read_file, write_file

# 1. Ler snapshot
snapshot_path = "/opt/data/cache/web/browser-snapshot-671f9da92e.txt"
snapshot = read_file(path=snapshot_path)

# 2. Parse das vagas
vagas = parse_job_cards_snapshot(snapshot_path)

# 3. Filtrar por critérios do usuário
def relevant_for_user(vaga):
    """Verifica se vaga é relevante para o perfil do usuário."""
    # Stack: IA, Node, Arquitetura, Java, etc.
    title_lower = vaga["title"].lower()
    company_lower = vaga["company"].lower()
    
    relevant_stacks = ["tech lead", "software engineer", "ia", "arquitetura", 
                       "cloud", "backend", "fullstack", "java", "node", "python"]
    relevant_roles = ["tech lead", "staff", "senior", "arquiteto", "especialista"]
    
    has_relevant_stack = any(s in title_lower or s in company_lower for s in relevant_stacks)
    has_relevant_role = any(r in title_lower for r in relevant_roles)
    
    # Modality: remoto ou híbrido SP (CLT aceitável, PJ preferido)
    modality = vaga.get("modality", "")
    relevant_location = modality in ["Remoto", "Híbrido"] or "São Paulo" in vaga.get("location", "")
    
    return has_relevant_stack and has_relevant_role and relevant_location

relevant_vagas = [v for v in vagas if relevant_for_user(v)]

# 4. Salvar resultados
write_file(
    path="/tmp/linkedin_vagas_extracted.json",
    content=json.dumps(vagas, indent=2, ensure_ascii=False)
)

# 5. Report
print(f"Total de vagas na página: {len(vagas)}")
print(f"Vagas relevantes para o usuário: {len(relevant_vagas)}")
for v in relevant_vagas:
    print(f"- [{v['modality']}] {v['title']} @ {v['company']} ({v['location']})")
```

---

## Pontos de atenção

1. **Sessão pode expirar:** se o snapshot vier vazio ou com erro, reconectar via `browser_navigate` e retranscrever
2. **Cards promovidas:** aparecem no topo, podem distorcer ordenação por relevância
3. **Company vazia:** algumas cards podem não ter empresa claramente identificada — manter campo vazio, não inventar
4. **Location variável:** "São Paulo, SP (Híbrido)" vs "São Paulo, SP (Remoto)" vs "Osasco, SP" — parse robusto necessário
5. **Time posted:** "há 3 semanas", "há 4 dias", "há 1 mês" — normalizar para dias se necessário para filtragem por recência
6. **Connection count:** pode ser "X conexões" ou "X ex-alunos" — ambos indicam concorrência

---

## Campos para Job Process Pipeline

| Campo | Origem no snapshot | Uso no pipeline |
|-------|-------------------|-----------------|
| `title` | Primeiro paragraph ou parse do aria-label | Título da vaga no Notion |
| `company` | Segundo paragraph (heurística) | Nome da empresa no Notion |
| `location` | Terceiro paragraph | Localização no Notion |
| `modality` | Parse de "Remoto/Híbrido/Presencial" | Filtro Freelance-First (remoto PJ = ACEITAR) |
| `time_posted` | "Anunciada há X" | Filtro por recência |
| `is_verified` | Badge "Vaga verificada" | Confiança na vaga (postado pela empresa) |
| `is_promoted` | Badge "Promovida" | Vaga paga pelo LinkedIn (pode ser menos relevante) |
| `is_selected` | "Selecionada"/"Você seria um dos melhores" | Recomendação personalizada (alta relevância) |
| `connection_count` | "X conexões/ex-alunos" | Indicador de concorrência |
| `has_apply_link` | "Candidate-se" presente | Se true, pode haver aplicação via LinkedIn |

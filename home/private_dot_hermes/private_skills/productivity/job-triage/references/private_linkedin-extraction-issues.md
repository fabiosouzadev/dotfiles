# LinkedIn Post Extraction Issues (Aug 2026)

## Login Wall Problem

Many LinkedIn shared post URLs (`linkedin.com/posts/...`) redirect to login page when accessed without auth cookies. Even public posts sometimes show login modal.

**Workarounds:**
1. **User provides text content** — Most reliable: user copies post text and sends directly
2. **Camofox with cookies** — Use authenticated browser session (requires login flow setup)
3. **web_extract with firecrawl/tavily** — Some extraction backends can bypass (not configured)

**Pattern observed:** Posts from `linkedin.com/posts/` often require login; `linkedin.com/jobs/view/` may be more accessible.

## Company Extraction Algorithm (Working)

**Priority order (implemented in `triage.py`):**
1. Explicit patterns: `Empresa: X`, `Company: Y`, `Contratante: Z`, `A X é uma [setor]tech`
2. Domain from email: `user@empresa.com` → `Empresa` (removes TLDs, filters person-name domains)
3. @handle (not email): `@empresa` but NOT `@domain.com`
4. `Postado por X` / `Autor: X` — filtered for person names (2-3 capitalized words)
5. First relevant capitalized word from content (excludes tech terms list)

**Tech terms exclusion list** (50+ terms): Node.js, Java, Python, React, Spring, Boot, Django, NestJS, AWS, GCP, Azure, Kubernetes, Docker, Kafka, PostgreSQL, MongoDB, TypeScript, JavaScript, Go, Rust, CLT, PJ, Remoto, Híbrido, Presencial, Sênior, Senior, Tech, Lead, Arquiteto, Fullstack, Backend, Frontend, Pleno, Júnior, Junior, Estágio, Estagio, Vaga, Oportunidade, Engenheiro, Engenheira, Desenvolvedor, Desenvolvedora, etc.

**Person name filter:** Regex `^[A-Z][a-z]+(?:\s+[A-Z][a-z]+){1,2}$` catches "Julia Argueiro", "Catarina Ugolini Maragno", "Carla Ferreira", "Leony Nobre"

## Notion Card Title Format (Validated)

Format: `"Empresa - Cargo (Score)"`
Examples:
- `Hanzo - Vaga do LinkedIn (70)`
- `Deal - Vaga do LinkedIn (100)`
- `Tiviati - Vaga do LinkedIn (65)`
- `confidencial (IoT/IAoT) - São Paulo/SP - Vaga do LinkedIn (83)`

## Email Subject Format (Validated)

`Candidatura: Vaga do LinkedIn - {Empresa} (Tech Lead/Arquiteto Sênior - PJ Remoto)`

Works correctly with company extracted from content/email domain.

## Notion Database Cleanup (Aug 2026)

**Before:** 46 cards (many duplicates, old format)
**After:** 5 clean cards

**Cleanup script pattern:**
```python
# Keep only cards with correct format "Empresa - Cargo (Score)"
keep_titles = {"Hanzo - Vaga do LinkedIn (70)", "Deal - Vaga do LinkedIn (100)", ...}
for page in all_pages:
    if page_title not in keep_titles:
        archive_page(page.id)
```

**Archive endpoint:** `PATCH /pages/{id} {"archived": true}`
Rate limit: ~3 req/s (safe with small delays)
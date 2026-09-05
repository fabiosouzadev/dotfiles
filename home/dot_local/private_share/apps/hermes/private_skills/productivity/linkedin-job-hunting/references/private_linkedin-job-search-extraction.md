# LinkedIn Job Search Extraction — Session Reference (2026-08-31)

## Overview
Patterns for extracting job listings from LinkedIn job search results page (`/jobs/search-results/`).

## Navigation
- URL pattern: `https://www.linkedin.com/jobs/search-results/?keywords=<KEYWORDS>&geoId=<GEO_ID>`
- Optional params: `currentJobId`, `showHowYouFit`, `origin`, `originToLandingJobPostings`
- Wait for page to load: snapshot shows "X + resultados" or job cards when ready

## Page Structure
- **Header**: Search box, nav (Início, Minha rede, Vagas, Mensagens, Notificações), user menu
- **Toolbar**: Filters (Data de publicação, Candidatura via LinkedIn, Menos de 10 candidaturas, Na minha rede)
- **Main content**: Vertical list of job cards (each is a `<button>` element)
- **Pagination**: Page number buttons (1, 2, 3...) + "Próxima" button at bottom
- **Footer**: "Esses resultados foram úteis?" feedback section

## Job Card Structure
Each job card is a `<button>` in `main` containing multi-line text:
- **Line 1**: Job title (e.g., "Backend Software Engineer Lead", "Tech Lead - Java (Conta Digital)")
- **Line 2**: Company (e.g., "MB | Mercado Bitcoin", "Porto", "B3", "Nubank")
- **Line 3**: Location (e.g., "São Paulo, SP (Híbrido)", "São Paulo, SP (Remoto)", "São Paulo, SP (Presencial)")
- **Badges**: "Visto", "Candidate-se", "Vaga verificada", "Promovida"
- **Time**: "Anunciada há X" (e.g., "há 3 semanas", "há 4 dias", "há 1 mês")
- **Connections**: "X conexões trabalham aqui" or "X ex-alunos da instituição trabalham aqui"

## Extraction Approach
1. Navigate to search URL via `browser_navigate`
2. Wait for job cards to load (snapshot shows cards when ready)
3. Read snapshot with `browser_snapshot(full=true)`
4. Parse each button's text content to extract fields

## Data Fields to Extract for Job Process Pipeline
For each job card, extract:
- `title`: Job title (first line of button text)
- `company`: Company name (second line)
- `location`: Location string (third line)
- `modality`: Parse from location string — "Remoto", "Híbrido", "Presencial"
- `time_posted`: Extract "há X" pattern (e.g., "3 semanas", "4 dias", "1 mês")
- `is_promoted`: Whether "Promovida" badge is present
- `is_verified`: Whether "Vaga verificada" badge is present
- `is_selected`: Whether "Selecionada" or "Você seria um dos melhores candidatos" is present
- `connection_count`: Parse "X conexões" or "X ex-alunos" pattern
- `has_apply_link`: Whether "Candidate-se" button/text is present

## Edge Cases
- **Promoted jobs**: Have "Promovida" badge, may appear at top of results
- **Selected/personalized jobs**: Have "Selecionada" or "Você seria um dos melhores candidatos" — these are personalized recommendations based on profile
- **Verified jobs**: Have "Vaga verificada" badge (posted by company, not third-party recruiter)
- **Connection count variations**: "X conexões trabalham aqui" or "X ex-alunos da instituição trabalham aqui"
- **Missing company**: Some cards may have empty company line (parse defensively)
- **Location variations**: "São Paulo, SP (Híbrido)", "São Paulo, SP (Presencial)", "São Paulo, SP (Remoto)", "São Paulo e Região (Presencial)", "Osasco, SP", "Barueri, SP"

## Pagination
- Page number buttons: `button[Página 1]`, `button[Página 2]`, etc.
- Next button: `button[Próxima]`
- To get more jobs: click "Próxima" or click page number buttons
- Each page loads ~25 jobs (varies by viewport/UI)

## Limitations
- LinkedIn may require login for full access (dialog "Entre para visualizar mais conteúdos")
- Some job details require clicking into the individual job posting
- Pagination may be infinite scroll or page-based depending on UI version
- Job card structure may change with LinkedIn UI updates
- Camofox session must be active for browser automation to work

## Session Notes (2026-08-31)
- Searched for "Tech Lead de Software" in Brazil (geoId=90009574)
- Found 99+ results, extracted first 25 from page 1
- Job cards are buttons with multi-line text content
- Pagination available via "Próxima" button and page number buttons
- Camofox went offline during extraction, preventing completion of 100 jobs
- Some job cards have incomplete text (missing company or location on separate lines)
- Location modality must be parsed from location string (Remoto/Híbrido/Presencial)

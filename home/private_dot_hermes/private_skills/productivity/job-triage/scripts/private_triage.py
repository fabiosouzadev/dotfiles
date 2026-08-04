#!/usr/bin/env python3
"""
Job Triage Main Script
Receives a job URL, extracts content, scores against profile, takes action.
"""

import sys
import os
import json
import subprocess
import re
from pathlib import Path

# Add skill directory to path
SKILL_DIR = Path(__file__).parent.parent
SCRIPTS_DIR = Path(__file__).parent
sys.path.insert(0, str(SCRIPTS_DIR))

from extract_content import extract_job_content, extract_keywords, find_email_in_text
from score_vaga import score_job, CANDIDATE_PROFILE


def extract_company_from_content(content: str, url: str) -> str:
    """Tenta extrair nome da empresa do conteúdo da vaga ou URL."""
    if not content:
        return "Empresa não identificada"
    
    # PRIORIDADE 1: Padrões explícitos de empresa no texto
    # Ex: "A Hanzo é uma foodtech...", "Empresa: X", "Company: Y"
    company_patterns = [
        r'(?i)a\s+(\w+)\s+é\s+uma\s+\w+tech',  # "A Hanzo é uma foodtech"
        r'(?i)empresa[:@\s]+([^\n]+)',
        r'(?i)company[:@\s]+([^\n]+)',
        r'(?i)contratante[:@\s]+([^\n]+)',
        r'(?i)hiring\s+(?:company|for)[:@\s]+([^\n]+)',
        r'(?i)post(?:ado)?\s+por[:@]\s*([^\n@]+?)(?:\s+[-–—|:]|\s+https?://|$)',
        r'(?i)autor[:@\s]+([^\n]+)',
    ]
    for pat in company_patterns:
        m = re.search(pat, content)
        if m:
            candidate = m.group(1).strip()
            # Filtrar nomes que parecem de pessoas (duas OU TRÊS palavras capitalizadas)
            # Ex: "Catarina Ugolini", "Andréa B", "Julia Argueiro", "Carla Ferreira"
            if not re.match(r'^[A-Z][a-z]+(?:\s+[A-Z][a-z]+){1,2}$', candidate):
                return candidate
    
    # PRIORIDADE 2: @usuario mas NÃO domínios de email
    at_match = re.search(r'@(\w+)(?![.\w]*\.(com|br|org|net|io|co|me|ai|gov|edu))', content)
    if at_match:
        return at_match.group(1).capitalize()
    
    # PRIORIDADE 3: Tentar extrair do domínio do email
    email_match = re.search(r'@([\w.-]+)', content)
    if email_match:
        domain = email_match.group(1)
        # Handle multi-level TLDs like .com.br, .inf.br, .co.uk, .org.br, etc.
        # List of known second-level domains in BR
        br_second_level = ['com', 'org', 'net', 'edu', 'gov', 'mil', 'inf', 'eco', 'co', 'blog', 'shop', 'app', 'dev', 'ai', 'tech', 'io', 'me', 'br']
        # Try to match known patterns
        for tld in br_second_level:
            pattern = rf'\.{tld}\.(br|com|org|net)$'
            if re.search(pattern, domain):
                domain = re.sub(pattern, '', domain)
                break
        # Also handle .com.br, .org.br, etc.
        domain = re.sub(r'\.(com|br|org|net|io|co|me|ai|gov|edu)(\.(br|com|org|uk|au|ca))?$', '', domain)
        if domain and len(domain) > 2:
            # Verificar se não parece nome de pessoa (ex: primeiro.ultimo, primeiro_ultimo)
            # Mas aceitar domínios válidos de empresa (letras, números, hífens, pontos para subdomínios)
            if not re.search(r'^[a-z]+\.[a-z]+$', domain) and re.match(r'^[a-zA-Z0-9.-]+$', domain):
                # Pegar a parte principal - para domínios como datum.inf, pegar 'datum' (o primeiro segmento significativo)
                parts = domain.split('.')
                # Se tem subdomínio (ex: datum.inf), pegar o primeiro (datum)
                # Se é domínio simples (ex: empresa), pegar ele
                main_domain = parts[0]
                if len(main_domain) > 2:
                    return main_domain.capitalize()
    
    # PRIORIDADE 3b: Tentar extrair de URLs no conteúdo (ex: ats.landor.com.br)
    url_match = re.search(r'https?://([\w.-]+)', content)
    if url_match:
        domain = url_match.group(1)
        domain = re.sub(r'\.(com|br|org|net|io|co|me|ai|gov|edu)(\.(br|com|org))?$', '', domain)
        if domain and len(domain) > 2:
            if not re.search(r'^[a-z]+\.[a-z]+$', domain) and re.match(r'^[a-zA-Z0-9.-]+$', domain):
                main_domain = domain.split('.')[0]
                if len(main_domain) > 2:
                    return main_domain.capitalize()
    
    # PRIORIDADE 3c: Tentar extrair de domínios "nus" no conteúdo (ex: ats.landor.com.br)
    bare_domain_match = re.search(r'\b([a-zA-Z0-9-]+\.[a-zA-Z0-9.-]+\.(?:com\.br|com|br|org|net|io|co|me|ai|gov|edu))\b', content)
    if bare_domain_match:
        domain = bare_domain_match.group(1)
        # Para domínios .com.br, a parte principal é o penúltimo segmento
        if domain.endswith('.com.br'):
            domain = domain[:-7]  # remove .com.br
            main_domain = domain.split('.')[-1]  # pega o último (ex: landor)
        else:
            domain = re.sub(r'\.(com|br|org|net|io|co|me|ai|gov|edu)(\.(br|com|org))?$', '', domain)
            main_domain = domain.split('.')[-1]
        if main_domain and len(main_domain) > 2:
            return main_domain.capitalize()
    
    # PRIORIDADE 4: Primeira palavra capitalizada relevante (não tech terms)
    tech_terms = {'Node.js', 'Java', 'Python', 'React', 'Spring', 'Boot', 'Django', 'NestJS', 'AWS', 'GCP', 'Azure', 'Kubernetes', 'Docker', 'Kafka', 'PostgreSQL', 'MongoDB', 'TypeScript', 'JavaScript', 'Go', 'Rust', 'CLT', 'PJ', 'Remoto', 'Híbrido', 'Presencial', 'Sênior', 'Senior', 'Tech', 'Lead', 'Arquiteto', 'Fullstack', 'Backend', 'Frontend', 'Pleno', 'Júnior', 'Junior', 'Estágio', 'Estagio', 'Vaga', 'Oportunidade', 'Olá', 'Estou', 'Buscando', 'Engenheiro', 'Engenheira', 'Engenheiroa', 'Desenvolvedor', 'Desenvolvedora', 'Sistemas', 'Distribuídos', 'Microserviços', 'Pipeline', 'Dados', 'Mensageria', 'Bancos', 'Relacionais', 'Analíticos', 'Escala', 'Concorrência', 'Latência', 'Resiliência', 'Mentoria', 'Hands-on', 'IoT', 'IAoT', 'Confidencial', 'São', 'Paulo', 'Segunda', 'Sexta', 'Horários', 'Modalidade', 'Sede', 'Quantidade', 'Requisitos', 'Experiência', 'Comprovada', 'Domínio', 'Vivência', 'Resolvendo', 'Problemas', 'Capacidade', 'Análise', 'Comunicação', 'Técnica', 'Responsabilidades', 'Evoluir', 'Plataforma', 'Core', 'Desenvolver', 'Revisar', 'Código', 'Caminhos', 'Críticos', 'Performance', 'Definir', 'Padrões', 'Arquitetura', 'Observabilidade', 'Mentorar', 'Produto', 'DevOps', 'Atuar', 'Incident', 'Response', 'Contínua', 'Interessados', 'Enviem', 'Palavra', 'Através', 'Link', 'Software', 'Full', 'Stack', 'Senior', 'Sênior', 'Anos', 'Experiência', 'Inglês', 'Fluente', 'Negociável', 'Enviar', 'CV', 'Para', 'Postado', 'Por', 'Mês', 'Milhões', 'Transações', 'Ano', 'Liderança', 'Cross-squad', 'Mentoria', 'Profiling', 'Tuning', 'Cache', 'Distribuído', 'Foodtech', 'Própria', 'CRM', 'Fidelização', 'Pedidos', 'Digitais', 'Processando', 'Integrações', 'Reais', 'Pagamento', 'Delivery', 'WhatsApp', 'Fidelidade', 'Não', 'Sistema', 'Brinquedo', 'Alta', 'Disponibilidade', 'Baixa', 'Evolução', 'Contínua', 'Verdade', 'Arquitetura', 'Monolítica', 'Modular', 'Greenfield', 'Fácil', 'Iniciativas', 'Voz', 'Decisões', 'Troubleshooting', 'Produção', 'Não', 'Só', 'Teoria', 'Diferenciais', 'Fazem', 'Diferença', 'SaaS', 'SLO', 'Kinesis', 'Uso', 'Dia', 'Copilot', 'Claude', 'Code', 'Cursor', 'Foodtech', 'Plataforma', 'CRM', 'Fidelização', 'Pedidos', 'Digitais', 'Processando', 'Milhões', 'Transações', 'Integrações', 'Reais', 'Pagamento', 'Delivery', 'WhatsApp', 'Fidelidade', 'Não', 'Sistema', 'Brinquedo', 'Alta', 'Disponibilidade', 'Baixa', 'Latência', 'Evolução', 'Contínua', 'Verdade', 'Arquitetura', 'Monolítica', 'Modular', 'Greenfield', 'Fácil', 'Engenharia', 'Iniciativas', 'Cross-squad', 'Voz', 'Decisões', 'Problemas', 'Reais', 'Performance', 'Concorrência', 'Escala', 'Profiling', 'GC', 'Tuning', 'Cache', 'Distribuído', 'Mentoria', 'Outros', 'Cultura', 'Code', 'Review', 'Importa', 'Pedimos', 'Vivência', 'Sistemas', 'Resilientes', 'Bagagem', 'Troubleshooting', 'Produção', 'Não', 'Só', 'Teoria', 'Diferenciais', 'Fazem', 'Diferença', 'SaaS', 'SLO', 'Kubernetes', 'Docker', 'Kafka', 'Kinesis', 'Uso', 'Dia', 'Copilot', 'Claude', 'Code', 'Cursor', 'Internacional', 'Principal', 'Full', 'Stack', 'E-commerce', 'ERP', 'Shopify', 'Arquitetura', 'Microserviços', 'Cloud', 'CI/CD', 'Candidatura', 'Via', 'Link', 'Notion', 'Comentários', 'Postado', 'Por', 'Tech', 'Lead', 'React', 'Node.js', 'TypeScript', 'Kafka', 'AWS', 'GCP', 'Azure'}
    
    lines = content.strip().split('\n')
    for line in lines[:15]:
        line = line.strip()
        if line and not line.startswith(('🔥', '🚀', 'VAGA:', 'Teste', 'Oportunidade', 'Olá', 'Estou', 'Buscando')):
            words = line.split()
            for w in words[:4]:
                # Limpar pontuação
                w_clean = re.sub(r'[^\w\s.-]', '', w)
                if w_clean and w_clean[0].isupper() and len(w_clean) > 2 and w_clean not in tech_terms:
                    # Se for duas palavras capitalizadas, pode ser nome de pessoa - evitar
                    if ' ' not in w_clean:
                        return w_clean
    
    return "Empresa não identificada"


def run_shell_script(script_name: str, args: list) -> tuple[bool, str]:
    """Executa script shell e retorna (sucesso, output)."""
    script_path = SCRIPTS_DIR / script_name
    if not script_path.exists():
        return False, f"Script não encontrado: {script_path}"
    
    cmd = [str(script_path)] + args
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120, env={**os.environ})
        return result.returncode == 0, result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return False, "Timeout"
    except Exception as e:
        return False, str(e)


def send_application_email(job_data: dict, email: str) -> bool:
    """Envia candidatura via script shell send-application.sh."""
    title = job_data.get('title', 'Vaga')
    company = job_data.get('company', 'Empresa')
    # Se empresa for genérica, tentar extrair do conteúdo
    if company in ['Empresa não identificada', 'Empresa', '']:
        company = extract_company_from_content(job_data.get('content', ''), job_data.get('url', ''))
    url = job_data.get('url', '')
    score = job_data.get('score', 0)
    cv_path = CANDIDATE_PROFILE['cv_path']
    linkedin = CANDIDATE_PROFILE['linkedin']
    
    success, output = run_shell_script("send-application.sh", [
        email, title, company, url, str(score), cv_path, linkedin
    ])
    print(output)
    return success


def create_notion_card(job_data: dict, etapa: str) -> bool:
    """Cria card no Notion via script shell create-notion-card.sh."""
    # Preparar JSON para o script
    json_data = json.dumps(job_data, ensure_ascii=False)
    # Passar etapa como variável de ambiente
    env = {**os.environ, 'ETAPA_PARAM': etapa}
    success, output = run_shell_script("create-notion-card.sh", [json_data])
    print(output)
    return success


def send_telegram_card(job_data: dict, action: str) -> bool:
    """Envia card visual para Telegram (placeholder - implementar depois)."""
    # TODO: Implementar telegram_card.py ou chamar API do Telegram
    # Por enquanto, apenas loga o card
    title = job_data.get('title', 'Vaga')
    company = job_data.get('company', 'Empresa')
    score = job_data.get('score', 0)
    url = job_data.get('url', '')
    email = job_data.get('email', 'Não encontrado')
    
    card = f"""🎯 **Triagem de Vaga** ({action})
**{title}** — {company}
📊 Score: **{score}/100**
🔗 {url}
📧 {email}
"""
    print("📱 [TELEGRAM CARD]")
    print(card)
    # Salvar para envio manual via MEDIA:
    import tempfile
    with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False, prefix='job_card_') as f:
        f.write(card)
        print(f"   Card salvo em: {f.name}")
    return True


def main():
    if len(sys.argv) < 2:
        print("Uso: triage.py <job_url>")
        sys.exit(1)
    
    job_url = sys.argv[1]
    print(f"🔍 Analisando vaga: {job_url}")
    
    # 1. Extrair conteúdo da vaga
    print("📄 Extraindo conteúdo...")
    job_data = extract_job_content(job_url)
    
    if not job_data or not job_data.get('content'):
        print("❌ Falha ao extrair conteúdo da vaga")
        # Tentar usar URL como conteúdo bruto para scoring heurístico
        job_data = {'url': job_url, 'content': job_url, 'source': 'url_only'}
    
    # Enriquecer com keywords e email
    keywords = extract_keywords(job_data.get('content', ''))
    job_data['keywords'] = keywords
    job_data['email'] = find_email_in_text(job_data.get('content', ''))
    job_data['tags'] = keywords.get('stack', []) + keywords.get('cloud', []) + keywords.get('domain', []) + keywords.get('ai', [])
    job_data['modalidade'] = []
    if keywords.get('contract') == 'pj':
        job_data['modalidade'].append('PJ')
    if keywords.get('remote'):
        job_data['modalidade'].append('Remoto')
    elif keywords.get('contract') == 'clt':
        job_data['modalidade'].append('CLT')
    job_data['title'] = job_data.get('title', 'Vaga do LinkedIn')
    
    # Extrair empresa ANTES de usar no Notion/email
    job_data['company'] = extract_company_from_content(job_data.get('content', ''), job_data.get('url', ''))
    
    print(f"✅ Conteúdo processado ({len(job_data.get('content', ''))} chars)")
    print(f"🏢 Empresa identificada: {job_data['company']}")
    
    # 2. Scoring
    print("🧮 Calculando score...")
    score_result = score_job(job_data.get('content', ''))
    score = score_result['score']
    details = score_result['details']
    
    print(f"📊 Score: {score}/100")
    print(f"   Detalhes: {json.dumps(details, ensure_ascii=False, indent=2)}")

    # Determinar etapa baseado no score e email (usar apenas Etapa Atual)
    email = job_data.get('email')
    if score >= 70 and email and email != 'null':
        etapa = 'Aguardando retorno'
    elif score >= 70 and (not email or email == 'null'):
        etapa = 'Sem email'
    elif score >= 40:
        etapa = 'Análise necessária'
    else:
        etapa = 'Arquivado'

    # 3. Decisão baseada no score
    job_data['score'] = score
    job_data['score_details'] = details
    job_data['url'] = job_url

    if score >= 70:
        # Alta prioridade - tentar auto-candidatura
        print("🎯 Score alto (≥70) - tentando candidatura automática...")

        email = job_data.get('email')
        if email:
            print(f"📧 Email encontrado: {email}")
            success = send_application_email(job_data, email)
            if success:
                print("✅ Candidatura enviada com sucesso!")
                create_notion_card(job_data, etapa="Aguardando retorno")
            else:
                print("⚠️ Falha no envio - criando card Notion para ação manual")
                create_notion_card(job_data, etapa="Preparar candidatura")
        else:
            print("📭 Sem email na descrição - criando card Notion para candidatura manual")
            create_notion_card(job_data, etapa="Preparar candidatura")

        send_telegram_card(job_data, action="auto_applied" if email else "needs_manual")

    elif score >= 40:
        # Média prioridade - Notion + Telegram para decisão
        print("🤔 Score médio (40-69) - criando card para análise")
        create_notion_card(job_data, etapa="Análise necessária")
        send_telegram_card(job_data, action="review_needed")

    else:
        # Baixa prioridade - apenas log/arquivar
        print(f"📉 Score baixo ({score}) - arquivando")
        create_notion_card(job_data, etapa="Arquivado")


if __name__ == "__main__":
    main()
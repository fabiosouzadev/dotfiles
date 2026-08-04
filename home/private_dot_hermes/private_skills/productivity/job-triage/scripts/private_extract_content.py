#!/usr/bin/env python3
"""
Extract job content from URL.
Uses web_extract (for public pages) or Camofox (for authenticated LinkedIn).
"""

import sys
import json
import re
from urllib.parse import urlparse

def extract_job_content(url: str) -> dict:
    """
    Extrai conteúdo de uma URL de vaga.
    Retorna dict com: title, company, content, email, location, contract_type, etc.
    """
    
    parsed = urlparse(url)
    domain = parsed.netloc.lower()
    
    # LinkedIn público - usar web_extract via terminal
    if 'linkedin.com' in domain:
        return extract_linkedin_public(url)
    
    # Outros sites - tentar web_extract genérico
    return extract_generic(url)


def extract_linkedin_public(url: str) -> dict:
    """Extrai vaga pública do LinkedIn via web_extract."""
    try:
        # Usar terminal tool via subprocess para chamar web_extract
        # Na prática, isso será chamado via execute_code ou terminal tool do Hermes
        import subprocess
        
        # Chamar via curl para web_extract endpoint se disponível
        # Por enquanto, retorna estrutura esperada para ser preenchida pelo chamador
        return {
            'url': url,
            'source': 'linkedin',
            'title': '',
            'company': '',
            'content': '',
            'email': None,
            'location': '',
            'contract_type': '',
            'seniority': '',
            'raw_html': ''
        }
    except Exception as e:
        print(f"Erro ao extrair LinkedIn: {e}")
        return {}


def extract_generic(url: str) -> dict:
    """Extração genérica para outros sites."""
    return {
        'url': url,
        'source': 'generic',
        'title': '',
        'company': '',
        'content': '',
        'email': None,
        'location': '',
        'contract_type': '',
        'seniority': '',
        'raw_html': ''
    }


def find_email_in_text(text: str) -> str | None:
    """Encontra email no texto."""
    email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    matches = re.findall(email_pattern, text)
    # Filtrar emails genéricos (noreply, support, etc.)
    filtered = [m for m in matches if not any(x in m.lower() for x in ['noreply', 'no-reply', 'support', 'help', 'info@', 'contact@', 'admin@'])]
    return filtered[0] if filtered else (matches[0] if matches else None)


def extract_keywords(text: str) -> dict:
    """Extrai palavras-chave relevantes do texto da vaga."""
    text_lower = text.lower()
    
    keywords = {
        'stack': [],
        'cloud': [],
        'domain': [],
        'ai': [],
        'seniority': '',
        'contract': '',
        'remote': False
    }
    
    # Stack
    stack_keywords = ['node.js', 'nodejs', 'nestjs', 'nestjs', 'java', 'spring boot', 'springboot', 
                      'python', 'django', 'fastapi', 'flask', 'react', 'next.js', 'nextjs', 
                      'typescript', 'javascript', 'go', 'golang', 'rust', 'c#', '.net', 'kotlin']
    for kw in stack_keywords:
        if kw in text_lower:
            keywords['stack'].append(kw)
    
    # Cloud
    cloud_keywords = ['aws', 'gcp', 'google cloud', 'azure', 'kubernetes', 'k8s', 'docker', 
                      'terraform', 'ci/cd', 'jenkins', 'gitlab', 'github actions']
    for kw in cloud_keywords:
        if kw in text_lower:
            keywords['cloud'].append(kw)
    
    # Domain
    domain_keywords = ['fintech', 'pagamento', 'payment', 'gateway', 'pci-dss', 'pci dss', 
                       'banking', 'banco', 'cartão', 'card', 'transaction', 'transação']
    for kw in domain_keywords:
        if kw in text_lower:
            keywords['domain'].append(kw)
    
    # AI
    ai_keywords = ['llm', 'llms', 'generative ai', 'genai', 'generative', 'langchain', 'langfuse', 
                   'openai', 'anthropic', 'claude', 'gpt', 'rag', 'agent', 'agente', 'ai', 'ml', 
                   'machine learning', 'deep learning']
    for kw in ai_keywords:
        if kw in text_lower:
            keywords['ai'].append(kw)
    
    # Seniority
    if any(x in text_lower for x in ['tech lead', 'techlead', 'technical lead', 'lead developer', 'liderança técnica']):
        keywords['seniority'] = 'tech_lead'
    elif any(x in text_lower for x in ['architect', 'arquiteto', 'architecture', 'arquitetura']):
        keywords['seniority'] = 'architect'
    elif any(x in text_lower for x in ['senior', 'sênior', 'sr.', 'sr ']):
        keywords['seniority'] = 'senior'
    elif any(x in text_lower for x in ['pleno', 'mid', 'mid-level']):
        keywords['seniority'] = 'pleno'
    elif any(x in text_lower for x in ['junior', 'júnior', 'jr.', 'jr ']):
        keywords['seniority'] = 'junior'
    
    # Contract
    if any(x in text_lower for x in ['pj', 'pessoa jurídica', 'freelance', 'freelancer', 'contrato', 'pessoa juridica', 'prestador', 'autônomo', 'autonomo']):
        keywords['contract'] = 'pj'
    elif any(x in text_lower for x in ['clt', 'carteira assinada', 'efetivo']):
        keywords['contract'] = 'clt'
    elif any(x in text_lower for x in ['cooperado', 'cooperativa']):
        keywords['contract'] = 'cooperado'
    
    # Remote
    if any(x in text_lower for x in ['100% remoto', '100% remote', 'full remote', 'totalmente remoto', 'home office', '100 % remoto', 'remoto', 'remote']):
        keywords['remote'] = True
    elif any(x in text_lower for x in ['híbrido', 'hibrido', 'hybrid', 'presencial', 'onsite']):
        keywords['remote'] = False
    
    return keywords


if __name__ == "__main__":
    # Teste
    if len(sys.argv) > 1:
        result = extract_job_content(sys.argv[1])
        print(json.dumps(result, ensure_ascii=False, indent=2))